#!/bin/bash

# AutoHarness 安装脚本
# 用法:
#   bash scripts/install.sh claude                    # 安装到当前目录
#   bash scripts/install.sh codex                     # 安装到当前目录
#   bash scripts/install.sh claude --target dir       # 安装到指定目录
#   bash scripts/install.sh claude codex              # 安装两个支持的平台
#   bash scripts/install.sh all                       # 安装 Claude Code 和 Codex
#   bash scripts/install.sh                           # 自动检测当前 CLI；检测不到时默认安装 claude

set -e

SCRIPT_HOME="$(cd "$(dirname "$0")/.." && pwd)"
ASSET_DIR="$SCRIPT_HOME"
if [ -d "$SCRIPT_HOME/autoharness" ]; then
  ASSET_DIR="$SCRIPT_HOME/autoharness"
fi
SCRIPT_SOURCE_DIR="$SCRIPT_HOME/scripts"
AGENTS_TEMPLATE="$SCRIPT_HOME/AGENTS.md"
if [ ! -f "$AGENTS_TEMPLATE" ] && [ -f "$ASSET_DIR/AGENTS.md" ]; then
  AGENTS_TEMPLATE="$ASSET_DIR/AGENTS.md"
fi

TOOLS=()
TARGET="."
SKIP_NEXT=false

for arg in "$@"; do
  if [ "$SKIP_NEXT" = true ]; then
    TARGET="$arg"
    SKIP_NEXT=false
    continue
  fi
  if [ "$arg" = "--target" ] || [ "$arg" = "-t" ]; then
    SKIP_NEXT=true
    continue
  fi
  case "$arg" in
    --target=*)
      TARGET="${arg#*=}"
      ;;
    -t=*)
      TARGET="${arg#*=}"
      ;;
    claude|codex|all)
      TOOLS+=("$arg")
      ;;
    *)
      if [ -d "$arg" ] || [ "$arg" = "." ]; then
        TARGET="$arg"
      fi
      ;;
  esac
done

if printf '%s\n' "${TOOLS[@]}" | grep -qx 'all'; then
  TOOLS=(claude codex)
fi

