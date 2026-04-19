# AutoHarness 使用手册

> 当前版本只支持 `Claude Code` 和 `Codex`。

## 目录

1. 现有项目接入
2. 新项目初始化
3. 用 AI 助手安装
4. 常用工作流
5. FAQ

## 1. 现有项目接入

### 步骤 1：临时克隆仓库

```bash
git clone https://github.com/vanrayliu/autoharness.git /tmp/autoharness
```

### 步骤 2：进入你的项目目录

```bash
cd /path/to/your-project
```

### 步骤 3：执行安装

```bash
# 自动检测 Claude Code / Codex 环境
bash /tmp/autoharness/scripts/install.sh

# 或显式指定
bash /tmp/autoharness/scripts/install.sh claude
bash /tmp/autoharness/scripts/install.sh codex
bash /tmp/autoharness/scripts/install.sh all
```

### 步骤 4：检查安装结果

```bash
ls -la
```

你至少会看到这些核心文件：

- `.autoharness/`
- `AGENTS.md`

如果安装了 Claude Code，还应该看到：

```bash
ls .claude
ls CLAUDE.md
ls .autoharness
```

如果安装了 Codex，还应该看到：

```bash
ls .codex
ls AGENTS.md
ls .autoharness
```

### 步骤 5：填写项目上下文

编辑 `.autoharness/project.md`，填入技术栈、架构、业务背景、约束和规范。

### 步骤 6：重启工具

```bash
claude
# 或
codex
```

### 步骤 7：测试命令

```text
/ah-propose test-feature
```

## 2. 新项目初始化

```bash
mkdir my-new-project
cd my-new-project
git init
git clone https://github.com/vanrayliu/autoharness.git /tmp/autoharness
bash /tmp/autoharness/scripts/install.sh all
```

安装脚本已经同时完成初始化。安装后建议立刻补全：

- `.autoharness/project.md`
- `.autoharness/workspace/STATE.md`
- `.autoharness/workspace/ROADMAP.md`

## 3. 用 AI 助手安装

如果你已经在 `Claude Code` 或 `Codex` 里工作，可以直接说：

```text
请帮我安装 AutoHarness：https://github.com/vanrayliu/autoharness
```

或者：

```text
请帮我把 AutoHarness 安装到 /path/to/my-project
```

如果你要明确指定平台，可以说：

```text
我是 Claude Code 用户，帮我安装 AutoHarness
```

```text
我是 Codex 用户，帮我安装 AutoHarness
```

```text
同时为 Claude Code 和 Codex 安装 AutoHarness
```

## 4. 常用工作流

### 标准功能开发

```text
/ah-propose <change-name>
/ah-discuss <change-name>
/ah-execute <change-name>
/ah-verify <change-name>
/ah-ship <change-name>   # 可选
```

### 问题修复

```text
/ah-debug <issue>
/ah-verify <change-name>
/ah-ship <change-name>   # 可选
```

### 本地隔离开发

```text
/ah-worktree <change-name>
```

## 5. FAQ

### Q1：安装后看不到 `/ah-*` 命令怎么办？

先检查平台目录和入口文件：

```bash
ls .claude
ls CLAUDE.md
ls .codex
ls AGENTS.md
ls .autoharness
```

然后重启 `claude` 或 `codex`。

### Q2：需要单独跑 `init` 吗？

不需要。`install` 已经接管初始化逻辑。

如果你重复执行安装脚本：

- 会补齐缺失的 AutoHarness 资产
- 不会默认重置你的项目内容
- 后续升级应优先使用 `update`

### Q3：如何更新？

```bash
git clone https://github.com/vanrayliu/autoharness.git /tmp/autoharness
bash /tmp/autoharness/scripts/update.sh
```

预览更新：

```bash
bash /tmp/autoharness/scripts/update.sh --dry-run
```

### Q4：如果我真想移除 AutoHarness 怎么办？

通常不需要专门卸载命令。直接删除这些内容即可：

- `.autoharness/`
- `AGENTS.md`
- `CLAUDE.md`
- `.claude/`
- `.codex/`

不会影响你的业务代码目录。

### Q5：现在支持哪些平台？

只支持两种：

- `Claude Code`
- `Codex`

### Q6：如何在多个项目中使用？

每个项目独立安装一次：

```bash
cd /path/to/project-a
bash /tmp/autoharness/scripts/install.sh claude

cd /path/to/project-b
bash /tmp/autoharness/scripts/install.sh codex
```

### Q7：如何备份？

```bash
tar -czf autoharness-backup.tar.gz \
  .autoharness \
  AGENTS.md \
  CLAUDE.md
```
