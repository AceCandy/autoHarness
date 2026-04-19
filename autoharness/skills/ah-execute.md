---
name: ah-execute
description: AutoHarness /ah-execute 命令 — 执行实现与推进任务
---

# /ah-execute — 执行实现与推进任务

当用户输入 `/ah-execute <name>` 时执行此技能。

## 工作流程

### 1. 读取上下文

打开以下文件：

- `.autoharness/changes/<name>/proposal.md`
- `.autoharness/changes/<name>/design.md`
- `.autoharness/changes/<name>/tasks.md`
- `.autoharness/project.md`

### 2. 生成最小执行顺序

- 把当前任务拆成足够小的实现步
- 先做最关键、最独立的部分
- 高风险逻辑优先补测试或最小验证

### 3. 开始实现

对每个未完成任务：

1. 明确目标
2. 修改代码或配置
3. 运行最相关的本地检查
4. 更新 `tasks.md`

### 4. 处理异常

- 如果遇到阻塞型问题，记录到执行记录
- 如果进入问题定位阶段，切换到 `/ah-debug`

## 输出

- 更新后的 `.autoharness/changes/<name>/tasks.md`
- 已完成项、阻塞项、下一步建议

## 注意事项

- 优先小步修改，而不是一次性大改
- 每次完成一段实现后就留痕
- 不负责最终放行，完成后进入 `/ah-verify`

## 相关 Skills

- `/ah-discuss` — 先澄清再执行
- `/ah-debug` — 遇到问题时切换处理
- `/ah-verify` — 验证质量（后置）
- `/ah-ship` — 发布变更（后置）
