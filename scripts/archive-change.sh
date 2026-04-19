#!/bin/bash

# 变更归档脚本
# 将已完成的变更合并到主规格并归档

set -e

SCRIPT_HOME="$(cd "$(dirname "$0")/.." && pwd)"
ASSET_DIR="$SCRIPT_HOME"
if [ -d "$SCRIPT_HOME/autoharness" ]; then
  ASSET_DIR="$SCRIPT_HOME/autoharness"
fi

CHANGE_NAME="${1:-}"
CHANGES_DIR="${2:-$ASSET_DIR/changes}"
SPECS_DIR="${3:-$ASSET_DIR/specs}"

if [ -z "$CHANGE_NAME" ]; then
  echo "用法: $0 <change-name> [changes-dir] [specs-dir]"
  exit 1
fi

CHANGE_DIR="$CHANGES_DIR/$CHANGE_NAME"
ARCHIVE_DIR="$CHANGES_DIR/archive/$(date +%Y-%m-%d)-$CHANGE_NAME"

if [ ! -d "$CHANGE_DIR" ]; then
  echo "❌ 变更目录不存在: $CHANGE_DIR"
  exit 1
fi

echo "📦 归档变更: $CHANGE_NAME"
echo "---"

merge_section() {
  local spec_file="$1"
  local target_file="$2"
  local section_name="$3"

  if ! grep -qE "^#{1,6} ${section_name} Requirements" "$spec_file"; then
    return
  fi

  echo "  ➕ 合并 ${section_name}: ${spec_file#$CHANGE_DIR/specs/}"

  local existing_reqs
  existing_reqs=$(awk '/^#{1,6} Requirement:/ {
    gsub(/^#{1,6} +/, "");
    print;
    found=1
  }
  /^#{1,6} [^R]/{ found=0 }
  /^#{1,6} Requirement:/{ if (found) next }
  found { sub(/^#{1,6} +/, ""); print }
  ' "$target_file" 2>/dev/null || true)

  local section_content
  section_content=$(awk -v sect="${section_name}" '
    BEGIN { capturing=0 }
    $0 ~ "^#{1,6} " sect " Requirements" {
      capturing=1;
      next;
    }
    capturing && $0 ~ "^#{1,6} (ADDED|MODIFIED|REMOVED) Requirements" {
      capturing=0;
      next;
    }
    capturing {
      print;
    }
  ' "$spec_file")

  local in_block=0
  local block_name=""
  local block_lines=""

  while IFS= read -r line; do
    if echo "$line" | grep -qE '^#{1,6} Requirement:'; then
      if [ -n "$block_lines" ]; then
        printf '%s\n' "$block_lines" >> "$target_file"
      fi

      block_name=$(echo "$line" | sed -E 's/^#{1,6} +Requirement: +/Requirement: /')

      if echo "$existing_reqs" | grep -qF -- "$block_name"; then
        block_lines=""
        in_block=0
      else
        block_lines="## ${block_name}"
        in_block=1
        existing_reqs="${existing_reqs}${block_name}"$'\n'
      fi
    elif [ $in_block -eq 1 ]; then
      block_lines="${block_lines}"$'\n'"$line"
    fi
  done <<< "$section_content"

  if [ -n "$block_lines" ]; then
    printf '%s\n' "$block_lines" >> "$target_file"
  fi
}

if [ -d "$CHANGE_DIR/specs" ]; then
  echo "📝 合并增量规格..."
  while IFS= read -r spec_file; do
    REL_PATH="${spec_file#$CHANGE_DIR/specs/}"
    REL_PATH="${REL_PATH%/spec.md}"
    TARGET_SPEC="$SPECS_DIR/$REL_PATH/spec.md"

    mkdir -p "$(dirname "$TARGET_SPEC")"
    [ -f "$TARGET_SPEC" ] || touch "$TARGET_SPEC"

    merge_section "$spec_file" "$TARGET_SPEC" "ADDED"
    merge_section "$spec_file" "$TARGET_SPEC" "MODIFIED"
    merge_section "$spec_file" "$TARGET_SPEC" "REMOVED"
  done < <(find "$CHANGE_DIR/specs" -name "spec.md")
fi

echo "📁 移动到归档..."
mkdir -p "$ARCHIVE_DIR"
mv "$CHANGE_DIR"/* "$ARCHIVE_DIR/" 2>/dev/null || true
rmdir "$CHANGE_DIR" 2>/dev/null || true

echo "---"
echo "✅ 变更已归档到: $ARCHIVE_DIR"
