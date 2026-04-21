#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_SCRIPT="$ROOT_DIR/scripts/install.sh"
UPDATE_SCRIPT="$ROOT_DIR/scripts/update.sh"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/autoharness-policy-tests.XXXXXX")"

HOOK_EXIT=0
HOOK_STDOUT=""
HOOK_STDERR=""

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

assert_file_contains() {
  local file="$1"
  local expected="$2"

  grep -Fq -- "$expected" "$file" || fail "文件 $file 未包含: $expected"
}

assert_text_contains() {
  local text="$1"
  local expected="$2"

  printf '%s' "$text" | grep -Fq -- "$expected" || fail "输出未包含: $expected"
}

assert_text_not_contains() {
  local text="$1"
  local unexpected="$2"

  if printf '%s' "$text" | grep -Fq -- "$unexpected"; then
    fail "输出不应包含: $unexpected"
  fi
}

assert_exit_code() {
  local actual="$1"
  local expected="$2"

  [ "$actual" -eq "$expected" ] || fail "退出码不符合预期: 实际 $actual, 期望 $expected"
}

run_hook() {
  local project="$1"
  local payload="$2"
  local stdout_file="$TMP_ROOT/hook.stdout"
  local stderr_file="$TMP_ROOT/hook.stderr"

  set +e
  (
    cd "$project"
    node ".claude/hooks/pre-tool-use.js" "$payload"
  ) >"$stdout_file" 2>"$stderr_file"
  HOOK_EXIT=$?
  set -e

  HOOK_STDOUT="$(cat "$stdout_file" 2>/dev/null || true)"
  HOOK_STDERR="$(cat "$stderr_file" 2>/dev/null || true)"
}

install_claude_project() {
  local project="$1"

  mkdir -p "$project"
  bash "$INSTALL_SCRIPT" claude --target "$project" >/dev/null
}

test_install_creates_policy_and_update_preserves_custom_file() {
  local project="$TMP_ROOT/policy-file"

  mkdir -p "$project"
  bash "$INSTALL_SCRIPT" codex --target "$project" >/dev/null

  assert_file_exists "$project/.autoharness/policy.json"
  assert_file_contains "$project/.autoharness/policy.json" '"hard_block"'

  cat > "$project/.autoharness/policy.json" <<'EOF'
{
  "version": 1,
  "note": "custom-policy",
  "hard_block": [],
  "soft_warn": [],
  "allowlist": [],
  "secret_patterns": []
}
EOF

  bash "$UPDATE_SCRIPT" --target "$project" >/dev/null
  assert_file_contains "$project/.autoharness/policy.json" '"custom-policy"'

  pass "policy.json 会被安装，且 update 默认保留用户自定义内容"
}

test_rm_rf_is_blocked() {
  local project="$TMP_ROOT/block-rm-rf"

  install_claude_project "$project"
  run_hook "$project" '{"tool":"Bash","input":{"command":"rm -rf tmp-dir"}}'

  assert_exit_code "$HOOK_EXIT" 2
  assert_text_contains "$HOOK_STDERR" '策略阻断(bash-rm-rf)'

  pass "rm -rf 会被 hard block"
}

test_git_add_all_is_blocked() {
  local project="$TMP_ROOT/block-git-add"

  install_claude_project "$project"
  run_hook "$project" '{"tool":"Bash","input":{"command":"git add -A"}}'

  assert_exit_code "$HOOK_EXIT" 2
  assert_text_contains "$HOOK_STDERR" '策略阻断(bash-git-add-all)'

  pass "git add -A 会被 hard block"
}

test_no_verify_is_blocked() {
  local project="$TMP_ROOT/block-no-verify"

  install_claude_project "$project"
  run_hook "$project" '{"tool":"Bash","input":{"command":"pnpm test -- --no-verify"}}'

  assert_exit_code "$HOOK_EXIT" 2
  assert_text_contains "$HOOK_STDERR" '策略阻断(bash-no-verify)'

  pass "--no-verify 会被 hard block"
}

test_git_push_force_warns_only() {
  local project="$TMP_ROOT/warn-git-push-force"

  install_claude_project "$project"
  run_hook "$project" '{"tool":"Bash","input":{"command":"git push --force origin main"}}'

  assert_exit_code "$HOOK_EXIT" 0
  assert_text_contains "$HOOK_STDERR" '策略提醒(bash-git-push-force)'

  pass "git push --force 只提醒，不阻断"
}

test_allowlist_can_skip_hard_block() {
  local project="$TMP_ROOT/allowlist"

  install_claude_project "$project"
  cat > "$project/.autoharness/policy.json" <<'EOF'
{
  "version": 1,
  "hard_block": [
    {
      "id": "bash-rm-rf",
      "tool": "Bash",
      "regex": "(^|[;&|\\s])rm\\s+-rf(\\s|$)",
      "message": "检测到 rm -rf。删除目录前必须先获得明确确认。"
    }
  ],
  "soft_warn": [],
  "allowlist": [
    {
      "id": "allow-safe-cleanup",
      "tool": "Bash",
      "regex": "^rm\\s+-rf\\s+tmp-safe-dir$"
    }
  ],
  "secret_patterns": []
}
EOF

  run_hook "$project" '{"tool":"Bash","input":{"command":"rm -rf tmp-safe-dir"}}'

  assert_exit_code "$HOOK_EXIT" 0
  assert_text_not_contains "$HOOK_STDERR" '策略阻断'

  pass "allowlist 命中时会跳过 hard block"
}

main() {
  test_install_creates_policy_and_update_preserves_custom_file
  test_rm_rf_is_blocked
  test_git_add_all_is_blocked
  test_no_verify_is_blocked
  test_git_push_force_warns_only
  test_allowlist_can_skip_hard_block
  printf '\n🎯 Phase 2 policy 测试全部通过\n'
}

main "$@"
