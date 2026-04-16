# Architecture and Design

This document captures **high-level architecture and general design principles** only.
Detailed phase-level designs live in `docs/specs/YYYY-MM-DD-<topic>-design.md`.

## System Overview

Silver Bullet is a Claude Code plugin (`.claude-plugin/`) composed of shell hook scripts,
skill markdown files, JSON configuration, and workflow documentation. It wraps the GSD,
Superpowers, Engineering, and Design plugins with an enforcement layer that prevents Claude
from skipping required workflow steps. No server, no database — all state lives in flat files
under `~/.claude/.silver-bullet/`.

## Core Components

| Component | Path | Responsibility |
|-----------|------|----------------|
| Hook scripts | `hooks/*.sh` | PostToolUse/PreToolUse enforcement — fire on every tool call |
| Skill files | `skills/*/SKILL.md` | Declarative workflow instructions loaded via the Skill tool |
| Workflow docs | `docs/workflows/` | Full per-session step-by-step procedures (active copies) |
| Templates | `templates/` | Bootstrap files copied during `/silver:init` setup |
| Config | `.silver-bullet.json` | Project-level list of tracked/required skills |
| State file | `~/.claude/.silver-bullet/state` | Flat file recording invoked skills in this session |
| Trivial flag | `~/.claude/.silver-bullet/trivial` | Touch-file that suspends enforcement for trivial changes |

### Key hooks

| Hook | Trigger | Behavior |
|------|---------|----------|
| `record-skill.sh` | PostToolUse (Skill tool) | Appends normalized skill name to state file |
| `dev-cycle-check.sh` | PreToolUse (Edit/Write/Bash) | 4-stage gate: blocks source edits if planning incomplete |
| `compliance-status.sh` | PostToolUse (all tools) | Emits live progress score per tool call |
| `completion-audit.sh` | PostToolUse (Bash) | Blocks `git commit/push/deploy/gh release` if `required_deploy` skills are missing |
| `ci-status-check.sh` | PostToolUse (Bash) | Warns on commit/push if CI is failing |
| `stop-check.sh` | Stop / SubagentStop | Requires required_deploy skills before session ends; skipped when `trivial` file exists |
| *(hooks.json entry)* | SessionStart | Creates `~/.claude/.silver-bullet/trivial` — marks every new session trivial by default |
| *(hooks.json entry)* | PostToolUse (Write\|Edit\|MultiEdit) | Removes `~/.claude/.silver-bullet/trivial` — clears trivial flag when files are modified |

## Design Principles

1. **Never modify third-party plugins.** All enforcement is additive to the host project.
2. **7 layers, no single bypass.** Enforcement survives context window resets because hooks
   re-fire on every tool call, not just at session start.
3. **User instructions always take precedence.** `CLAUDE.md` user rules override SB defaults.
4. **Non-destructive file operations.** Hooks are read-only except for the state/mode files they
   own. Setup commands create new files; update mode overwrites only `silver-bullet.md`.
5. **Flat-file state.** No process, no daemon, no server. State is a text file. Any tool that
   writes to it or reads from it can be independently audited.
6. **Template parity.** `templates/workflows/` must remain byte-identical to `docs/workflows/`
   so new projects get the same enforcement rules as the current project.

## Technology Choices

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Language | Bash + Node.js | Bash for hooks (no runtime dep); Node for scripts that need JSON parsing |
| Config format | JSON | Machine-readable by hooks and CI; human-readable for customization |
| Skill format | Markdown | Loaded natively by Claude Code's Skill tool |
| State format | Line-delimited text | `grep -q` lookups; append-only; trivially auditable |
| CI | GitHub Actions | Target audience is GitHub repos; `gh` CLI integrates release workflow |
