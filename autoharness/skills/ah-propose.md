---
name: ah-propose
description: AutoHarness /ah-propose 命令 — 创建变更提案
---

# /ah-propose — 创建变更提案

当用户输入 `/ah-propose <name>` 时执行此技能。

## 工作流程

### 1. 解析变更名称

- 从命令参数提取变更名称
- 格式：`/ah-propose add-user-login`

### 2. 创建变更目录结构

```text
.autoharness/changes/<name>/
├── proposal.md
├── design.md
├── specs/
└── tasks.md
```

### 3. 初始化 proposal.md

```markdown
# 变更提案: <name>

> 创建时间: YYYY-MM-DD

## 目标
- 这次要解决什么问题

## 不做什么
- 明确排除项

## 影响范围
- 影响模块
- 风险点

## 验收标准
- [ ]
```

### 4. 初始化 design.md

```markdown
# 设计方案: <name>

## 当前判断

## 方案草稿

## 待讨论问题
```

### 5. 初始化 tasks.md

```markdown
# 任务清单: <name>

## 待执行
- [ ] 补齐需求边界
- [ ] 明确实现方案
- [ ] 开始执行

## 执行记录
- YYYY-MM-DD: 创建变更骨架
```

## 输出

- 创建完整的变更骨架
- 提示下一步先运行 `/ah-discuss <name>`

## 注意事项

- 如果变更已存在，提示用户并退出
- 使用 `set -e` 确保失败时停止
- 时间使用 ISO 8601 格式 (UTC)

## 相关 Skills

- `/ah-discuss` — 澄清需求、边界和验收标准
- `/ah-execute` — 在需求确认后进入实现
- `/ah-worktree` — 需要隔离开发时创建独立工作目录
