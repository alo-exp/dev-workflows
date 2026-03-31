# Silver Bullet

**The silver bullet for AI-driven software engineering.**

> *"There is no single development, in either technology or management technique, which by itself promises even one order-of-magnitude improvement..."* — Fred Brooks, 1986

Brooks was right then. AI changes the equation now.

Silver Bullet is a Claude Code plugin that makes Claude follow a structured 31-step development cycle — every time, without exception. It solves the #1 problem with AI coding agents: they skip steps. Even when your CLAUDE.md says "always brainstorm first," Claude will rationalize its way past it ("this is simple enough to just code directly"). This plugin makes that impossible.

## How It Works

When you edit source code without completing the planning phase, you see this:

```
🚫 HARD STOP — Planning incomplete. Missing skills:
❌ brainstorming
❌ write-spec
❌ modularity
❌ reusability
❌ scalability
❌ security
❌ reliability
❌ usability
❌ testability
❌ extensibility
❌ writing-plans
Run the missing planning skills before editing source code.
```

When you try to `git commit` before completing the full workflow:

```
🛑 COMPLETION BLOCKED — Workflow incomplete.

You are attempting to commit/push/deploy but these required steps are missing:
  ❌ /code-review
  ❌ /testing-strategy
  ❌ /documentation
  ❌ /verification-before-completion
Complete ALL required workflow steps before finalizing.
```

On every single tool use, you see progress:

```
Silver Bullet: 12 steps | PLANNING 11/11 | EXECUTION 1/1 | REVIEW 0/3 | FINALIZATION 0/3 | Next: /code-review
```

There is no way to skip steps without the plugin telling Claude (and you) exactly what's missing.

## Install

### 1. Install prerequisites

```
/plugin install obra/superpowers
/plugin install anthropics/knowledge-work-plugins/tree/main/engineering
```

Install `jq` if you don't have it:
```bash
brew install jq    # macOS
apt install jq     # Linux
```

### 2. Install Silver Bullet

```
/plugin install alo-exp/silver-bullet
```

### 3. Initialize your project

Open your project in Claude Code and run:

```
/using-silver-bullet
```

This will:
- Check that all dependencies are installed
- Auto-detect your project name, tech stack, and source directory
- Create a `CLAUDE.md` with enforcement rules
- Create `.silver-bullet.json` with your project config
- Create `docs/workflows/full-dev-cycle.md` with the 31-step workflow
- Create placeholder docs (`docs/Master-PRD.md`, etc.)
- Commit everything

That's it. Enforcement is now active.

## The 31-Step Workflow

### PLANNING (must complete before any source code edit)

| # | Skill | Required | What it does |
|---|-------|----------|-------------|
| 1 | `/using-superpowers` | Yes | Establish available skills for the session |
| 2 | `/using-git-worktrees` | No | Ask if you should use an isolated worktree |
| 3 | `/brainstorming` | **Yes** | Explore intent, constraints, and approaches |
| 4 | `/write-spec` | **Yes** | Write or update spec in `docs/specs/` |
| 5 | `/design-system` | If needed | Visual/UI design |
| 6 | `/ux-copy` | If needed | Review UX copy |
| 7 | `/architecture` | If needed | ADR for architectural decisions |
| 8 | `/system-design` | If needed | Service/component design |
| 9 | `/modularity` | **Yes** | Small, focused modules; file size limits |
| 10 | `/reusability` | **Yes** | DRY, composable components, no duplication |
| 11 | `/scalability` | **Yes** | Stateless, efficient data access, async |
| 12 | `/security` | **Yes** | OWASP, input validation, secrets management |
| 13 | `/reliability` | **Yes** | Fault tolerance, retries, graceful degradation |
| 14 | `/usability` | **Yes** | Intuitive APIs, clear errors, accessibility |
| 15 | `/testability` | **Yes** | Injectable deps, pure functions, test seams |
| 16 | `/extensibility` | **Yes** | Open-closed, versioned, backward-compatible |
| 17 | `/writing-plans` | **Yes** | Create detailed implementation plan |

### EXECUTION

| # | Skill | Required | What it does |
|---|-------|----------|-------------|
| 18 | `/executing-plans` | **Yes** | Execute using TDD + subagent-driven development |

### REVIEW (must complete before deploy)

| # | Skill | Required | What it does |
|---|-------|----------|-------------|
| 19 | `/code-review` | **Yes** | Self-review + code-reviewer subagent |
| 20 | `/requesting-code-review` | No | Request external/peer review |
| 21 | `/receiving-code-review` | **Yes** | Accept/reject all review items |
| 22 | `/writing-plans` | No | Plan to address accepted review items |
| 23 | `/executing-plans` | No | Implement the review-driven plan |
| 24 | `/testing-strategy` | **Yes** | Define best test strategy |
| 25 | `/systematic-debugging` + `/debug` | If needed | Use both for any bug |

### FINALIZATION (must complete before deploy)

| # | Skill | Required | What it does |
|---|-------|----------|-------------|
| 26 | `/tech-debt` | No | Identify and document technical debt |
| 27 | `/documentation` | **Yes** | Update/create project docs |
| 28 | `/verification-before-completion` | **Yes** | Produce evidence before claiming done |
| 29 | `/finishing-a-development-branch` | **Yes** | Merge prep + cleanup |

### DEPLOYMENT

| # | Skill | Required | What it does |
|---|-------|----------|-------------|
| 30 | CICD pipeline | **Yes** | Use existing or set up before deploying |
| 31 | `/deploy-checklist` | **Yes** | Pre-deployment verification gate |

