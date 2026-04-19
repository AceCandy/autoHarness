#!/bin/bash

# AutoHarness 更新脚本
# 用法:
#   bash scripts/update.sh                    # 更新当前项目
#   bash scripts/update.sh --target dir       # 更新指定目录
#   bash scripts/update.sh --dry-run          # 预览将更新的内容
#   bash scripts/update.sh --force            # 强制覆盖所有文件

set -e

echo "🔄 AutoHarness 更新程序"
echo "======================"

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

TARGET="."
DRY_RUN=false
FORCE=false
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
    --dry-run)
      DRY_RUN=true
      ;;
    --force|-f)
      FORCE=true
      ;;
    *)
      if [ -d "$arg" ]; then
        TARGET="$arg"
      fi
      ;;
  esac
done

EXPANDED_TARGET=$(eval echo "$TARGET")
if [ "$EXPANDED_TARGET" = "$HOME" ] || [ "$EXPANDED_TARGET" = "/" ]; then
  echo "❌ 不允许在 home 目录或根目录更新"
  exit 1
fi

if [ ! -d "$TARGET" ]; then
  echo "❌ 目标目录不存在：$TARGET"
  exit 1
fi

cd "$TARGET"

if [ ! -d ".autoharness" ] && [ ! -f "AGENTS.md" ] && [ ! -f "CLAUDE.md" ] && [ ! -d ".claude" ] && [ ! -d ".codex" ]; then
  echo "⚠️  未检测到 AutoHarness 安装"
  echo ""
  echo "请先运行安装："
  echo "  bash $SCRIPT_HOME/scripts/install.sh"
  exit 1
fi

echo "目标目录：$TARGET"
echo ""

backup_file() {
  local file="$1"
  if [ -f "$file" ]; then
    BAK_FILE="$file.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$file" "$BAK_FILE"
    echo "  📦 备份：$file -> $BAK_FILE"
  fi
}

remove_file() {
  local file="$1"
  if [ ! -f "$file" ]; then
    return
  fi

  if [ "$DRY_RUN" = true ]; then
    echo "  🗑️  将删除：$file"
  else
    rm -f "$file"
    echo "  ✅ 已删除：$file"
  fi
}

remove_dir() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    return
  fi

  if [ "$DRY_RUN" = true ]; then
    echo "  🗑️  将删除目录：$dir/"
  else
    rm -rf "$dir"
    echo "  ✅ 已删除目录：$dir/"
  fi
}

write_managed_file() {
  local dst="$1"
  local content="$2"
  local tmp

  tmp="$(mktemp)"
  printf '%s\n' "$content" > "$tmp"

  if [ -f "$dst" ] && diff -q "$tmp" "$dst" >/dev/null 2>&1; then
    rm -f "$tmp"
    return
  fi

  if [ "$DRY_RUN" = true ]; then
    echo "  🔄 将更新：$dst"
    rm -f "$tmp"
    return
  fi

  mkdir -p "$(dirname "$dst")"
  if [ -f "$dst" ]; then
    backup_file "$dst"
  fi
  cp "$tmp" "$dst"
  rm -f "$tmp"
  echo "  ✅ 已更新：$dst"
}

update_file() {
  local src="$1"
  local dst="$2"
  local force="${3:-false}"

  if [ ! -f "$src" ]; then
    return
  fi

  local src_abs dst_abs
  src_abs="$(cd "$(dirname "$src")" && pwd)/$(basename "$src")"
  if [ -e "$dst" ]; then
    dst_abs="$(cd "$(dirname "$dst")" && pwd)/$(basename "$dst")"
    if [ "$src_abs" = "$dst_abs" ]; then
      return
    fi
  fi

  if [ ! -f "$dst" ] || [ "$force" = true ] || ! diff -q "$src" "$dst" >/dev/null 2>&1; then
    if [ "$DRY_RUN" = true ]; then
      echo "  🔄 将更新：$dst"
    else
      mkdir -p "$(dirname "$dst")"
      if [ -f "$dst" ]; then
        backup_file "$dst"
      fi
      cp "$src" "$dst"
      echo "  ✅ 已更新：$dst"
    fi
  fi
}

INSTALLED_TOOLS=()
[ -d ".claude" ] && INSTALLED_TOOLS+=("claude")
[ -d ".codex" ] && INSTALLED_TOOLS+=("codex")

