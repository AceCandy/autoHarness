#!/bin/bash

# AutoHarness 初始化脚本（兼容入口）
# init 已并入 install，保留此脚本仅用于兼容旧用法

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "ℹ️  init 已并入 install，正在转交给 install.sh"
exec bash "$SCRIPT_DIR/install.sh" "$@"