## Six Layers of Enforcement

The plugin doesn't rely on Claude reading instructions. It enforces compliance through hooks that fire automatically:

| Layer | How it works |
|-------|-------------|
| **1. HARD STOP gate** | `dev-cycle-check.sh` fires on every Edit/Write/Bash. If planning skills are incomplete and you're touching source code, it outputs a HARD STOP message. |
| **2. Compliance status** | `compliance-status.sh` fires on every tool use. Shows a one-line progress score so Claude always knows where it stands. |
| **3. Phase gates** | `dev-cycle-check.sh` enforces PLANNING -> EXECUTION -> REVIEW -> FINALIZATION ordering. Detects phase skips. |
| **4. Completion audit** | `completion-audit.sh` fires on every Bash command. Detects `git commit`, `git push`, `gh pr create`, and `deploy` commands and blocks them if the workflow is incomplete. |
| **5. Redundant instructions** | The same rules appear in `CLAUDE.md`, the workflow file, and the hook messages. Claude can't miss them. |
| **6. Anti-rationalization** | Explicit language in CLAUDE.md and the workflow file that blocks common excuses: "it's simple enough," "I already covered this," "not applicable." |

## Customization

Edit `.silver-bullet.json` in your project root:

```json
{
  "project": {
    "name": "my-app",
    "src_pattern": "/src/",
    "src_exclude_pattern": "__tests__|\\.test\\.",
    "active_workflow": "full-dev-cycle"
  },
  "skills": {
    "required_planning": [
      "brainstorming", "write-spec",
      "modularity", "reusability", "scalability", "security",
      "reliability", "usability", "testability", "extensibility",
      "writing-plans"
    ],
    "required_deploy": ["brainstorming", "write-spec", "code-review", "verification-before-completion"],
    "all_tracked": [
      "using-superpowers", "brainstorming", "write-spec", "design-system",
      "ux-copy", "architecture", "system-design",
      "modularity", "reusability", "scalability", "security",
      "reliability", "usability", "testability", "extensibility",
      "writing-plans", "executing-plans", "code-review",
      "requesting-code-review", "receiving-code-review", "testing-strategy",
      "systematic-debugging", "debug", "tech-debt", "documentation",
      "verification-before-completion", "finishing-a-development-branch",
      "deploy-checklist"
    ]
  },
  "state": {
    "state_file": "/tmp/.silver-bullet-state",
    "trivial_file": "/tmp/.silver-bullet-trivial"
  }
}
```

### What you can change

| Field | What it controls | Default |
|-------|-----------------|---------|
| `src_pattern` | Which file paths trigger enforcement | `/src/` |
| `src_exclude_pattern` | Which files are exempt (regex) | `__tests__\|\.test\.` |
| `required_planning` | Skills that must run before code edits | brainstorming, write-spec, 8 quality-ilities, writing-plans |
| `required_deploy` | Skills that must run before commit/push/deploy | brainstorming, write-spec, code-review, verification-before-completion |
| `all_tracked` | All skills that get recorded | 28 skills (see above) |

## Trivial Changes

For typo fixes, copy edits, and config tweaks that don't need the full workflow, Claude will automatically detect the change is trivial and bypass enforcement by running:

```bash
touch /tmp/.silver-bullet-trivial
```

You can also run this manually if Claude doesn't detect a trivial change. The flag is automatically cleaned up on the next session start.

## For CI/CD Pipelines

Copy the deploy gate snippet into your pipeline:

```bash
# In your deploy script:
bash scripts/deploy-gate-snippet.sh

# Or with bypass:
bash scripts/deploy-gate-snippet.sh --skip-workflow-check
```

This checks the workflow state file and blocks deployment if required skills are missing.

## Updating

If the plugin is updated and you want to refresh templates:

```
/using-silver-bullet
```

It detects the existing config and asks if you want to refresh templates while preserving your customizations.

## Troubleshooting

**"jq not found"** — Install jq: `brew install jq` (macOS) or `apt install jq` (Linux).

**"Superpowers plugin not found"** — Run `/plugin install obra/superpowers`.

**"Engineering plugin not found"** — Run `/plugin install anthropics/knowledge-work-plugins/tree/main/engineering`.

**Hooks not firing** — Make sure you ran `/using-silver-bullet` in the project. Check that `.silver-bullet.json` exists in your project root.

**Wrong files triggering enforcement** — Edit `src_pattern` in `.silver-bullet.json` to match your project's source directory (e.g., `/app/` or `/lib/`).

**Want to start fresh** — Delete `.silver-bullet.json` and `CLAUDE.md`, then run `/using-silver-bullet` again.

## Architecture

```
Plugin hooks (fire automatically)          Project files (created by /using-silver-bullet)
─────────────────────────────────          ───────────────────────────────────────────────
hooks/record-skill.sh                      .silver-bullet.json (config)
  → records skill invocations              CLAUDE.md (enforcement rules)
                                           docs/workflows/full-dev-cycle.md (31 steps)
hooks/dev-cycle-check.sh
  → HARD STOP if planning incomplete       State files (ephemeral, in /tmp/)
                                           ─────────────────────────────────
hooks/compliance-status.sh                 /tmp/.silver-bullet-state (skill log)
  → progress score on every tool use       /tmp/.silver-bullet-trivial (bypass flag)

hooks/completion-audit.sh
  → blocks commit/push/deploy

hooks/session-start
  → injects Superpowers context
```

## License

MIT — [Ālo Labs](https://alolabs.dev)
