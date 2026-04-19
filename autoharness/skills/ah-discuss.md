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

如果存在 `.autoharness/changes/<name>/source/prd.md`，也一起读取，用于回看原始需求。

再按需读取：

- `.autoharness/project.md`
- `.autoharness/knowledge/business.md`
- `.autoharness/knowledge/rules.md`
- `.autoharness/knowledge/decisions.md`
- `.autoharness/specs/**/spec.md`

读取原则：

1. 只读取与当前变更直接相关的知识和规格
2. 如果提案里已经标出冲突点，优先围绕这些冲突补齐范围和验收
3. 不需要在 discuss 阶段通读全部规格库

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

## 讨论重点

- 如果 PRD、项目知识和现有规格不一致，必须在 `proposal.md` 或 `design.md` 里写明最终结论
- 如果需要修改长期规格，记录到 `.autoharness/changes/<name>/specs/`

## 相关 Skills

- `/ah-new` — 先保存 PRD 来源（前置）
- `/ah-propose` — 创建变更提案（前置）
- `/ah-execute` — 在范围确认后开始实现
- `/ah-worktree` — 需要独立目录时先做隔离开发
