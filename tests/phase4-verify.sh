#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_SCRIPT="$ROOT_DIR/scripts/install.sh"
VERIFY_SOURCE_SCRIPT="$ROOT_DIR/scripts/verify.js"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/autoharness-verify-tests.XXXXXX")"

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

write_project_config() {
  local project="$1"
  local body="$2"

  cat > "$project/.autoharness/project.md" <<EOF
# 项目上下文

## 运行与验证入口

$body
EOF
}

test_install_copies_verify_script() {
  local project="$TMP_ROOT/install-verify-script"

  mkdir -p "$project"
  bash "$INSTALL_SCRIPT" codex --target "$project" >/dev/null

  assert_file_exists "$project/.autoharness/scripts/verify.js"
  cmp -s "$VERIFY_SOURCE_SCRIPT" "$project/.autoharness/scripts/verify.js" || fail "安装后的 verify.js 与源码不一致"

  pass "安装会把 verify.js 带进 .autoharness/scripts/"
}

test_verify_fails_when_no_commands_configured() {
  local project="$TMP_ROOT/no-commands"
  local report="$project/.autoharness/workspace/verify-report.md"
  local output=""
  local status=0

  mkdir -p "$project"
  bash "$INSTALL_SCRIPT" codex --target "$project" >/dev/null

  set +e
  output="$(
    cd "$project" &&
    node ".autoharness/scripts/verify.js" 2>&1
  )"
  status=$?
  set -e

  [ "$status" -eq 1 ] || fail "未配置任何验证命令时应返回退出码 1"
  assert_file_exists "$report"
  assert_file_contains "$report" 'project.md 中未配置任何验证命令'
  assert_text_contains "$(cat "$report")" '## ❌ 失败'
  [ -z "$output" ] || fail "verify.js 失败时不应额外输出未处理错误"

  pass "未配置验证命令时会生成失败报告"
}

test_verify_success_writes_change_report_and_state() {
  local project="$TMP_ROOT/verify-success"
  local change_name="denglu-20260420"
  local report="$project/.autoharness/changes/$change_name/verify-report.md"
  local state_file="$project/.autoharness/workspace/STATE.md"

  mkdir -p "$project/.autoharness/changes/$change_name"
  bash "$INSTALL_SCRIPT" codex --target "$project" >/dev/null

  write_project_config "$project" $'- 测试命令: node -e "console.log(\'test ok\')"\n- 构建命令: node -e "console.log(\'build ok\')"'

  (
    cd "$project"
    node ".autoharness/scripts/verify.js" "$change_name"
  )

  assert_file_exists "$report"
  assert_file_contains "$report" "# 验证报告: $change_name"
  assert_file_contains "$report" "- 测试: \`node -e \"console.log('test ok')\"\`"
  assert_file_contains "$report" "- 构建: \`node -e \"console.log('build ok')\"\`"
  assert_file_contains "$report" "- Lint: 未配置 Lint 命令"
  assert_file_contains "$state_file" '## 当前阶段'
  assert_file_contains "$state_file" 'verify'
  assert_file_contains "$state_file" '验证通过: 2 项, 跳过 2 项'

  pass "验证成功时会写 change 级报告并更新 STATE.md"
}

test_verify_failure_records_failed_command() {
  local project="$TMP_ROOT/verify-failure"
  local report="$project/.autoharness/workspace/verify-report.md"
  local status=0

  mkdir -p "$project"
  bash "$INSTALL_SCRIPT" codex --target "$project" >/dev/null

  write_project_config "$project" $'- Lint 命令: node -e "console.log(\'lint ok\')"\n- 测试命令: node -e "console.error(\'test fail\'); process.exit(3)"\n- 构建命令: node -e "console.log(\'build ok\')"'

  set +e
  (
    cd "$project"
    node ".autoharness/scripts/verify.js"
  )
  status=$?
  set -e

  [ "$status" -eq 1 ] || fail "验证失败时应返回退出码 1"
  assert_file_exists "$report"
  assert_file_contains "$report" "- Lint: \`node -e \"console.log('lint ok')\"\`"
  assert_file_contains "$report" "- 测试: \`node -e \"console.error('test fail'); process.exit(3)\"\`"
  assert_file_contains "$report" '- 退出码: 3'
  assert_file_contains "$report" "- 构建: \`node -e \"console.log('build ok')\"\`"
  assert_file_contains "$report" '- test fail'
  assert_file_contains "$project/.autoharness/workspace/STATE.md" '验证失败: 1 项, 通过 2 项'

  pass "验证失败时会记录失败命令和输出摘要"
}

main() {
  test_install_copies_verify_script
  test_verify_fails_when_no_commands_configured
  test_verify_success_writes_change_report_and_state
  test_verify_failure_records_failed_command
  printf '\n🎯 Phase 4 verify 测试全部通过\n'
}

main "$@"
