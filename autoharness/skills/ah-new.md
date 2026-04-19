---
name: ah-new
description: AutoHarness /ah-new 命令 — 创建变更输入骨架并保存 PRD 来源
---

# /ah-new — 创建变更输入骨架

当用户输入 `/ah-new <name>` 时执行此技能。

## 目标

- 先创建变更目录，但暂不生成 `proposal.md`、`design.md`、`tasks.md`
- 先把当前需求来源保存到 `.autoharness/changes/<name>/source/`
- 为后续 `/ah-propose` 准备稳定输入

## 命名规则

- 变更目录名统一使用：`<全小写拼音>-YYYYMMDD`
- 不直接使用中文目录名
- 如果用户给的是中文或没有日期，应先规范化再创建

示例：

```text
/ah-new yonghudenglu-20260420
/ah-new dingdanliebiao-20260420
```

## 工作流程

### 1. 规范化变更名称

- 从命令参数提取名称
- 转成 `<拼音>-YYYYMMDD`
- 如果用户未提供日期，使用当天日期补齐

### 2. 创建目录结构

```text
.autoharness/changes/<name>/
└── source/
```

### 3. 保存需求来源

根据用户提供的输入类型保存：

#### 情况 A：直接给文字或 Markdown

- 保存为 `.autoharness/changes/<name>/source/prd.md`

#### 情况 B：给的是链接

- 保存为 `.autoharness/changes/<name>/source/prd.md`
- 至少记录：
  - 原始链接
  - 页面标题或简要说明
  - 当前能获取到的正文摘要

#### 情况 C：给的是文件，且不是 Markdown

- 保存到 `.autoharness/changes/<name>/source/prd.<ext>`
- 例如：`prd.pdf`、`prd.docx`
- 如果当前环境存在 `prd2md` skill，则优先调用它，把原文件转换成 `source/prd.md`
- 如果没有 `prd2md` skill，则保留原文件，等待 `/ah-propose` 阶段继续处理

#### 情况 D：给的是 Markdown 文件

- 统一保存为 `.autoharness/changes/<name>/source/prd.md`

## 输出

- 已创建的变更目录
- 已保存的 PRD 来源文件
- 规范化后的变更名称
- 下一步：`/ah-propose <name>`

## 注意事项

- `/ah-new` 只负责保存来源，不提前生成提案和任务文件
- 如果变更目录已存在，优先复用并补齐 `source/`
- 如果已有 `source/prd.md`，不要盲目覆盖，除非用户明确要求

## 相关 Skills

- `/ah-propose` — 读取 `source/prd.md` 或 `source/prd.*` 生成提案骨架
- `/ah-discuss` — 在提案生成后继续澄清范围和边界

