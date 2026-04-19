---
name: ah-worktree
description: AutoHarness /ah-worktree 命令 — Git Worktree 隔离
---

# /ah-worktree — Git Worktree 隔离

当用户输入 `/ah-worktree <name>` 时执行此技能。

## 工作流程

### 1. 检查当前状态

- 查看现有 worktrees
- 检查分支状态

### 2. 创建新 Worktree

```bash
git worktree add -b feature/<name> ../worktree-<name> main
```

### 3. 切换到 Worktree

```bash
cd ../worktree-<name>
```

### 4. 完成后清理

```bash
git worktree remove ../worktree-<name>
git branch -d feature/<name>
```

## 输出

- 新 worktree 路径
- 分支名称
- 后续开发指引

## 注意事项

- 使用 worktree 隔离大改动或高风险改动
- 不要把 worktree 当成默认步骤
- 完成工作后及时合并和清理

## 相关 Skills

- `/ah-propose` — 先创建变更骨架
- `/ah-execute` — 在隔离目录中执行任务
- `/ah-ship` — 完成交付后再清理 worktree
