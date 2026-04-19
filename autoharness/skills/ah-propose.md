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
# 提案: <change-name>

## 目标
<!-- 要解决什么问题，为什么现在做 -->

## 不做什么
<!-- 明确这次不包含的内容 -->

## 影响范围
<!-- 会改到哪些模块、接口、数据或流程 -->

## 验收标准
<!-- 用可验证结果描述成功 -->
```

### 4. 初始化 design.md

```markdown
# 设计: <change-name>

## 当前判断
<!-- 当前准备采用什么实现方向 -->

## 方案草稿
<!-- 先写最小可行方案，不要过度展开 -->

## 关键决策

### 决策 1
- 选择:
- 原因:
- 备选:

## 数据与接口
<!-- 只写本次变更真正涉及的部分 -->

## 风险与回滚
- 风险:
- 兜底:
```

### 5. 初始化 tasks.md

```markdown
# 任务清单: <change-name>

> 只保留可执行、可验证、可勾选的任务。

## Discuss
- [ ] 补齐目标、范围、边界和验收标准

## Execute
- [ ] 任务 1: <任务描述>
  文件: <涉及文件>
  验证: <如何确认完成>

- [ ] 任务 2: <任务描述>
  文件: <涉及文件>
  验证: <如何确认完成>

## Verify
- [ ] 运行测试
- [ ] 运行构建
- [ ] 检查验收标准

## Ship
- [ ] 更新文档或 CHANGELOG
- [ ] 准备交付说明
```

### 6. 需要补规格时初始化 spec.md

```markdown
# <模块名> 规格

## ADDED Requirements

### Requirement: <需求名>
系统 MUST/SHALL/SHOULD/MAY <行为描述>

#### Scenario: <场景名>
- GIVEN <前置条件>
- WHEN <触发动作>
- THEN <预期结果>
- AND <附加结果>

---

## MODIFIED Requirements

### Requirement: <需求名>
<新描述>
原描述: <旧描述>

---

## REMOVED Requirements

### Requirement: <需求名>
原因: <说明>
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
