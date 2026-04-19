---
name: ah-propose
description: AutoHarness /ah-propose 命令 — 基于 PRD 来源生成变更提案
---

# /ah-propose — 生成变更提案

当用户输入 `/ah-propose <name>` 时执行此技能。

## 前提

- 变更目录应已存在
- 默认先执行 `/ah-new <name>`
- 目录名统一使用：`<全小写拼音>-YYYYMMDD`

## 工作流程

### 1. 解析变更名称

- 从命令参数提取变更名称
- 格式：`/ah-propose yonghudenglu-20260420`

### 2. 检查输入来源

先检查以下目录：

```text
.autoharness/changes/<name>/
└── source/
    ├── prd.md
    └── prd.<ext>
```

处理顺序：

1. 如果存在 `source/prd.md`
   - 直接读取它，生成 `proposal.md`、`design.md`、`tasks.md`
2. 如果没有 `source/prd.md`，但存在 `source/prd.<ext>`
   - 如果当前环境存在 `prd2md` skill，优先执行转换，生成 `source/prd.md`
   - 如果没有 `prd2md` skill，则直接基于 `source/prd.<ext>` 提炼需求并生成提案文件
3. 如果两者都不存在
   - 不继续生成
   - 提示用户先执行 `/ah-new <name>`

### 3. 补充读取项目基线

在生成提案前，按需读取以下上下文：

- `.autoharness/project.md`
- `.autoharness/knowledge/business.md`
- `.autoharness/knowledge/rules.md`
- `.autoharness/knowledge/decisions.md`
- `.autoharness/specs/**/spec.md`

读取原则：

1. 先根据 `source/prd.md` 或 `source/prd.<ext>` 判断最相关的模块
2. 只读取与当前变更最相关的 `knowledge` 和 `specs`
3. 如果无法判断，再扩展到 1 到 3 个最可能相关的规格文件

### 4. 创建提案文件结构

```text
.autoharness/changes/<name>/
├── source/
│   ├── prd.md
│   └── prd.<ext>
├── proposal.md
├── design.md
├── specs/
└── tasks.md
```

### 5. 初始化 proposal.md

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

### 6. 初始化 design.md

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

### 7. 初始化 tasks.md

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

### 8. 需要补规格时初始化 spec.md

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

- 基于 PRD 来源生成完整的变更骨架
- 提案内容应与相关 `specs`、`knowledge` 保持一致，发现冲突时要在 `design.md` 中显式写出
- 提示下一步先运行 `/ah-discuss <name>`

## 注意事项

- 如果变更目录不存在或没有任何 PRD 来源，提示先执行 `/ah-new`
- 如果 `proposal.md`、`design.md`、`tasks.md` 已存在，优先更新而不是盲目覆盖
- 不需要通读全部 `specs`，只读取相关模块
- 如果发现 PRD 与已有 `specs` 或 `knowledge` 冲突，先在提案里标明冲突点，再进入 `/ah-discuss`

## 相关 Skills

- `/ah-new` — 先保存 PRD 来源
- `/ah-discuss` — 澄清需求、边界和验收标准
- `/ah-execute` — 在需求确认后进入实现
- `/ah-worktree` — 需要隔离开发时创建独立工作目录
