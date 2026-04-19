# AutoHarness User Guide

> The current repository supports only `Claude Code` and `Codex`.

## Contents

1. Adopt in an existing project
2. Start a new project
3. Install through your AI assistant
4. Common workflows
5. FAQ

## 1. Adopt in an Existing Project

### Step 1: Clone to a temporary directory

```bash
git clone https://github.com/AceCandy/autoHarness.git /tmp/autoharness
```

### Step 2: Enter your project directory

```bash
cd /path/to/your-project
```

### Step 3: Install

```bash
# Auto-detect Claude Code / Codex environment
bash /tmp/autoharness/scripts/install.sh

# Or specify explicitly
bash /tmp/autoharness/scripts/install.sh claude
bash /tmp/autoharness/scripts/install.sh codex
bash /tmp/autoharness/scripts/install.sh all
```

### Step 4: Verify

```bash
ls -la
```

Core project files installed by AutoHarness:

- `.autoharness/`
- `AGENTS.md`

For Claude Code:

```bash
ls .claude
ls CLAUDE.md
ls .autoharness
```

For Codex:

```bash
ls .codex
ls AGENTS.md
ls .autoharness
```

### Step 5: Fill in `.autoharness/project.md`

Document the tech stack, architecture, domain context, constraints, and conventions.

### Step 6: Restart your tool

```bash
claude
# or
codex
```

### Step 7: Try a command

```text
/ah-propose test-feature
```

## 2. Start a New Project

```bash
mkdir my-new-project
cd my-new-project
git init
git clone https://github.com/AceCandy/autoHarness.git /tmp/autoharness
bash /tmp/autoharness/scripts/install.sh all
```

The install script already performs initialization. Then update:

- `.autoharness/project.md`
- `.autoharness/workspace/STATE.md`
- `.autoharness/workspace/ROADMAP.md`

## 3. Install Through Your AI Assistant

Inside `Claude Code` or `Codex`, you can say:

```text
Please install AutoHarness: https://github.com/AceCandy/autoHarness
```

Or:

```text
Please install AutoHarness to /path/to/my-project
```

Platform-specific requests:

```text
I use Claude Code, please install AutoHarness
```

```text
I use Codex, please install AutoHarness
```

```text
Install AutoHarness for both Claude Code and Codex
```

## 4. Common Workflows

### Feature development

```text
/ah-propose <change-name>
/ah-discuss <change-name>
/ah-execute <change-name>
/ah-verify <change-name>
/ah-ship <change-name>   # optional
```

### Bug fixing

```text
/ah-debug <issue>
/ah-verify <change-name>
/ah-ship <change-name>   # optional
```

### Local isolated development

```text
/ah-worktree <change-name>
```

## 5. FAQ

### Q1: I cannot see `/ah-*` commands after installation

Check the platform files first:

```bash
ls .claude
ls CLAUDE.md
ls .codex
ls AGENTS.md
ls .autoharness
```

Then restart `claude` or `codex`.

### Q2: Do I need to run `init` separately?

No. `install` already includes initialization.

If you run install again:

- it fills in missing AutoHarness assets
- it does not reset project content by default
- use `update` for normal upgrades

### Q3: How do I update?

```bash
git clone https://github.com/AceCandy/autoHarness.git /tmp/autoharness
bash /tmp/autoharness/scripts/update.sh
```

Preview only:

```bash
bash /tmp/autoharness/scripts/update.sh --dry-run
```

### Q4: How do I remove AutoHarness if I really want to?

Usually you do not need a dedicated uninstall command. Remove these items directly:

- `.autoharness/`
- `AGENTS.md`
- `CLAUDE.md`
- `.claude/`
- `.codex/`

This does not remove your product code.

### Q5: Which platforms are supported now?

Only these two:

- `Claude Code`
- `Codex`

### Q6: How do I use AutoHarness in multiple projects?

Install it once per project:

```bash
cd /path/to/project-a
bash /tmp/autoharness/scripts/install.sh claude

cd /path/to/project-b
bash /tmp/autoharness/scripts/install.sh codex
```

### Q7: How do I back up configuration?

```bash
tar -czf autoharness-backup.tar.gz \
  .autoharness \
  AGENTS.md \
  CLAUDE.md
```
