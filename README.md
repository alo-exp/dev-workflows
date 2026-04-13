# Silver Bullet

**Agentic Process Orchestrator for AI-native Software Engineering & DevOps**

> *"There is no single development, in either technology or management technique, which by itself promises even one order-of-magnitude improvement..."* — Fred Brooks, 1986

Brooks was right then. AI changes the equation now.

Silver Bullet is a Claude Code plugin that orchestrates the best open-source agentic workflows into one enforced process. It combines [GSD](https://github.com/gsd-build/get-shit-done) (multi-agent execution), [Superpowers](https://github.com/obra/superpowers) (code review, branch management), [Engineering](https://github.com/anthropics/knowledge-work-plugins/tree/main/engineering) (testing, docs, deploy), and [Design](https://github.com/anthropics/knowledge-work-plugins/tree/main/design) (design system, UX copy, accessibility) into one guided workflow with 10 layers of compliance. **You don't need to know GSD** -- Silver Bullet guides you through every step, explains what's happening, and handles errors. Just describe what you want to build.

**Current version: v0.18.3** — Fixes F-07 hook false-positive: interpreter binaries (`node`, `python3`, `ruby`) no longer trigger the plugin-boundary write-detection check — only shell write operators do. Plus v0.18.1: Configurable review depth (deep/standard/quick per artifact type), review analytics with JSON Lines metrics and summary reports, cross-artifact consistency validation (SPEC↔REQUIREMENTS↔ROADMAP↔DESIGN alignment), verification-before-completion enforcement in review loop, plus all v0.15.0 capabilities: AI-driven spec creation, external artifact ingestion (JIRA, Figma, Google Docs via MCP), pre-build validation, multi-repo spec coordination, spec floor enforcement, PR-to-spec traceability, UAT pipeline gate, granular artifact review rounds (8 reviewer skills with depth-configurable pass enforcement), SENTINEL security hardening, and enforced subagent dispatch for large-context steps.

## How It Works

When you edit source code without completing the planning phase, you see this:

```
🚫 HARD STOP — Planning incomplete. Missing skills:
❌ quality-gates
Run the missing planning skills before editing source code.
```

When you try to `git commit` before completing the full workflow:

```
🛑 COMPLETION BLOCKED — Workflow incomplete.

You are attempting to commit/push/deploy but these required steps are missing:
  ❌ /code-review
  ❌ /requesting-code-review
  ❌ /receiving-code-review
  ❌ /testing-strategy
  ❌ /documentation
  ❌ /finishing-a-development-branch
  ❌ /deploy-checklist
Complete ALL required workflow steps before finalizing.
```

On every single tool use, you see progress:

```
Silver Bullet: 3 steps | PLANNING 1/1 | REVIEW 1/3 | FINALIZATION 0/4 | Next: /requesting-code-review
```

There is no way to skip steps without the plugin telling Claude (and you) exactly what's missing.

## Two Workflows

Silver Bullet supports two workflow modes, selected during project initialization:

| Workflow | For | Steps | Unique features |
|----------|-----|-------|-----------------|
| `full-dev-cycle` | Application development (web, API, CLI, library) | 20 | GSD wave execution, 9 quality dimensions, TDD, dev-to-DevOps transition, release notes |
| `devops-cycle` | Infrastructure / DevOps (Terraform, k8s, Helm, CI/CD) | 24 | Blast radius assessment, IaC-adapted quality gates, environment promotion, incident fast path, DevOps-to-dev transition, release notes |

Both workflows use GSD as the primary execution engine. Silver Bullet guides you through every step with explanations of what each command does, what to expect, and what to do if something fails. Smooth transitions between the two workflows are built in -- after shipping an app, SB offers to set up infrastructure; after deploying infrastructure, SB offers to continue feature development.

## The Four-Plugin Ecosystem

| Plugin | Role | Key capabilities |
|--------|------|-----------------|
| **GSD** (primary) | Multi-agent execution | Fresh 200K-token context per agent, wave-based parallel execution, dependency graphs, atomic per-task commits, context rot prevention |
| **Superpowers** | Code review + branch management | Brainstorming, requesting-code-review, receiving-code-review, git worktrees, verification |
| **Engineering** | Testing + docs + deploy | code-review, testing-strategy, documentation, deploy-checklist, debugging, architecture |
| **Design** | Design system + UX | design-system, ux-copy, accessibility-review, design-critique |

## Install

### 1. Install prerequisites

```
npx get-shit-done-cc@1.30.0
/plugin install obra/superpowers
/plugin install anthropics/knowledge-work-plugins/tree/main/engineering
/plugin install anthropics/knowledge-work-plugins/tree/main/design
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

### 3. (Optional) Install DevOps plugins

If you'll use the `devops-cycle` workflow, these optional plugins provide context-aware
enrichment. Silver Bullet's skill router automatically selects the best plugin for
your IaC toolchain and cloud provider. None are required — the workflow works without them.

```
/plugin marketplace add hashicorp/agent-skills          # Terraform, Packer
/plugin marketplace add awslabs/agent-plugins           # AWS architecture, serverless, databases
/plugin marketplace add pulumi/agent-skills             # Pulumi programs, IaC migration
/plugin marketplace add ahmedasmar/devops-claude-skills  # k8s, CI/CD, GitOps, monitoring, cost optimization
/plugin marketplace add wshobson/agents                 # Kubernetes operations, Helm, multi-agent teams
```

| Plugin | Best for |
|--------|----------|
| `hashicorp/agent-skills` | Terraform HCL authoring, module design, provider development, Packer images |
| `awslabs/agent-plugins` | AWS architecture, serverless (Lambda/API GW), databases, CDK/CloudFormation |
| `pulumi/agent-skills` | Pulumi programs, ComponentResource, Automation API, IaC migration (TF/CDK/CF/ARM → Pulumi) |
| `ahmedasmar/devops-claude-skills` | Terraform/Terragrunt, k8s troubleshooting, AWS cost optimization, CI/CD pipelines, GitOps (ArgoCD/Flux), monitoring/observability |
| `wshobson/agents` | Kubernetes manifests/Helm/GitOps/security, multi-agent orchestration |

During `/silver:init` setup, Silver Bullet detects which of these are installed
and stores the results in `.silver-bullet.json`. The `devops-cycle` workflow then uses
the `/devops-skill-router` to invoke the best available skill at each trigger point.

### 4. Initialize your project

Open your project in Claude Code and run:

```
/silver:init
```

This will:
- Check that all 4 plugin dependencies are installed
- Auto-detect your project name, tech stack, and source directory
- Ask whether this is an application or DevOps/infrastructure project
- Create `silver-bullet.md` (11-section enforcement guide, §0–§10) and `CLAUDE.md` (project instructions)
- Create `.silver-bullet.json` with your project config
- Copy the appropriate workflow file(s) to `docs/workflows/`
- Scan existing `docs/` and offer to migrate them to the SB documentation scheme (100% transparent — originals preserved as `.pre-sb-backup`, every action requires your approval)
- Create placeholder docs (`docs/ARCHITECTURE.md`, `docs/TESTING.md`, `docs/knowledge/`, `docs/lessons/`, etc.)
- Commit everything

That's it. Enforcement is now active.

## Full Dev Cycle (20 Steps)

### INITIALIZATION
| # | Step | Source | Required |
|---|------|--------|----------|
| 1 | Worktree decision | Inline | No |
| 2 | `/gsd:new-project` | GSD | If new project |

### PER-PHASE LOOP (repeat for each phase in ROADMAP)
| # | Step | Source | Required |
|---|------|--------|----------|
| 3 | `/gsd:discuss-phase` | GSD | **Yes** |
| 4 | `/quality-gates` | Silver Bullet | **Yes** |
| 5 | `/gsd:plan-phase` | GSD | **Yes** |
| 6 | `/gsd:execute-phase` | GSD | **Yes** |
| 7 | `/gsd:verify-work` | GSD | **Yes** |
| 8 | `/code-review` (structured quality review) | Engineering | **Yes** |
| 9 | `/requesting-code-review` (dispatches code-reviewer) | Superpowers | **Yes** |
| 10 | `/receiving-code-review` | Superpowers | **Yes** |
| 11-12 | Post-review plan + execute | GSD | If needed |

### FINALIZATION
| # | Step | Source | Required |
|---|------|--------|----------|
| 13 | `/testing-strategy` | Engineering | **Yes** |
| 14 | `/tech-debt` | Engineering | **Yes** |
| 15 | `/documentation` | Engineering | **Yes** |
| 16 | `/finishing-a-development-branch` | Superpowers | **Yes** |

### DEPLOYMENT
| # | Step | Source | Required |
|---|------|--------|----------|
| 17 | CI/CD pipeline (CI must be green) | Inline | **Yes** |
| 18 | `/deploy-checklist` | Engineering | **Yes** |
| 19 | `/gsd:ship` | GSD | **Yes** |

### RELEASE
| # | Step | Source | Required |
|---|------|--------|----------|
| 20 | `/create-release` | Silver Bullet | **Yes** |

## DevOps Cycle (24 Steps)

Same structure as full-dev-cycle with these additions:
- **Incident fast path** at the top for emergency production changes
- **`/blast-radius`** assessment before quality gates (maps change scope, dependencies, failure scenarios, rollback plan)
- **`/devops-quality-gates`** — 7 IaC-adapted quality dimensions (usability excluded)
- **Environment promotion** section (dev → staging → prod)
- `.yml`/`.yaml` files are NOT exempt from enforcement (they are infrastructure code)

## Built-in Silver Bullet Skills

Skills installed by this plugin that extend the workflow:

| Skill | When to use |
|-------|-------------|
| `/silver` | Main entry point — routes freeform text to the best SB or GSD skill |
| `/silver:init` | Once per project — initializes CLAUDE.md, config, CI, and docs scaffold |
| `/silver:feature` | Orchestrated workflow for feature development |
| `/silver:bugfix` | Orchestrated workflow for bug investigation and fixes |
| `/silver:ui` | Orchestrated workflow for UI/UX work |
| `/silver:devops` | Orchestrated workflow for infrastructure and DevOps tasks |
| `/silver:research` | Orchestrated workflow for research and exploration |
| `/silver:release` | Orchestrated workflow for release preparation |
| `/silver:fast` | Orchestrated workflow for quick, low-overhead tasks |
| `/quality-gates` | Before planning (dev) — checks all 9 quality dimensions in parallel |
| `/blast-radius` | Before planning (DevOps) — maps change scope, dependencies, and rollback plan |
| `/devops-quality-gates` | Before planning (DevOps) — 7 IaC-adapted quality dimensions (usability excluded) |
| `/devops-skill-router` | During DevOps execution — routes to best available IaC toolchain plugin |
| `/forensics` | After a completed, failed, or abandoned session — routes to GSD forensics for workflow issues, handles session-level issues directly |
| `/create-release` | After `/gsd:ship` — generates release notes and creates GitHub Release |

### `/forensics`

When a session produces wrong output, stalls, or is abandoned, `/forensics` guides Claude through structured root-cause investigation rather than blind retrying.

**GSD-aware routing (v0.9.0):** Before running its own investigation, `/forensics` checks whether the issue is a GSD-workflow-level problem (plan drift, execution anomalies, stuck loops, missing artifacts). If so, it routes to `/gsd:forensics` which specializes in `.planning/` artifact analysis. Session-level issues (timeout, stall, SB enforcement failures) remain handled by SB's forensics directly.

**Three investigation paths (for session-level issues):**
1. **Session-level** — Timeout flag, session log, git history → classifies as pre-answer gap, anti-stall trigger, genuine blocker, external kill, or unknown
2. **Task-level** — Plan vs. diff comparison, test failures → classifies as plan ambiguity, implementation drift, upstream dependency, or verification gap
3. **General** — Open-ended; delegates to Path 1 or 2 after one targeted follow-up

**Output:** Saves a `docs/forensics/YYYY-MM-DD-<slug>.md` report with symptom, evidence, root cause, contributing factors, next steps, and prevention.

---

## Ten Enforcement Layers

The plugin doesn't rely on Claude reading instructions. It enforces compliance through hooks that fire automatically:

| Layer | How it works |
|-------|-------------|
| **1. Skill tracker** | `record-skill.sh` fires on every Skill tool invocation. Records completed skills to state file. |
| **2. Stage enforcer** | `dev-cycle-check.sh` fires on every Edit/Write/Bash. HARD STOP if quality gates incomplete and you're touching source code. |
| **3. Compliance status** | `compliance-status.sh` fires on every tool use. Shows progress score so Claude always knows where it stands. |
| **4. Completion audit** | `completion-audit.sh` fires on every Bash command. Blocks `git commit`, `git push`, `gh pr create`, and `deploy` if workflow is incomplete. |
| **5. CI gate** | `ci-status-check.sh` intercepts `git push`. Blocks if the most recent CI run is failing — broken builds cannot be pushed. |
| **6. Stop hook** | `stop-check.sh` fires when Claude declares a task complete. Blocks if required skills are missing — survives compaction. |
| **7. Prompt reminder** | `prompt-reminder.sh` fires on every user prompt. Re-injects missing-skill list and core enforcement rules before Claude processes any message. |
| **8. Forbidden skill gate** | `forbidden-skill-check.sh` blocks deprecated/forbidden skills before they execute. |
| **9. GSD workflow guard** | GSD's own hook detects file edits made outside a `/gsd:*` command and warns. |
| **10. Redundant instructions + anti-rationalization** | CLAUDE.md + workflow file both enforce the same rules. Explicit rules against skipping, combining, or implicitly covering steps. |

## Customization

Edit `.silver-bullet.json` in your project root:

```json
{
  "version": "0.2.0",
  "project": {
    "name": "my-app",
    "src_pattern": "/src/",
    "src_exclude_pattern": "__tests__|\\.test\\.",
    "active_workflow": "full-dev-cycle"
  },
  "skills": {
    "required_planning": ["quality-gates"],
    "required_deploy": [
      "quality-gates",
      "code-review", "requesting-code-review", "receiving-code-review",
      "testing-strategy", "documentation",
      "finishing-a-development-branch", "deploy-checklist",
      "create-release",
      "verification-before-completion",
      "test-driven-development", "tech-debt"
    ],
    "all_tracked": [
      "quality-gates", "blast-radius", "devops-quality-gates", "devops-skill-router",
      "design-system", "ux-copy",
      "architecture", "system-design",
      "code-review", "requesting-code-review", "receiving-code-review",
      "testing-strategy", "documentation",
      "finishing-a-development-branch", "deploy-checklist",
      "create-release",
      "modularity", "reusability", "scalability", "security",
      "reliability", "usability", "testability", "extensibility",
      "forensics", "silver-init",
      "verification-before-completion",
      "test-driven-development", "tech-debt", "accessibility-review", "incident-response",
      "gsd-new-project", "gsd-new-milestone", "gsd-discuss-phase", "gsd-plan-phase",
      "gsd-execute-phase", "gsd-verify-work", "gsd-ship", "gsd-debug",
      "gsd-ui-phase", "gsd-ui-review", "gsd-secure-phase"
    ]
  },
  "devops_plugins": {
    "hashicorp": false,
    "awslabs": false,
    "pulumi": false,
    "devops-skills": false,
    "wshobson": false
  },
  "state": {
    "state_file": "~/.claude/.silver-bullet/state",
    "trivial_file": "~/.claude/.silver-bullet/trivial"
  }
}
```

### What you can change

| Field | What it controls | Default |
|-------|-----------------|---------|
| `src_pattern` | Which file paths trigger enforcement | `/src/` |
| `src_exclude_pattern` | Which files are exempt (regex) | `__tests__\|\.test\.` |
| `active_workflow` | Which workflow to enforce | `full-dev-cycle` |
| `required_planning` | Skills that must run before code edits | `quality-gates` |
| `required_deploy` | Skills required for final delivery (gh pr create, deploy, release) — see two-tier enforcement note below | quality-gates, code-review, requesting-code-review, receiving-code-review, testing-strategy, documentation, finishing-a-development-branch, deploy-checklist, create-release, verification-before-completion, test-driven-development, tech-debt |
| `all_tracked` | All skills that get recorded | 42 skills (see above) |
| `devops_plugins` | Which optional DevOps plugins are installed (auto-detected) | all `false` |

> **Two-tier enforcement**: `git commit` and `git push` only require `required_planning` skills (default: `quality-gates`). The full `required_deploy` list is only checked at final delivery time — `gh pr create`, deploy commands, and `gh release create`. This allows GSD's `/gsd:execute-phase` to make atomic commits during development without being blocked.

## Trivial Changes

For typo fixes, copy edits, and config tweaks that don't need the full workflow, Claude will automatically detect the change is trivial and bypass enforcement by running:

```bash
touch ~/.claude/.silver-bullet/trivial
```

You can also run this manually if Claude doesn't detect a trivial change. The flag is automatically cleaned up on the next session start.

**Note**: In `devops-cycle` mode, `.yml`, `.yaml`, `.json`, and `.toml` files are infrastructure code and are NOT auto-exempted from enforcement.

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
/silver:init
```

It detects the existing config and asks if you want to refresh templates while preserving your customizations.

## Troubleshooting

**"jq not found"** — Install jq: `brew install jq` (macOS) or `apt install jq` (Linux).

**"Superpowers plugin not found"** — Run `/plugin install obra/superpowers`.

**"Engineering plugin not found"** — Run `/plugin install anthropics/knowledge-work-plugins/tree/main/engineering`.

**"Design plugin not found"** — Run `/plugin install anthropics/knowledge-work-plugins/tree/main/design`.

**"GSD plugin not found"** — Run `npx get-shit-done-cc@1.30.0`.

**Hooks not firing** — Make sure you ran `/silver:init` in the project. Check that `.silver-bullet.json` exists in your project root.

**Wrong files triggering enforcement** — Edit `src_pattern` in `.silver-bullet.json` to match your project's source directory (e.g., `/app/` or `/lib/`).

**Want to start fresh** — Delete `.silver-bullet.json` and `CLAUDE.md`, then run `/silver:init` again.

## Architecture

```
Enforcement hooks (fire automatically)     Project files (created by /silver:init)
──────────────────────────────────────     ───────────────────────────────────────────────
hooks/record-skill.sh                      .silver-bullet.json (config)
  → records skill invocations              silver-bullet.md (enforcement guide)
                                           CLAUDE.md (project instructions)
                                           docs/workflows/full-dev-cycle.md (20 steps)
hooks/dev-cycle-check.sh                   docs/workflows/devops-cycle.md (24 steps)
  → HARD STOP if planning incomplete
                                           State files (in ~/.claude/.silver-bullet/)
hooks/compliance-status.sh                 ─────────────────────────────────
  → progress score on every tool use       ~/.claude/.silver-bullet/state (skill log)
                                           ~/.claude/.silver-bullet/trivial (bypass flag)
hooks/completion-audit.sh                  ~/.claude/.silver-bullet/mode (interactive|autonomous)
  → blocks commit/push/deploy              ~/.claude/.silver-bullet/session-log-path

hooks/stop-check.sh
  → blocks task-complete if skills missing (fires on Stop/SubagentStop)

hooks/prompt-reminder.sh
  → re-injects missing skills + core rules before every user message

hooks/forbidden-skill-check.sh
  → blocks deprecated/forbidden skills (PreToolUse/Skill)

Support hooks (fire automatically)
───────────────────────────────────
hooks/semantic-compress.sh
  → TF-IDF context compression after Skill invocations

hooks/session-log-init.sh
  → creates session log file on first Bash use

hooks/ci-status-check.sh
  → verifies CI green before push/deploy proceeds

hooks/timeout-check.sh
  → monitors for stall conditions

hooks/session-start
  → injects Superpowers + Design context; injects core-rules.md at session open

External enforcement (GSD's own hooks)
──────────────────────────────────────
GSD workflow guard → warns on edits outside /gsd:* commands
GSD context monitor → warns at ≤35% tokens, escalates at ≤25%
```

## License

MIT — [Alo Labs](https://alolabs.dev)
