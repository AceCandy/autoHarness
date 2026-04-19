# AutoHarness 工作流指南

> 从需求到交付的完整路径，围绕 7 个主命令和 1 个高级命令展开。

## 总览

```text
需求
  -> /ah-new
  -> /ah-propose
  -> /ah-discuss
  -> /ah-execute
  -> /ah-verify
  -> /ah-ship

需要隔离开发时：
  + /ah-worktree

遇到缺陷时：
  /ah-debug -> /ah-verify -> /ah-ship
```

## 标准功能流程

适合：新功能、重构、较大改动

### 1. `/ah-new`

- 创建 `.autoharness/changes/<name>/source/`
- 统一变更名称为 `<全小写拼音>-YYYYMMDD`
- 保存原始需求来源：
  - 文本/Markdown -> `source/prd.md`
  - 链接 -> `source/prd.md`
  - 文件 -> `source/prd.<ext>`
- 如果当前环境存在 `prd2md` skill，可在这一阶段先转出 `source/prd.md`

### 2. `/ah-propose`

- 读取 `source/prd.md`，或 fallback 到 `source/prd.<ext>`
- 读取 `.autoharness/project.md`
- 按需读取相关 `.autoharness/knowledge/*.md`
- 按需读取相关 `.autoharness/specs/**/spec.md`
- 如果缺少任何 PRD 来源，提示先执行 `/ah-new`
- 生成 `proposal.md`、`design.md`、`tasks.md`、`.autoharness/changes/<name>/specs/`
- 把原始需求提炼成可执行骨架

### 3. `/ah-discuss`

- 澄清需求、边界、输入输出、风险和验收标准
- 对照相关 `knowledge` 与 `specs` 补齐冲突和遗漏
- 吸收原先的探索、计划、UI 讨论等前置工作
- 更新 proposal/design/tasks

### 4. `/ah-execute`

- 读取当前变更上下文并拆成可执行的小步
- 实现前按需复查相关 `knowledge` 与 `specs`
- 直接进入实现
- 需要时自动采用测试优先或小步提交策略
- 更新 `tasks.md` 和状态文件

### 5. `/ah-verify`

- 统一执行代码、测试、构建与必要专项检查
- 把相关 `specs` 与 `knowledge` 作为验收基线之一
- 对 Web 项目可附加浏览器检查
- 对性能敏感项目可附加性能检查
- 给出通过、阻塞项、修复建议

### 6. `/ah-ship`

- 消费 `/ah-verify` 的结果
- 完成提交、推送、PR 或其他交付动作
- 如果交付完成且变更可归档，则准备归档计划并请求确认

## 问题修复流程

适合：测试失败、线上缺陷、回归问题

### 1. `/ah-debug`

- 复现问题
- 缩小范围
- 定位根因
- 做最小修复
- 补回归验证

### 2. `/ah-verify`

- 确认修复有效且没有引入新的问题

### 3. `/ah-ship`

- 需要交付修复时再执行

## 高级流程：本地隔离开发

适合：需要独立分支、避免污染当前目录

### `/ah-worktree`

- 创建独立 worktree 和分支
- 在隔离目录里配合 `/ah-execute` 工作
- 完成后合并、清理 worktree

## 验证与归档

`/ah-verify` 现在是统一验证入口，不再拆成多个主命令。它内部吸收：

- 代码质量检查
- 测试验证
- 构建验证
- 安全基线检查
- 浏览器检查（按需）
- 性能检查（按需）

`/ah-ship` 结束后，如果变更已经完整交付，应进入归档收尾：

1. 检查任务是否完成
2. 准备把 `.autoharness/changes/<name>/specs/` 合并回 `.autoharness/specs/`
3. 准备移动 `.autoharness/changes/<name>/` 到 `.autoharness/changes/archive/`
4. 展示归档计划并请求确认

## 关键原则

1. 一个命令只负责一个阶段
2. 用户决定阶段，不需要决定阶段内的方法论
3. 所有重要状态都落到文件里
4. 验证统一收口，不再分散成多个主命令
