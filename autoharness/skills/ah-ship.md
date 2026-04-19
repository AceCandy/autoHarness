---
name: ah-ship
description: AutoHarness /ah-ship 命令 — 发布变更
---

# /ah-ship — 发布变更

当用户输入 `/ah-ship <name>` 时执行此技能。

## 工作流程

### 1. 检查发布前提

必须确认：

- `/ah-verify` 已通过
- CHANGELOG.md 已更新
- 关键阻塞项已经处理

### 2. Git 操作

```bash
git status
git diff
git add -A
git commit -m "feat: <描述>"
git push origin <branch>
```

### 3. 创建 PR 或执行交付动作

```bash
gh pr create --title "feat: <描述>" --body "..."
```

### 4. 可选部署检查

- 如果项目包含部署流程，在这里执行 smoke check
- 如果只是代码交付，可以跳过

### 5. 归档收尾

- 检查当前变更是否已经完整交付
- 准备归档计划
- 若存在 `.autoharness/scripts/archive-change.sh`，在用户确认后执行：

```bash
bash .autoharness/scripts/archive-change.sh <name>
```

## 输出

- PR 链接或交付结果
- 发布确认
- 验证结果摘要
- 如满足条件，给出归档计划

## 验证失败处理

如果前提不满足，输出阻塞项，并要求先回到 `/ah-verify` 或 `/ah-debug`。

## 相关 Skills

- `/ah-verify` — 验证质量
- `/ah-worktree` — 在独立分支中交付改动
