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
For step-by-step usage, see [USAGE.md](./USAGE.md) and [USAGE_zh.md](./USAGE_zh.md).

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

### Command Install Only

```bash
bash scripts/install.sh claude
bash scripts/install.sh codex
bash scripts/install.sh claude codex
bash scripts/install.sh all
```

Source assets live in `autoharness/`. Installed project assets still go into `.autoharness/`.

Manual file copying is no longer supported. Install only through `scripts/install.sh`.

Installed project layout is intentionally split:

- `.autoharness/` keeps shared workflow assets such as `project.md`, `changes/`, `specs/`, `config/`, `workspace/`, and `scripts/`
- `.claude/` keeps Claude-only runtime assets such as `skills/` and `hooks/`
- `.codex/` stays minimal and uses root `AGENTS.md`

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

| You say               | Script                                                                        |
| --------------------- | ----------------------------------------------------------------------------- |
| `Install AutoHarness` | `bash /path/to/autoHarness/scripts/install.sh`                                |
| `Update AutoHarness`  | `bash /path/to/autoHarness/scripts/update.sh --target your-project`           |
| `Preview update`      | `bash /path/to/autoHarness/scripts/update.sh --target your-project --dry-run` |
| `Force update`        | `bash /path/to/autoHarness/scripts/update.sh --target your-project --force`   |

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
3. `Enhancement` - hooks, verification, memory
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
  skills/
  hooks/
```

## Related Docs

- [README_zh.md](./README_zh.md)
- [USAGE.md](./USAGE.md)
- [USAGE_zh.md](./USAGE_zh.md)
- [QUICKREF.md](./QUICKREF.md)
- [WORKFLOW.md](./WORKFLOW.md)

## License

MIT
