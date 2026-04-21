#!/bin/bash

# AutoHarness 卸载脚本
# 用法: 在要卸载的项目根目录执行 bash /path/to/autoHarness/scripts/uninstall.sh [--force]

set -e

MANIFEST_REL=".autoharness/install-manifest.json"
AUTOHARNESS_HOOK_FILES=(
  ".claude/hooks/session-start.js"
  ".claude/hooks/session-end.js"
  ".claude/hooks/pre-tool-use.js"
  ".claude/hooks/post-tool-use.js"
)
AUTOHARNESS_HOOK_COMMANDS=(
  'node $CLAUDE_PROJECT_DIR/.claude/hooks/session-start.js'
  'node $CLAUDE_PROJECT_DIR/.claude/hooks/session-end.js'
  'node $CLAUDE_PROJECT_DIR/.claude/hooks/pre-tool-use.js'
  'node $CLAUDE_PROJECT_DIR/.claude/hooks/post-tool-use.js'
)

echo "🗑️  AutoHarness 卸载程序"
echo "======================"

manifest_list_array() {
  local manifest_path="$1"
  local key="$2"

  [ -f "$manifest_path" ] || return 0

  awk -v key="\"$key\"" '
    $0 ~ key "[[:space:]]*:[[:space:]]*\\[" { in_array=1; next }
    in_array && $0 ~ /^[[:space:]]*]/ { in_array=0; next }
    in_array {
      line=$0
      gsub(/^[[:space:]]*"/, "", line)
      gsub(/",[[:space:]]*$/, "", line)
      gsub(/"[[:space:]]*$/, "", line)
      if (length(line) > 0) print line
    }
  ' "$manifest_path"
}

append_unique() {
  local var_name="$1"
  local value="$2"
  local current item

  eval "current=(\"\${${var_name}[@]}\")"
  for item in "${current[@]}"; do
    if [ "$item" = "$value" ]; then
      return 0
    fi
  done

  eval "${var_name}+=(\"\$value\")"
}

array_contains() {
  local needle="$1"
  shift
  local item

  for item in "$@"; do
    if [ "$item" = "$needle" ]; then
      return 0
    fi
  done

  return 1
}

settings_has_autoharness_hooks() {
  local settings_file="$1"
  local command

  [ -f "$settings_file" ] || return 1

  for command in "${AUTOHARNESS_HOOK_COMMANDS[@]}"; do
    if grep -qF "$command" "$settings_file"; then
      return 0
    fi
  done

  return 1
}

strip_project_claude_hooks() {
  local settings_file="$1"
  local backup_file="$settings_file.bak.$(date +%Y%m%d_%H%M%S)"
  local tmp_file="$settings_file.tmp"

  [ -f "$settings_file" ] || return 0

  if ! command -v jq >/dev/null 2>&1; then
    echo "  ⚠️  jq 未安装，跳过 .claude/settings.json 中的 hook 清理"
    return 0
  fi

  cp "$settings_file" "$backup_file"

  jq '
    def strip_hook(cmd):
      map(
        if (type == "object" and has("hooks")) then
          .hooks = (.hooks | map(select(.command != cmd)))
          | select((.hooks | length) > 0)
        elif (type == "object" and (.command? == cmd)) then
          empty
        else
          .
        end
      );
    .hooks.SessionStart = ((.hooks.SessionStart // []) | strip_hook("node $CLAUDE_PROJECT_DIR/.claude/hooks/session-start.js")) |
    .hooks.SessionEnd = ((.hooks.SessionEnd // []) | strip_hook("node $CLAUDE_PROJECT_DIR/.claude/hooks/session-end.js")) |
    .hooks.PreToolUse = ((.hooks.PreToolUse // []) | strip_hook("node $CLAUDE_PROJECT_DIR/.claude/hooks/pre-tool-use.js")) |
    .hooks.PostToolUse = ((.hooks.PostToolUse // []) | strip_hook("node $CLAUDE_PROJECT_DIR/.claude/hooks/post-tool-use.js")) |
    if (.hooks.SessionStart | length) == 0 then del(.hooks.SessionStart) else . end |
    if (.hooks.SessionEnd | length) == 0 then del(.hooks.SessionEnd) else . end |
    if (.hooks.PreToolUse | length) == 0 then del(.hooks.PreToolUse) else . end |
    if (.hooks.PostToolUse | length) == 0 then del(.hooks.PostToolUse) else . end |
    if ((.hooks // {}) | length) == 0 then del(.hooks) else . end
  ' "$settings_file" > "$tmp_file" && mv "$tmp_file" "$settings_file"

  if cmp -s "$backup_file" "$settings_file"; then
    rm -f "$backup_file"
    echo "  ⏭️  .claude/settings.json 中未发现 AutoHarness hooks"
    return 0
  fi

  if jq -e 'type == "object" and length == 0' "$settings_file" >/dev/null 2>&1; then
    rm -f "$settings_file"
    rm -f "$backup_file"
    echo "  ✅ 删除: .claude/settings.json (仅包含 AutoHarness hooks)"
  else
    echo "  ✅ 已清理: .claude/settings.json 中的 AutoHarness hooks"
    echo "  📦 备份: .claude/settings.json -> $backup_file"
  fi
}

EXPANDED_PWD="$(pwd -P)"
if [ "$EXPANDED_PWD" = "$HOME" ] || [ "$EXPANDED_PWD" = "/" ]; then
  echo "❌ 不允许在 home 目录或根目录卸载"
  exit 1
fi

FORCE=false
if [ "$1" = "--force" ] || [ "$1" = "-f" ]; then
  FORCE=true
fi

echo "目标目录: $PWD"
echo ""

MANIFEST_PATH="$PWD/$MANIFEST_REL"
MANAGED_ROOT_FILES=()
CREATED_DIRS=()
DISPLAY_FILES=()
DISPLAY_DIRS=()
MANIFEST_FOUND=false
LEGACY_MODE=false

if [ -f "$MANIFEST_PATH" ]; then
  MANIFEST_FOUND=true
  while IFS= read -r item; do
    [ -n "$item" ] && append_unique MANAGED_ROOT_FILES "$item"
  done < <(manifest_list_array "$MANIFEST_PATH" "managed_root_files")
  while IFS= read -r item; do
    [ -n "$item" ] && append_unique CREATED_DIRS "$item"
  done < <(manifest_list_array "$MANIFEST_PATH" "created_dirs")
else
  LEGACY_MODE=true
fi

installed=false
if [ "$MANIFEST_FOUND" = true ] || [ -d ".autoharness" ] || [ -d ".claude" ] || [ -d ".codex" ] || [ -f "CLAUDE.md" ] || [ -f "AGENTS.md" ]; then
  installed=true
fi

if [ "$installed" = false ]; then
  echo "⚠️  未检测到 AutoHarness 安装"
  exit 0
fi

if [ "$LEGACY_MODE" = true ]; then
  echo "⚠️  未检测到 install-manifest，将按保守兼容模式卸载"
  echo ""
fi

for file in "${MANAGED_ROOT_FILES[@]}"; do
  [ -f "$file" ] && append_unique DISPLAY_FILES "$file"
done

if [ "$LEGACY_MODE" = true ] && [ -f "CLAUDE.md" ] && [ "$(cat "CLAUDE.md" 2>/dev/null)" = "@AGENTS.md" ]; then
  append_unique DISPLAY_FILES "CLAUDE.md"
fi

for dir in "${CREATED_DIRS[@]}"; do
  [ -d "$dir" ] && append_unique DISPLAY_DIRS "$dir/"
done

for hook_file in "${AUTOHARNESS_HOOK_FILES[@]}"; do
  [ -f "$hook_file" ] && append_unique DISPLAY_FILES "$hook_file"
done

if compgen -G ".claude/skills/ah-*" >/dev/null 2>&1; then
  while IFS= read -r skill_dir; do
    append_unique DISPLAY_DIRS "${skill_dir#./}/"
  done < <(find ".claude/skills" -maxdepth 1 -mindepth 1 -name "ah-*" | sort)
fi

if settings_has_autoharness_hooks ".claude/settings.json"; then
  append_unique DISPLAY_FILES ".claude/settings.json (仅移除 AutoHarness hooks)"
fi

if [ -f "$MANIFEST_REL" ]; then
  append_unique DISPLAY_FILES "$MANIFEST_REL"
fi

if [ "$FORCE" = false ]; then
  echo "将要删除以下文件和目录："
  echo ""
  for file in "${DISPLAY_FILES[@]}"; do
    if [ -f "$file" ]; then
      echo "  📄 $file"
    else
      echo "  📄 $file"
    fi
  done
  for dir in "${DISPLAY_DIRS[@]}"; do
    echo "  📁 $dir"
  done
  echo ""
  read -p "确认卸载? (y/N) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "已取消"
    exit 0
  fi
fi

echo "🗑️  开始卸载..."

for file in "${MANAGED_ROOT_FILES[@]}"; do
  if [ -f "$file" ]; then
    rm -f "$file"
    echo "  ✅ 删除: $file"
  fi
done

if [ "$LEGACY_MODE" = true ] && [ -f "CLAUDE.md" ] && [ "$(cat "CLAUDE.md" 2>/dev/null)" = "@AGENTS.md" ]; then
  rm -f "CLAUDE.md"
  echo "  ✅ 删除: CLAUDE.md"
fi

for hook_file in "${AUTOHARNESS_HOOK_FILES[@]}"; do
  if [ -f "$hook_file" ]; then
    rm -f "$hook_file"
    echo "  ✅ 删除: $hook_file"
  fi
done

if compgen -G ".claude/skills/ah-*" >/dev/null 2>&1; then
  while IFS= read -r skill_dir; do
    rm -rf "$skill_dir"
    echo "  ✅ 删除: ${skill_dir#./}/"
  done < <(find ".claude/skills" -maxdepth 1 -mindepth 1 -name "ah-*" | sort)
fi

if settings_has_autoharness_hooks ".claude/settings.json"; then
  strip_project_claude_hooks ".claude/settings.json"
fi

if [ -f "$MANIFEST_REL" ]; then
  rm -f "$MANIFEST_REL"
  echo "  ✅ 删除: $MANIFEST_REL"
fi

if array_contains ".autoharness" "${CREATED_DIRS[@]}" && [ -d ".autoharness" ]; then
  rm -rf ".autoharness"
  echo "  ✅ 删除: .autoharness/"
fi

if array_contains ".codex" "${CREATED_DIRS[@]}" && [ -d ".codex" ]; then
  rm -rf ".codex"
  echo "  ✅ 删除: .codex/"
fi

rmdir .claude/hooks 2>/dev/null || true
rmdir .claude/skills 2>/dev/null || true
if array_contains ".claude" "${CREATED_DIRS[@]}" && [ -d ".claude" ]; then
  rmdir .claude 2>/dev/null || true
fi

echo ""
echo "✅ AutoHarness 已卸载"
echo ""
echo "注意: 如果需要重新安装，请回到 AutoHarness 源码目录后运行："
echo "  bash scripts/install.sh claude"
