---
name: ah-verify
description: AutoHarness /ah-verify 命令 — 统一验证与放行判断
---

# /ah-verify — 统一验证与放行判断

当用户输入 `/ah-verify <name>` 时执行此技能。

## 工作流程

### 0. 读取验证基线

先读取以下内容：

- `.autoharness/changes/<name>/proposal.md`
- `.autoharness/changes/<name>/tasks.md`
- `.autoharness/project.md`
- `.autoharness/knowledge/business.md`
- `.autoharness/knowledge/rules.md`
- `.autoharness/knowledge/decisions.md`
- 相关 `.autoharness/specs/**/spec.md`

读取原则：

1. 以当前变更最相关的规格和项目知识为基线
2. 不需要为一次验证通读全部规格库
3. 如果规格、知识和实现结论冲突，必须在验证报告中明确指出

### 1. 代码质量检查

- 运行 lint
- 运行 typecheck
- 检查明显风格问题

### 2. 测试验证

- 运行单元测试
- 运行集成测试
- 必要时检查回归场景

### 3. 构建验证

- 确保项目可以构建
- 检查关键构建产物

### 4. 规格与功能验证

- 验证实现符合相关规格与项目知识
- 对照验收标准逐项检查

### 5. 必要专项检查

- 安全基线检查
- Web 项目可加浏览器检查
- 性能敏感项目可加性能检查

### 6. 输出报告

```markdown
# 验证报告

## ✅ 通过
- 检查项 1
- 检查项 2

## ❌ 失败
- 检查项 3: 问题描述

## 下一步
- 进入 /ah-ship
- 或先修复问题后重新验证
```

## 输出

- 验证报告
- 失败项及修复建议
- 如果通过，给出是否可以发布或归档的判断

## 相关 Skills

- `/ah-execute` — 执行任务（前置）
- `/ah-debug` — 遇到阻塞项时先修复
- `/ah-ship` — 发布变更（后置）
