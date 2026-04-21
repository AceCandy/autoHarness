#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_SCRIPT="$ROOT_DIR/scripts/install.sh"
STATE_SOURCE_SCRIPT="$ROOT_DIR/scripts/state.js"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/autoharness-state-tests.XXXXXX")"

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

test_install_copies_state_script() {
  local project="$TMP_ROOT/install-state-script"

  mkdir -p "$project"
  bash "$INSTALL_SCRIPT" codex --target "$project" >/dev/null

  assert_file_exists "$project/.autoharness/scripts/state.js"
  cmp -s "$STATE_SOURCE_SCRIPT" "$project/.autoharness/scripts/state.js" || fail "安装后的 state.js 与源码不一致"

  pass "安装会把 state.js 带进 .autoharness/scripts/"
}

test_set_command_updates_state_file() {
  local project="$TMP_ROOT/set-command"
  local state_file="$project/.autoharness/workspace/STATE.md"

  mkdir -p "$project"
  bash "$INSTALL_SCRIPT" codex --target "$project" >/dev/null

  (
    cd "$project"
    node ".autoharness/scripts/state.js" set \
      --task "订单页埋点改造" \
      --phase execute \
      --progress "已完成接口梳理" \
      --pending "等待产品确认字段"
  )

  assert_file_contains "$state_file" '## 当前任务'
  assert_file_contains "$state_file" '- 订单页埋点改造'
  assert_file_contains "$state_file" '## 当前阶段'
  assert_file_contains "$state_file" 'execute'
  assert_file_contains "$state_file" '- 已完成接口梳理'
  assert_file_contains "$state_file" '- 等待产品确认字段'

  pass "set 命令会覆盖写入 STATE.md"
}

test_append_and_clear_commands() {
  local project="$TMP_ROOT/append-clear"
  local state_file="$project/.autoharness/workspace/STATE.md"
  local shown=""

  mkdir -p "$project"
  bash "$INSTALL_SCRIPT" codex --target "$project" >/dev/null

  (
    cd "$project"
    node ".autoharness/scripts/state.js" set --task "登录页联调" --phase discuss >/dev/null
    node ".autoharness/scripts/state.js" append-progress --value "已确认接口字段" >/dev/null
    node ".autoharness/scripts/state.js" append-progress --value "已确认接口字段" >/dev/null
    node ".autoharness/scripts/state.js" append-pending --value "确认错误码文案" >/dev/null
    node ".autoharness/scripts/state.js" clear-pending >/dev/null
    shown="$(node ".autoharness/scripts/state.js" show)"
    printf '%s' "$shown" > "$project/show.txt"
  )

  assert_file_contains "$state_file" '- 已确认接口字段'
  count="$(grep -Fc -- '- 已确认接口字段' "$state_file")"
  [ "$count" -eq 1 ] || fail "append-progress 不应重复追加相同行"
  assert_file_contains "$state_file" '## 待确认事项'
  assert_file_contains "$state_file" '- 无'
  assert_text_contains "$(cat "$project/show.txt")" '登录页联调'
  assert_text_contains "$(cat "$project/show.txt")" 'discuss'

  pass "append/show/clear 命令会按预期更新 STATE.md"
}

test_invalid_phase_fails() {
  local project="$TMP_ROOT/invalid-phase"
  local output=""

  mkdir -p "$project"
  bash "$INSTALL_SCRIPT" codex --target "$project" >/dev/null

  set +e
  output="$(
    cd "$project" &&
    node ".autoharness/scripts/state.js" set-phase --value draft 2>&1
  )"
  status=$?
  set -e

  [ "$status" -eq 1 ] || fail "无效阶段应返回退出码 1"
  assert_text_contains "$output" '无效阶段: draft'

  pass "无效阶段会被明确拒绝"
}

main() {
  test_install_copies_state_script
  test_set_command_updates_state_file
  test_append_and_clear_commands
  test_invalid_phase_fails
  printf '\n🎯 Phase 3 state 测试全部通过\n'
}

main "$@"
