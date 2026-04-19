# AutoHarness 快速参考卡

> 一页纸记住当前只保留的 7 个命令。

## 命令速查 (7 个)

| 命令 | 类型 | 用途 |
|------|------|------|
| `/ah-propose <name>` | 主命令 | 创建变更提案，并生成最小规格骨架 |
| `/ah-discuss <name>` | 主命令 | 澄清需求、范围、边界和验收标准 |
| `/ah-execute <name>` | 主命令 | 执行实现、推进任务、更新状态 |
| `/ah-debug <issue>` | 主命令 | 复现、定位并修复缺陷，补齐回归验证 |
| `/ah-verify <name>` | 主命令 | 统一做代码、测试、构建和必要专项检查 |
| `/ah-ship <name>` | 主命令 | 提交、发布或推进到交付阶段 |
| `/ah-worktree <name>` | 高级命令 | 创建独立 worktree 和分支做隔离开发 |

## 标准流程

```text
功能开发：
/ah-propose -> /ah-discuss -> /ah-execute -> /ah-verify -> /ah-ship

问题修复：
/ah-debug -> /ah-verify -> /ah-ship

隔离开发：
/ah-worktree -> /ah-execute
```

## 关键文件

| 文件 | 用途 |
|------|------|
| `.autoharness/project.md` | 项目最小上下文 |
| `.autoharness/changes/<name>/proposal.md` | 变更目标、范围和验收标准 |
| `.autoharness/changes/<name>/design.md` | 设计方案和关键取舍 |
| `.autoharness/changes/<name>/tasks.md` | 执行清单和进度记录 |
| `.autoharness/workspace/STATE.md` | 当前状态 |
| `.autoharness/workspace/ROADMAP.md` | 路线图 |
| `.autoharness/config/settings.json` | 全局配置 |
| `.autoharness/config/memory.json` | 项目记忆 |

## 验证口径

`/ah-verify` 统一吸收以下检查：

- 代码质量
- 测试验证
- 构建验证
- 安全基线
- 浏览器检查（仅 Web 项目）
- 性能检查（仅性能敏感项目）

## 黄金法则

1. **规格先行** — 没对齐需求，不开始写代码
2. **阶段单一** — 一个命令只负责一个阶段
3. **验证统一** — 不再分散跑多个检查命令
4. **文件留痕** — 重要状态和决策都落到文件里
