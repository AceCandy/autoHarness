# AutoHarness

> A focused AI coding harness for `Claude Code` and `Codex`.

AutoHarness keeps the public workflow intentionally small. The command set is now:

- `/ah-new`
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

- `.autoharness/` keeps shared workflow assets such as `project.md`, `knowledge/`, `changes/`, `specs/`, `workspace/`, and `scripts/archive-change.sh`
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

## Recommended Manual Setup

After installation, these files should be filled in by a human before starting real work:

- Required: `.autoharness/project.md`
  Fill in project overview, tech stack, run/test/build entrypoints, and architecture boundaries.
- Required: `.autoharness/knowledge/business.md`
  Fill in business background, core entities, key flows, and terminology.
- Required: `.autoharness/knowledge/rules.md`
  Fill in hidden constraints, business rules, boundaries, and compatibility requirements.
- Recommended: `.autoharness/knowledge/decisions.md`
  Fill in confirmed decisions, rationale, and things that should not be changed lightly.

When Claude Code enters the project, the SessionStart hook will remind you if these files still look like templates.

## Natural Language Commands

These are script actions triggered via natural language:

| You say               | Script                                                                        |
| --------------------- | ----------------------------------------------------------------------------- |
| `Install AutoHarness` | `bash /path/to/autoHarness/scripts/install.sh`                                |
| `Update AutoHarness`  | `bash /path/to/autoHarness/scripts/update.sh --target your-project`           |
| `Preview update`      | `bash /path/to/autoHarness/scripts/update.sh --target your-project --dry-run` |
| `Force update`        | `bash /path/to/autoHarness/scripts/update.sh --target your-project --force`   |

## Core Commands

- `/ah-new` — Create a change input skeleton and save the PRD source first.
- `/ah-propose` — Read the PRD source and generate the minimum proposal skeleton.
- `/ah-discuss` — Clarify requirements, scope, edge cases, and acceptance criteria before coding.
- `/ah-execute` — Implement the confirmed plan and move the work forward.
- `/ah-debug` — Reproduce, isolate, and fix defects with regression validation.
- `/ah-verify` — Run unified verification and report pass/fail status with blockers.
- `/ah-ship` — Submit, release, or move verified changes to delivery.
- `/ah-worktree` — Create an isolated worktree and branch for tasks that need separate development context.

## Standard Flows

```text
Feature flow:
/ah-new <name>
-> /ah-propose <name>
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

1. `Input` - PRD source and change input
2. `Knowledge` - project context, business rules, stable specs
3. `Skills` - stage-based workflow commands
4. `Runtime` - hooks, verification, workspace state
5. `Delivery` - implementation, ship, archive

## Repository Layout

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

## Related Docs

- [README_zh.md](./README_zh.md)
- [USAGE.md](./USAGE.md)
- [USAGE_zh.md](./USAGE_zh.md)
- [QUICKREF.md](./QUICKREF.md)
- [WORKFLOW.md](./WORKFLOW.md)

## License

MIT
