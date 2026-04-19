# AutoHarness

> A focused AI coding harness for `Claude Code` and `Codex`.

AutoHarness keeps the public workflow intentionally small. The command set is now:

- `/ah-propose`
- `/ah-discuss`
- `/ah-execute`
- `/ah-debug`
- `/ah-verify`
- `/ah-ship`
- `/ah-worktree` (advanced)

If you want the Chinese guide, see [README_zh.md](./README_zh.md).
For step-by-step usage, see [USAGE.md](./USAGE.md) and [USAGE_EN.md](./USAGE_EN.md).

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/AceCandy/autoHarness.git

# 2. Go to your project directory
cd your-project

# 3. Install AutoHarness into the current project
bash /path/to/autoHarness/scripts/install.sh claude
# or
bash /path/to/autoHarness/scripts/install.sh codex
# or install both
bash /path/to/autoHarness/scripts/install.sh all
```

`all` means `Claude Code + Codex`.

## Supported Platforms

### Claude Code

- Main entry file: `CLAUDE.md`
- Tool directory: `.claude/`
- Hooks supported: yes

### Codex

- Main entry file: `AGENTS.md`
- Tool directory: `.codex/`
- Hooks supported: no platform-specific hook installation

## Installation

### Recommended

```bash
bash scripts/install.sh claude
bash scripts/install.sh codex
bash scripts/install.sh claude codex
bash scripts/install.sh all
```

Source assets live in `autoharness/`. Installed project assets still go into `.autoharness/`.

### Manual Install for Claude Code

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

### Manual Install for Codex

```bash
cp AGENTS.md your-project/
mkdir -p your-project/.autoharness
mkdir -p your-project/.autoharness/scripts
cp AGENTS.md your-project/.autoharness/AGENTS.md
cp -r autoharness/. your-project/.autoharness/
cp -r scripts/. your-project/.autoharness/scripts/
mkdir -p your-project/.codex
```

## Verification

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

Then restart the tool you use.

## Natural Language Commands

These are script actions triggered via natural language:

| You say | Script |
|---|---|
| `Install AutoHarness` | `bash .autoharness/scripts/install.sh` |
| `Update AutoHarness` | `bash .autoharness/scripts/update.sh` |
| `Preview update` | `bash .autoharness/scripts/update.sh --dry-run` |
| `Force update` | `bash .autoharness/scripts/update.sh --force` |

## Core Commands

- `/ah-propose` — Create a new change proposal and generate the minimum spec skeleton.
- `/ah-discuss` — Clarify requirements, scope, edge cases, and acceptance criteria before coding.
- `/ah-execute` — Implement the confirmed plan and move the work forward.
- `/ah-debug` — Reproduce, isolate, and fix defects with regression validation.
- `/ah-verify` — Run unified verification and report pass/fail status with blockers.
- `/ah-ship` — Submit, release, or move verified changes to delivery.
- `/ah-worktree` — Create an isolated worktree and branch for tasks that need separate development context.

## Standard Flows

```text
Feature flow:
/ah-propose <name>
-> /ah-discuss <name>
-> /ah-execute <name>
-> /ah-verify <name>
-> /ah-ship <name>   # optional

Bug fix flow:
/ah-debug <issue>
-> /ah-verify <name>
-> /ah-ship <name>   # optional
```

## Architecture

AutoHarness keeps the same five-layer structure:

1. `Spec` - requirements and change specs
2. `Skills` - stage-based workflow commands
3. `Enhancement` - rules, hooks, verification, memory
4. `Execution` - implementation and delivery flow
5. `Workspace` - file-based project memory

## Repository Layout

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

## Related Docs

- [README_zh.md](./README_zh.md)
- [USAGE.md](./USAGE.md)
- [USAGE_EN.md](./USAGE_EN.md)
- [QUICKREF.md](./QUICKREF.md)
- [WORKFLOW.md](./WORKFLOW.md)

## License

MIT