echo "检测到已安装的工具：${INSTALLED_TOOLS[*]:-none}"
echo ""

echo "开始更新..."
echo ""

echo "📁 公共文件:"
mkdir -p ".autoharness"
update_file "$AGENTS_TEMPLATE" "AGENTS.md" "$FORCE"
remove_file ".autoharness/AGENTS.md"
remove_dir ".autoharness/config"
remove_dir ".autoharness/rules"
remove_dir ".autoharness/skills"
remove_dir ".autoharness/hooks"
remove_dir ".autoharness/lib"

if [ ! -f ".autoharness/project.md" ]; then
  if [ "$DRY_RUN" = true ]; then
    echo "  📄 将创建：.autoharness/project.md"
  else
    mkdir -p ".autoharness"
    cp "$ASSET_DIR/project.md" ".autoharness/project.md"
    echo "  ✅ 已创建：.autoharness/project.md"
  fi
else
  if [ "$FORCE" = true ]; then
    update_file "$ASSET_DIR/project.md" ".autoharness/project.md" true
  else
    echo "  ⏭️  跳过：.autoharness/project.md (保留用户自定义)"
  fi
fi

mkdir -p .autoharness/changes/archive .autoharness/specs .autoharness/knowledge .autoharness/scripts

for file in "$ASSET_DIR/workspace/"*.md; do
  [ -f "$file" ] || continue
  update_file "$file" ".autoharness/workspace/$(basename "$file")" "$FORCE"
done

for file in "$ASSET_DIR/knowledge/"*.md; do
  [ -f "$file" ] || continue
  if [ ! -f ".autoharness/knowledge/$(basename "$file")" ]; then
    update_file "$file" ".autoharness/knowledge/$(basename "$file")" "$FORCE"
  elif [ "$FORCE" = true ]; then
    update_file "$file" ".autoharness/knowledge/$(basename "$file")" true
  else
    echo "  ⏭️  跳过：.autoharness/knowledge/$(basename "$file") (保留用户自定义)"
  fi
done

remove_file ".autoharness/scripts/install.sh"
remove_file ".autoharness/scripts/update.sh"
remove_file ".autoharness/scripts/init.sh"
remove_file ".autoharness/scripts/uninstall.sh"
update_file "$SCRIPT_SOURCE_DIR/archive-change.sh" ".autoharness/scripts/archive-change.sh" "$FORCE"

for tool in "${INSTALLED_TOOLS[@]}"; do
  echo ""
  case "$tool" in
    claude)
      echo "🔧 Claude Code skills:"
      remove_dir ".claude/rules"
      remove_dir ".claude/lib"
      if [ -d ".claude/skills" ]; then
        find ".claude/skills" -maxdepth 1 -name "ah-*.md" -delete 2>/dev/null || true

        for skill_file in "$ASSET_DIR/skills/ah-"*.md; do
          [ -f "$skill_file" ] || continue
          name=$(basename "$skill_file" .md)
          skill_dir=".claude/skills/$name"
          if [ "$DRY_RUN" = true ]; then
            echo "  🔄 将更新：$skill_dir/SKILL.md"
          else
            mkdir -p "$skill_dir"
            update_file "$skill_file" "$skill_dir/SKILL.md" "$FORCE"
          fi
        done
      fi

      if [ -d ".claude/hooks" ]; then
        for hook in "$ASSET_DIR/hooks/"*.js; do
          [ -f "$hook" ] || continue
          update_file "$hook" ".claude/hooks/$(basename "$hook")" "$FORCE"
        done
      fi
      ;;
    codex)
      echo "🔧 Codex:"
      echo "  ⏭️  使用根目录 AGENTS.md，无额外平台专属目录需要更新"
      ;;
  esac
done

if printf '%s\n' "${INSTALLED_TOOLS[@]}" | grep -qx 'claude'; then
  echo ""
  echo "🔧 Claude Code 入口:"
  write_managed_file "CLAUDE.md" "@AGENTS.md"
fi

echo ""
echo "✅ 更新完成"
echo ""
echo "如需从源码仓库升级到最新版本，请在外部 AutoHarness 源码仓库中执行："
echo "  bash /path/to/autoHarness/scripts/update.sh --target $TARGET"
if [ "$FORCE" = false ]; then
  echo ""
  echo "如需强制覆盖已存在文件："
  echo "  bash /path/to/autoHarness/scripts/update.sh --target $TARGET --force"
fi