if [ ${#TOOLS[@]} -eq 0 ]; then
  if [ -n "$CLAUDE_CODE" ] || [ -n "$CLAUDE_PROJECT_DIR" ] || [ -d ".claude" ]; then
    TOOLS=(claude)
    echo "🔍 检测到 Claude Code 环境"
  elif [ -n "$CODEX" ] || [ -n "$CODEX_PROJECT_DIR" ] || [ -d ".codex" ]; then
    TOOLS=(codex)
    echo "🔍 检测到 Codex 环境"
  else
    TOOLS=(claude)
    echo "🔍 未检测到特定 CLI 环境，默认安装到 claude"
  fi
fi

echo "🚀 AutoHarness 安装程序"
echo "===================="
echo "目标目录: $TARGET"
echo "安装工具: ${TOOLS[*]}"
echo ""

EXPANDED_TARGET=$(eval echo "$TARGET")
if [ "$EXPANDED_TARGET" = "$HOME" ] || [ "$EXPANDED_TARGET" = "/" ] || [ "$EXPANDED_TARGET" = "$HOME/" ]; then
  echo "❌ 不允许安装到 home 目录 ($HOME) 或根目录"
  echo ""
  echo "请在项目目录下运行安装："
  echo "  cd your-project && bash scripts/install.sh claude"
  exit 1
fi

if [ ! -d "$TARGET" ]; then
  echo "❌ 目标目录不存在: $TARGET"
  exit 1
fi

cd "$TARGET"

echo "📁 复制公共文件..."
mkdir -p .autoharness
TARGET_ASSET_DIR="$(cd .autoharness && pwd)"
SOURCE_ASSET_DIR="$(cd "$ASSET_DIR" && pwd)"
ASSET_SELF=false
if [ "$SOURCE_ASSET_DIR" = "$TARGET_ASSET_DIR" ]; then
  ASSET_SELF=true
fi

TARGET_SCRIPT_DIR=""
SOURCE_SCRIPT_DIR=""
if [ -d "$SCRIPT_SOURCE_DIR" ]; then
  mkdir -p ".autoharness/scripts"
  TARGET_SCRIPT_DIR="$(cd .autoharness/scripts && pwd)"
  SOURCE_SCRIPT_DIR="$(cd "$SCRIPT_SOURCE_DIR" && pwd)"
fi

[ ! -f "AGENTS.md" ] && cp "$AGENTS_TEMPLATE" .
[ ! -f ".autoharness/project.md" ] && [ "$ASSET_SELF" = false ] && cp "$ASSET_DIR/project.md" ".autoharness/project.md"
rm -f ".autoharness/AGENTS.md"
rm -rf ".autoharness/rules" ".autoharness/skills" ".autoharness/hooks" ".autoharness/lib"

if [ "$ASSET_SELF" = false ]; then
  for dir in specs changes config workspace; do
    if [ -d "$ASSET_DIR/$dir" ]; then
      cp -rn "$ASSET_DIR/$dir" ".autoharness/" 2>/dev/null || true
    fi
  done
fi

if [ -d "$SCRIPT_SOURCE_DIR" ] && [ "$SOURCE_SCRIPT_DIR" != "$TARGET_SCRIPT_DIR" ]; then
  cp -rn "$SCRIPT_SOURCE_DIR/"* ".autoharness/scripts/" 2>/dev/null || true
fi

mkdir -p .autoharness/changes/archive

for tool in "${TOOLS[@]}"; do
  case "$tool" in
    claude)
      echo ""
      echo "🔧 安装到 Claude Code..."

      mkdir -p .claude/{skills,hooks}
      rm -rf .claude/rules .claude/lib

      if [ -f "CLAUDE.md" ]; then
        BAK_FILE="CLAUDE.md.bak.$(date +%Y%m%d_%H%M%S)"
        cp CLAUDE.md "$BAK_FILE"
        echo "  📦 备份: CLAUDE.md -> $BAK_FILE"
      fi
      printf '%s\n' '@AGENTS.md' > CLAUDE.md
      echo "  ✅ CLAUDE.md 已创建/更新"

      rm -f .claude/skills/*.md 2>/dev/null || true
      rm -rf .claude/skills/ah-* 2>/dev/null || true
      rm -rf .claude/agents 2>/dev/null || true

      for skill_file in "$ASSET_DIR/skills/ah-"*.md; do
        [ -f "$skill_file" ] || continue
        name=$(basename "$skill_file" .md)
        mkdir -p ".claude/skills/$name"
        cp "$skill_file" ".claude/skills/$name/SKILL.md"
        echo "  ✅ command: $name"
      done

      for hook in "$ASSET_DIR/hooks/"*.js; do
        [ -f "$hook" ] || continue
        if [ -f ".claude/hooks/$(basename "$hook")" ]; then
          BAK_FILE=".claude/hooks/$(basename "$hook").bak.$(date +%Y%m%d_%H%M%S)"
          cp ".claude/hooks/$(basename "$hook")" "$BAK_FILE"
          echo "  📦 备份: $(basename "$hook") -> $BAK_FILE"
        fi
        cp "$hook" ".claude/hooks/"
        echo "  ✅ hook: $(basename "$hook")"
      done

      OA_START='{ "matcher": "", "hooks": [{ "type": "command", "command": "node $CLAUDE_PROJECT_DIR/.claude/hooks/session-start.js" }] }'
      OA_END='{ "matcher": "", "hooks": [{ "type": "command", "command": "node $CLAUDE_PROJECT_DIR/.claude/hooks/session-end.js" }] }'
      OA_PRE='{ "matcher": "", "hooks": [{ "type": "command", "command": "node $CLAUDE_PROJECT_DIR/.claude/hooks/pre-tool-use.js" }] }'
      OA_POST='{ "matcher": "", "hooks": [{ "type": "command", "command": "node $CLAUDE_PROJECT_DIR/.claude/hooks/post-tool-use.js" }] }'

      if [ -f ".claude/settings.json" ]; then
        BAK_FILE=".claude/settings.json.bak.$(date +%Y%m%d_%H%M%S)"
        cp .claude/settings.json "$BAK_FILE"
        echo "  📦 备份已保存: $BAK_FILE"

        if command -v jq >/dev/null 2>&1; then
          if jq -e '.hooks.SessionStart[] | select(.hooks[].command | contains("session-start.js"))' "$BAK_FILE" >/dev/null 2>&1; then
            echo "  ✅ AutoHarness hooks 已存在，跳过合并"
          else
            jq \
              --argjson s "$OA_START" \
              --argjson e "$OA_END" \
              --argjson p "$OA_PRE" \
              --argjson o "$OA_POST" \
              '.hooks.SessionStart = (.hooks.SessionStart // []) | .hooks.SessionEnd = (.hooks.SessionEnd // []) | .hooks.PreToolUse = (.hooks.PreToolUse // []) | .hooks.PostToolUse = (.hooks.PostToolUse // []) | .hooks.SessionStart = ([$s] + (.hooks.SessionStart | map(if has("matcher") then . else {matcher:"", hooks: [.]} end))) | .hooks.SessionEnd = ([$e] + (.hooks.SessionEnd | map(if has("matcher") then . else {matcher:"", hooks: [.]} end))) | .hooks.PreToolUse = ([$p] + (.hooks.PreToolUse | map(if has("matcher") then . else {matcher:"", hooks: [.]} end))) | .hooks.PostToolUse = ([$o] + (.hooks.PostToolUse | map(if has("matcher") then . else {matcher:"", hooks: [.]} end)))' \
              "$BAK_FILE" > .claude/settings.json
            echo "  ✅ .claude/settings.json 已更新（AutoHarness hooks 已合并）"
          fi
        else
          echo "  ⚠️  jq 未安装，无法自动合并 hooks。原始配置已备份，请手动处理。"
        fi
      else
        cat > .claude/settings.json << EOF
{
  "hooks": {
    "SessionStart": [$OA_START],
    "SessionEnd": [$OA_END],
    "PreToolUse": [$OA_PRE],
    "PostToolUse": [$OA_POST]
  }
}
EOF
        echo "  ✅ .claude/settings.json 已创建（含 hooks 配置）"
      fi
      ;;

    codex)
      echo ""
      echo "🔧 安装到 Codex..."
      mkdir -p .codex
      [ ! -f "AGENTS.md" ] && cp "$AGENTS_TEMPLATE" .
      echo "  ✅ Codex 安装完成（通过 AGENTS.md 读取指令）"
      ;;

    *)
      echo "⚠️  未知工具：$tool"
      echo "   支持的工具：claude, codex, all"
      ;;
  esac
done

echo ""
echo "✅ AutoHarness 安装与初始化完成!"
echo ""
echo "已安装到: $TARGET"
echo "已启用工具: ${TOOLS[*]}"
echo ""
echo "当前项目结构:"
echo "  - 根目录: AGENTS.md / 可选 CLAUDE.md / .claude / .codex"
echo "  - 内部资产: .autoharness/"
echo ""
echo "下一步:"
echo "  1. 编辑 .autoharness/project.md 填入你的项目信息"
echo "  2. 启动你的 AI 编码工具"
echo "  3. 输入 /ah-propose <name> 开始第一个变更提案"
echo "  4. 然后输入 /ah-discuss <name> 澄清范围和验收标准"
echo ""
