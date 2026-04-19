# AutoHarness — Unified AI Coding Harness

> A focused, stage-based engineering framework combining OpenSpec, Superpowers, GSD, ECC, and Trellis.

## Architecture

AutoHarness uses a layered design where each layer can be enabled independently:

```text
┌─────────────────────────────────────────────────┐
│  Layer 5: Workspace  — Project Memory           │
├─────────────────────────────────────────────────┤
│  Layer 4: Execution — Delivery Flow             │
├─────────────────────────────────────────────────┤
│  Layer 3: Enhancement — Rules / Hooks / Verify  │
├─────────────────────────────────────────────────┤
│  Layer 2: Skills — Stage Commands               │
├─────────────────────────────────────────────────┤
│  Layer 1: Spec — Spec-Driven Development        │
└─────────────────────────────────────────────────┘
```

## Core Principles

1. **Spec First** — Align on requirements before writing code
2. **Stage Clarity** — Each command owns one stage of the workflow
3. **Context Hygiene** — Keep tasks small and information structured
4. **Unified Verification** — Run one verification gate instead of many scattered checks
5. **Project Memory** — Persist important decisions in files

## Installation

### Quick Install

```bash
git clone https://github.com/AceCandy/autoHarness.git
cd autoHarness
bash scripts/install.sh claude
bash scripts/install.sh codex
bash scripts/install.sh all
```

Source assets live in `autoharness/`. Installed project assets still go into `.autoharness/`.

### Claude Code

```bash
cp AGENTS.md your-project/CLAUDE.md
mkdir -p your-project/.autoharness
mkdir -p your-project/.autoharness/scripts
mkdir -p your-project/.claude/{rules,skills,hooks}
cp AGENTS.md your-project/.autoharness/AGENTS.md
cp -r autoharness/. your-project/.autoharness/
cp -r scripts/. your-project/.autoharness/scripts/
cp -r autoharness/rules/. your-project/.claude/rules/
cp autoharness/hooks/*.js your-project/.claude/hooks/
bash scripts/install.sh claude your-project/
```

### Codex

```bash
cp AGENTS.md your-project/
mkdir -p your-project/.autoharness
mkdir -p your-project/.autoharness/scripts
cp AGENTS.md your-project/.autoharness/AGENTS.md
cp -r autoharness/. your-project/.autoharness/
cp -r scripts/. your-project/.autoharness/scripts/
mkdir -p your-project/.codex
bash scripts/install.sh codex your-project/
```

## Quick Start

### Natural Language Commands

You can use natural language to trigger these actions:

| You say | AI executes |
|---------|-------------|
| "Install AutoHarness" | `bash /path/to/autoHarness/scripts/install.sh` |
| "Update AutoHarness" | `bash .autoharness/scripts/update.sh` |
| "I want to add a feature" | `/ah-propose <name>` |
| "Discuss requirements" | `/ah-discuss <name>` |
| "Start implementation" | `/ah-execute <name>` |
| "Check readiness" | `/ah-verify <name>` |
| "Ship this" | `/ah-ship <name>` |
| "Debug this bug" | `/ah-debug <issue>` |
| "Use a separate branch" | `/ah-worktree <name>` |

### Workflow Commands

```text
/ah-propose <name>      → Create change proposal
/ah-discuss <name>      → Clarify scope and acceptance
/ah-execute <name>      → Implement confirmed work
/ah-debug <issue>        → Reproduce and fix defects
/ah-verify <name>       → Run unified verification
/ah-ship <name>         → Commit or deliver verified work
/ah-worktree <name>     → Create isolated worktree
```

## Default Flow

```text
Feature flow:
/ah-propose -> /ah-discuss -> /ah-execute -> /ah-verify -> /ah-ship

Bug flow:
/ah-debug -> /ah-verify -> /ah-ship
```

## Script Commands

| You say | Script |
|---------|--------|
| "Install AutoHarness" | `bash /path/to/autoHarness/scripts/install.sh` |
| "Update AutoHarness" | `bash .autoharness/scripts/update.sh` |
| "Preview update" | `bash .autoharness/scripts/update.sh --dry-run` |
| "Force update" | `bash .autoharness/scripts/update.sh --force` |

## License

MIT
