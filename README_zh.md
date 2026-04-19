# AutoHarness

> 一个只面向 `Claude Code` 和 `Codex` 的精简 AI 编码工作流框架。

AutoHarness 现在只公开 8 个命令，其中 7 个是主线命令，1 个是高级命令：

- `/ah-new`
- `/ah-propose`
- `/ah-discuss`
- `/ah-execute`
- `/ah-debug`
- `/ah-verify`
- `/ah-ship`
- `/ah-worktree`（高级）

英文说明见 [README.md](./README.md)。详细使用手册见 [USAGE_zh.md](./USAGE_zh.md) 和 [USAGE.md](./USAGE.md)。

## 快速开始

```bash
# 1. 克隆仓库
git clone https://github.com/AceCandy/autoHarness.git

# 2. 进入你的项目目录
cd your-project

# 3. 安装到当前项目
bash /path/to/autoHarness/scripts/install.sh claude
# 或
bash /path/to/autoHarness/scripts/install.sh codex
# 或同时安装两个平台
bash /path/to/autoHarness/scripts/install.sh all
```

这里的 `all` 仅表示 `Claude Code + Codex`。

## 支持平台

### Claude Code

- 主入口文件：`CLAUDE.md`
- 平台目录：`.claude/`
- 支持 hooks：是

### Codex

- 主入口文件：`AGENTS.md`
- 平台目录：`.codex/`
- 不额外安装平台专属 hooks

## 安装方式

### 仅支持命令安装

```bash
bash scripts/install.sh claude
bash scripts/install.sh codex
bash scripts/install.sh claude codex
bash scripts/install.sh all
```

源码仓库内部资源目录是 `autoharness/`，安装到目标项目后仍然写入 `.autoharness/`。

不再支持手动复制文件安装，只支持通过 `scripts/install.sh` 安装。

安装后的项目目录会按职责拆开：

- `.autoharness/` 只保留共享工作流资产，如 `project.md`、`knowledge/`、`changes/`、`specs/`、`workspace/`、`scripts/archive-change.sh`
- `.claude/` 只保留 Claude 专属运行时资产，如 `skills/`、`hooks/`
- `.codex/` 保持最小化，只配合根目录 `AGENTS.md` 使用

## 安装后检查

```bash
# Claude Code
ls your-project/CLAUDE.md
ls your-project/.claude
ls your-project/.autoharness

# Codex
ls your-project/AGENTS.md
ls your-project/.codex
ls your-project/.autoharness
```

然后重启你实际使用的工具。

## 安装后建议人工填写

开始实际开发前，建议由人先补齐这些文件：

- 必填：`.autoharness/project.md`
  重点填写项目概览、技术栈、启动/测试/构建入口、架构边界。
- 必填：`.autoharness/knowledge/business.md`
  重点填写业务背景、核心实体、关键流程、术语说明。
- 必填：`.autoharness/knowledge/rules.md`
  重点填写隐形条件、业务规则、边界与禁区、兼容性要求。
- 推荐：`.autoharness/knowledge/decisions.md`
  重点填写已经确认的重要决策、原因，以及不要轻易改动的内容。

如果使用 Claude Code，进入项目时 `SessionStart` hook 会自动检查这些文件是否仍是模板占位，并给出中文提醒。

## 自然语言触发的脚本命令

| 你说                  | 实际脚本                                                                      |
| --------------------- | ----------------------------------------------------------------------------- |
| `Install AutoHarness` | `bash /path/to/autoHarness/scripts/install.sh`                                |
| `Update AutoHarness`  | `bash /path/to/autoHarness/scripts/update.sh --target your-project`           |
| `Preview update`      | `bash /path/to/autoHarness/scripts/update.sh --target your-project --dry-run` |
| `Force update`        | `bash /path/to/autoHarness/scripts/update.sh --target your-project --force`   |

## 核心命令

- `/ah-new` — 创建变更输入骨架，并先保存 PRD 来源。
- `/ah-propose` — 读取 PRD 来源并生成最小必要的提案骨架。
- `/ah-discuss` — 在写代码前澄清需求、范围、边界和验收标准。
- `/ah-execute` — 按当前已确认的方案执行实现，并推进任务落地。
- `/ah-debug` — 系统化复现、定位并修复缺陷，同时补齐回归验证。
- `/ah-verify` — 对当前结果做统一验证，给出通过、阻塞项和修复建议。
- `/ah-ship` — 将已验证通过的变更提交、发布或推进到交付阶段。
- `/ah-worktree` — 为需要隔离开发的任务创建独立 worktree 和分支。

## 标准流程

```text
功能开发：
/ah-new <name>
-> /ah-propose <name>
-> /ah-discuss <name>
-> /ah-execute <name>
-> /ah-verify <name>
-> /ah-ship <name>   # 可选

问题修复：
/ah-debug <issue>
-> /ah-verify <name>
-> /ah-ship <name>   # 可选
```

## 架构分层

AutoHarness 保留五层结构：

1. `Input`：PRD 来源与变更输入
2. `Knowledge`：项目上下文、业务规则、稳定规格
3. `Skills`：按阶段划分的工作流命令
4. `Runtime`：hooks、验证与状态留痕
5. `Delivery`：实现、交付与归档

## 目录结构

```text
AGENTS.md
scripts/
autoharness/
  project.md
  knowledge/
  specs/
  changes/
  workspace/
  skills/
  hooks/
```

## 相关文档

- [README.md](./README.md)
- [USAGE.md](./USAGE.md)
- [USAGE_zh.md](./USAGE_zh.md)
- [QUICKREF.md](./QUICKREF.md)
- [WORKFLOW.md](./WORKFLOW.md)

## License

MIT
