---
name: ah-discuss
description: AutoHarness /ah-discuss 命令 — 需求澄清与范围确认
---

# /ah-discuss — 需求澄清与范围确认

当用户输入 `/ah-discuss <name>` 时执行此技能。

## 目标

- 把模糊想法收敛成可执行的需求
- 明确范围、边界、验收标准和关键取舍
- 为 `/ah-execute` 提供足够清晰的输入

## 工作流程

### 1. 读取变更提案

打开 `.autoharness/changes/<name>/proposal.md`、`.autoharness/changes/<name>/design.md`、`.autoharness/changes/<name>/tasks.md`。

### 2. 澄清 5 类问题

1. 目标：这次改动真正要解决什么问题
2. 范围：做什么，不做什么
3. 边界：输入、输出、异常、兼容性
4. 方案：实现方向、约束、风险
5. 验收：什么算完成，什么算失败

## 状态保存

讨论结束后更新 `.autoharness/changes/<name>/proposal.md`：

```markdown
# 变更提案: <name>

> 创建时间: YYYY-MM-DD
> 更新时间: YYYY-MM-DD
> 状态: 待执行/已确认

## 目标
- ...

## 范围
- 做什么
- 不做什么

## 边界条件
- 输入：...
- 输出：...
- 成功定义：...
- 失败定义：...

## 实现方向
- 方案：...
- 理由：...

## 验收标准
- [ ]
```

## 最终输出

1. 更新后的 `proposal.md`
2. 补充后的 `design.md`
3. 可以开始执行的 `tasks.md`
4. 下一步：`/ah-execute <name>`

## 相关 Skills

- `/ah-propose` — 创建变更提案（前置）
- `/ah-execute` — 在范围确认后开始实现
- `/ah-worktree` — 需要独立目录时先做隔离开发
