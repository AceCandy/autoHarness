#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_SCRIPT="$ROOT_DIR/scripts/install.sh"
UPDATE_SCRIPT="$ROOT_DIR/scripts/update.sh"
UNINSTALL_SCRIPT="$ROOT_DIR/scripts/uninstall.sh"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/autoharness-tests.XXXXXX")"

cleanup() {
  rm -rf "$TMP_ROOT"
}

trap cleanup EXIT

pass() {
  printf '✅ %s\n' "$1"
}

fail() {
  printf '❌ %s\n' "$1" >&2
  exit 1
}

assert_file_exists() {
  [ -f "$1" ] || fail "缺少文件: $1"
}

assert_dir_exists() {
  [ -d "$1" ] || fail "缺少目录: $1"
}

assert_not_exists() {
  [ ! -e "$1" ] || fail "不应存在: $1"
}

assert_file_contains() {
  local file="$1"
  local expected="$2"

  grep -Fq -- "$expected" "$file" || fail "文件 $file 未包含: $expected"
}

assert_file_not_contains() {
  local file="$1"
  local unexpected="$2"

  if grep -Fq -- "$unexpected" "$file"; then
    fail "文件 $file 不应包含: $unexpected"
  fi
}

assert_text_contains() {
  local text="$1"
  local expected="$2"

  printf '%s' "$text" | grep -Fq -- "$expected" || fail "输出未包含: $expected"
}

test_install_all_and_clean_uninstall() {
  local project="$TMP_ROOT/install-all"

  mkdir -p "$project"
  bash "$INSTALL_SCRIPT" all --target "$project" >/dev/null

  assert_file_exists "$project/.autoharness/install-manifest.json"
  assert_file_contains "$project/.autoharness/install-manifest.json" '"AGENTS.md"'
  assert_file_contains "$project/.autoharness/install-manifest.json" '"CLAUDE.md"'
  assert_dir_exists "$project/.claude"
  assert_dir_exists "$project/.codex"

  (
    cd "$project"
    bash "$UNINSTALL_SCRIPT" --force >/dev/null
  )

  assert_not_exists "$project/AGENTS.md"
  assert_not_exists "$project/CLAUDE.md"
  assert_not_exists "$project/.autoharness"
  assert_not_exists "$project/.claude"
  assert_not_exists "$project/.codex"

  pass "全新项目安装 all 后可完整卸载"
}

test_custom_agents_stays_unmanaged() {
  local project="$TMP_ROOT/custom-agents"
  local update_output=""

  mkdir -p "$project"
  printf '%s\n' '# custom agents' > "$project/AGENTS.md"

  bash "$INSTALL_SCRIPT" codex --target "$project" >/dev/null

  assert_file_exists "$project/.autoharness/install-manifest.json"
  assert_file_not_contains "$project/.autoharness/install-manifest.json" '"AGENTS.md"'

  update_output="$(bash "$UPDATE_SCRIPT" --target "$project" --dry-run)"
  assert_text_contains "$update_output" '跳过：AGENTS.md (未标记为 AutoHarness 托管)'

  (
    cd "$project"
    bash "$UNINSTALL_SCRIPT" --force >/dev/null
  )

  assert_file_exists "$project/AGENTS.md"
  assert_file_contains "$project/AGENTS.md" '# custom agents'
  assert_not_exists "$project/.autoharness"
  assert_not_exists "$project/.codex"

  pass "已有自定义 AGENTS.md 时不会被 update 或 uninstall 误处理"
}

test_claude_settings_preserve_custom_hook() {
  local project="$TMP_ROOT/custom-claude-settings"

  mkdir -p "$project/.claude"
  cat > "$project/.claude/settings.json" <<'EOF'
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo custom-start"
          }
        ]
      }
    ]
  }
}
EOF

  bash "$INSTALL_SCRIPT" claude --target "$project" >/dev/null

  assert_file_contains "$project/.claude/settings.json" 'echo custom-start'
  if command -v jq >/dev/null 2>&1; then
    assert_file_contains "$project/.claude/settings.json" 'session-start.js'
  fi

  (
    cd "$project"
    bash "$UNINSTALL_SCRIPT" --force >/dev/null
  )

  assert_file_exists "$project/.claude/settings.json"
  assert_file_contains "$project/.claude/settings.json" 'echo custom-start'
  assert_file_not_contains "$project/.claude/settings.json" 'session-start.js'
  assert_not_exists "$project/.claude/hooks/session-start.js"
  assert_not_exists "$project/.autoharness"
  assert_not_exists "$project/AGENTS.md"
  assert_not_exists "$project/CLAUDE.md"

  pass "Claude 自定义 settings hooks 在卸载后仍保留"
}

test_legacy_update_is_conservative() {
  local project="$TMP_ROOT/legacy-project"
  local update_output=""

  mkdir -p "$project/.autoharness" "$project/.codex"
  printf '%s\n' '# legacy agents' > "$project/AGENTS.md"

  update_output="$(bash "$UPDATE_SCRIPT" --target "$project" --dry-run)"
  assert_text_contains "$update_output" '未检测到 install-manifest，根目录托管文件将按保守模式跳过'
  assert_text_contains "$update_output" '跳过：AGENTS.md (未标记为 AutoHarness 托管)'
  assert_file_contains "$project/AGENTS.md" '# legacy agents'

  pass "legacy 项目在无 manifest 时按保守模式处理"
}

main() {
  test_install_all_and_clean_uninstall
  test_custom_agents_stays_unmanaged
  test_claude_settings_preserve_custom_hook
  test_legacy_update_is_conservative
  printf '\n🎯 Phase 1 回归测试全部通过\n'
}

main "$@"
