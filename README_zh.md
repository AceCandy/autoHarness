# AutoHarness

> 一个只面向 `Claude Code` 和 `Codex` 的精简 AI 编码工作流框架。

AutoHarness 现在只公开 7 个命令，其中 6 个是主线命令，1 个是高级命令：

- `/ah-propose`
- `/ah-discuss`
- `/ah-execute`
- `/ah-debug`
- `/ah-verify`
- `/ah-ship`
- `/ah-worktree`（高级）

英文说明见 [README.md](./README.md)。详细使用手册见 [USAGE.md](./USAGE.md) 和 [USAGE_EN.md](./USAGE_EN.md)。

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

### 推荐脚本安装

```bash
bash scripts/install.sh claude
bash scripts/install.sh codex
bash scripts/install.sh claude codex
bash scripts/install.sh all
```

源码仓库内部资源目录是 `autoharness/`，安装到目标项目后仍然写入 `.autoharness/`。

### Claude Code 手动安装

```bash
cp AGENTS.md your-project/CLAUDE.md
mkdir -p your-project/.autoharness
mkdir -p your-project/.autoharness/scripts
cp AGENTS.md your-project/.autoharness/AGENTS.md
cp -r autoharness/. your-project/.autoharness/
cp -r scripts/. your-project/.autoharness/scripts/
mkdir -p your-project/.claude/{rules,skills,hooks}
cp -r autoharness/rules/. your-project/.claude/rules/
cp autoharness/hooks/*.js your-project/.claude/hooks/
```

### Codex 手动安装

```bash
cp AGENTS.md your-project/
mkdir -p your-project/.autoharness
mkdir -p your-project/.autoharness/scripts
cp AGENTS.md your-project/.autoharness/AGENTS.md
cp -r autoharness/. your-project/.autoharness/
cp -r scripts/. your-project/.autoharness/scripts/
mkdir -p your-project/.codex
```

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

## 自然语言触发的脚本命令

| 你说 | 实际脚本 |
|---|---|
| `Install AutoHarness` | `bash .autoharness/scripts/install.sh` |
| `Update AutoHarness` | `bash .autoharness/scripts/update.sh` |
| `Preview update` | `bash .autoharness/scripts/update.sh --dry-run` |
| `Force update` | `bash .autoharness/scripts/update.sh --force` |

## 核心命令

- `/ah-propose` — 创建一个新的变更提案，并生成最小必要的规格骨架。
- `/ah-discuss` — 在写代码前澄清需求、范围、边界和验收标准。
- `/ah-execute` — 按当前已确认的方案执行实现，并推进任务落地。
- `/ah-debug` — 系统化复现、定位并修复缺陷，同时补齐回归验证。
- `/ah-verify` — 对当前结果做统一验证，给出通过、阻塞项和修复建议。
- `/ah-ship` — 将已验证通过的变更提交、发布或推进到交付阶段。
- `/ah-worktree` — 为需要隔离开发的任务创建独立 worktree 和分支。

## 标准流程

```text
功能开发：
/ah-propose <name>
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

1. `Spec`：需求与变更规格
2. `Skills`：按阶段划分的工作流命令
3. `Enhancement`：规则、hooks、验证、记忆
4. `Execution`：实现与交付流程
5. `Workspace`：文件化项目记忆

## 目录结构

```text
AGENTS.md
scripts/
autoharness/
  project.md
  specs/
  changes/
  config/
  workspace/
  templates/
  rules/
  skills/
  hooks/
  lib/
```

## 相关文档

- [README.md](./README.md)
- [USAGE.md](./USAGE.md)
- [USAGE_EN.md](./USAGE_EN.md)
- [QUICKREF.md](./QUICKREF.md)
- [WORKFLOW.md](./WORKFLOW.md)

## License

MIT
