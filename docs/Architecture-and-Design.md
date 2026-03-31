# Silver Bullet — Architecture and Design

## Overview

Silver Bullet is a Claude Code plugin that enforces development workflow compliance through PostToolUse hooks and a setup skill. It runs entirely in bash, requires no build step, and uses the filesystem for state.

## System Architecture

```
┌─────────────────────────────────────────────────────┐
│  Claude Code Runtime                                │
│                                                     │
│  ┌──────────────┐    ┌──────────────────────────┐   │
│  │  Skill Tool   │───>│  /using-silver-bullet     │   │
│  │  invocation   │    │  (SKILL.md — setup)       │   │
│  └──────────────┘    └──────────────────────────┘   │
│                                                     │
│  ┌──────────────┐    ┌──────────────────────────┐   │
│  │  PostToolUse  │───>│  Hooks (5 scripts)        │   │
│  │  event        │    │  stdin: JSON  stdout: JSON│   │
│  └──────────────┘    └──────────────────────────┘   │
│                              │                      │
│                              v                      │
│                       ┌──────────────┐              │
│                       │  State file   │              │
│                       │  /tmp/.dev-*  │              │
│                       └──────────────┘              │
│                              ^                      │
│                              │                      │
│                       ┌──────────────┐              │
│                       │  Config file  │              │
│                       │  .dev-work*.json│            │
│                       └──────────────┘              │
└─────────────────────────────────────────────────────┘
```

## Hook Architecture

All hooks follow the same pattern:
1. Read JSON from stdin (hook protocol)
2. Walk up from `$PWD` to find `.silver-bullet.json` (stop at `.git/` or `/`)
3. Read config values with jq (fall back to defaults if missing)
4. Perform check logic
5. Output JSON to stdout with `hookSpecificOutput.message`
6. Always exit 0 (never block on hook failure)

### Hook Inventory

| Hook | Matcher | Fires On | Purpose |
|------|---------|----------|---------|
| `session-start` | SessionStart | Session init | Inject /using-superpowers context |
| `record-skill.sh` | Skill | Skill invocations | Track skills to state file |
| `dev-cycle-check.sh` | Edit\|Write\|Bash | Code edits | Four-stage enforcement gate |
| `compliance-status.sh` | .* | Every tool use | Show compliance progress |
| `completion-audit.sh` | Bash | Bash commands | Block premature commit/push/deploy |

### Six-Layer Enforcement

1. **HARD STOP gate** (dev-cycle-check.sh) — Blocks src edits without planning
2. **Compliance status** (compliance-status.sh) — Progress on every tool use
3. **Phase gates** (dev-cycle-check.sh) — Enforces phase ordering
4. **Completion audit** (completion-audit.sh) — Blocks commit/push/deploy
5. **Redundant instructions** — Rules in CLAUDE.md + workflow + hooks
6. **Anti-rationalization** — Explicit language against skipping

## Config Resolution

All hooks resolve config by walking up from `$PWD`:

```
$PWD → check .silver-bullet.json → parent dir → ... → .git/ boundary → /
```

`compliance-status.sh` caches the resolved path in `/tmp/.silver-bullet-config-path-<md5>` for performance (fires on every tool use).

## State Management

- **State file** (`/tmp/.silver-bullet-state`): One skill name per line, appended by `record-skill.sh`
- **Trivial file** (`/tmp/.silver-bullet-trivial`): Presence = bypass enforcement
- Both paths configurable via `.silver-bullet.json` and `SILVER_BULLET_STATE_FILE` env var

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Bash-only hooks | No dependencies beyond jq; runs everywhere Claude Code runs |
| Walk-up config resolution | Supports monorepos and nested project structures |
| Exit 0 on all failures | Hooks must never block the user — enforcement is advisory |
| State in /tmp/ | Simple, ephemeral, auto-cleans on reboot |
| Namespace stripping in record-skill.sh | Users invoke `superpowers:brainstorming` but we track `brainstorming` |
| `blockToolUse` in completion-audit | Strongest enforcement available if runtime supports it |

## File Structure

```
silver-bullet/
├── .claude-plugin/
│   ├── plugin.json          # Plugin identity and entry points
│   └── marketplace.json     # Marketplace metadata and dependencies
├── hooks/
│   ├── hooks.json           # Hook declarations (matchers + commands)
│   ├── session-start        # SessionStart: inject Superpowers context
│   ├── record-skill.sh      # PostToolUse(Skill): track invocations
│   ├── dev-cycle-check.sh   # PostToolUse(Edit|Write|Bash): stage gate
│   ├── compliance-status.sh # PostToolUse(*): progress score
│   ├── completion-audit.sh  # PostToolUse(Bash): block premature completion
│   └── run-hook.cmd         # Cross-platform polyglot wrapper
├── scripts/
│   └── deploy-gate-snippet.sh  # Copy-paste for CI/CD pipelines
├── skills/
│   ├── using-silver-bullet/
│   │   └── SKILL.md         # Setup skill (4 phases)
│   ├── modularity/
│   │   └── SKILL.md         # Modular design enforcement
│   ├── reusability/
│   │   └── SKILL.md         # DRY, composable components
│   ├── scalability/
│   │   └── SKILL.md         # Stateless, efficient, scalable design
│   ├── security/
│   │   └── SKILL.md         # OWASP, input validation, defense in depth
│   ├── reliability/
│   │   └── SKILL.md         # Fault tolerance, graceful degradation
│   ├── usability/
│   │   └── SKILL.md         # Intuitive APIs, clear errors, accessibility
│   ├── testability/
│   │   └── SKILL.md         # Injectable deps, pure functions, test seams
│   └── extensibility/
│       └── SKILL.md         # Open-closed, versioned interfaces
├── templates/
│   ├── CLAUDE.md.base       # Project CLAUDE.md template
│   ├── silver-bullet.config.json.default  # Config template
│   └── workflows/
│       └── full-dev-cycle.md # 31-step workflow definition
├── docs/                    # Project documentation
├── package.json             # Metadata only (no npm dependencies)
├── README.md
├── CHANGELOG.md
└── LICENSE
```
