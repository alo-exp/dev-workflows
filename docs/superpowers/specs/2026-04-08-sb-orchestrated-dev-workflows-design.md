# Silver Bullet Orchestrated Dev Workflows — Design Spec

**Date:** 2026-04-08  
**Status:** Approved for planning  
**Author:** Brainstorming session (Superpowers:brainstorming)

---

## 1. Overview

Silver Bullet (SB) gains six named orchestration workflows covering all common software development tasks. Each workflow chains GSD (execution backbone), Superpowers (craft discipline), MultAI (multi-AI intelligence), and SB quality gates (enforcement) in a deliberately designed, synergistic sequence.

The `/silver` router classifies any incoming bare instruction and dispatches to the correct workflow. SB enforces the workflow sequence, explains deviations, and persists user preferences in `silver-bullet.md §5`.

---

## 2. Design Goals

- **Maximize synergy**: each plugin does what it is best at; no overlap, no redundancy
- **GSD governs execution**: GSD is the backbone; other plugins discipline the process around it
- **Single namespace**: all SB skills use `silver:` prefix consistently. Skill folder names use `silver-<name>` (e.g. `skills/silver-feature/`) and map to slash commands as `silver:<name>` (e.g. `/silver:feature`)
- **Enforced but customizable**: workflows are enforced by SB; users can override steps with preferences saved to §5
- **Full coverage**: every common dev task has a pre-designed workflow; ad-hoc tasks route through `/silver` to the best available skill

---

## 3. New Plugin Dependencies

The following plugins must be added as formal SB dependencies, checked at `silver:init` and `silver:update`:

| Plugin | Required skill(s) | Status |
|--------|-------------------|--------|
| MultAI | orchestrator, landscape-researcher, solution-researcher, comparator, consolidator | Already installed |
| Anthropic Product Management | `/product-brainstorming` | In slash menu, not cached locally |
| Anthropic Engineering | `/documentation`, `/testing-strategy` | In slash menu, not cached locally |

`silver:init` must verify all three are accessible before proceeding. If missing, offer to install before continuing.

---

## 4. The Six Workflows

### 4.1 `silver:feature` — New Feature Development

**Entry triggers:** "add X", "build X", "implement X", "new feature", "enhance X", "extend X"

> **Multi-signal ambiguity:** If an instruction matches both `silver:feature` and `silver:ui` (e.g. "build a dashboard component"), route to `silver:ui` — UI is more specific. If it matches both `silver:feature` and `silver:bugfix`, route to `silver:bugfix` — fixes take precedence. See Section 6.6 for full conflict resolution rules.

| Step | Skill(s) | Purpose |
|------|----------|---------|
| 0 | `silver:intel` (gsd-intel) | Query codebase intelligence to orient planning |
| 0b | `silver:scan` [brownfield only, if no intel files] | Rapid structure assessment |
| 1a | `silver:explore` [fuzzy ideas only] | Socratic clarification before structured brainstorming |
| 1b | `/product-brainstorming` | PM lens: problem definition, user value, personas, success metrics, scope |
| 1c | `silver:brainstorm` (superpowers:brainstorming) | Engineering lens: architecture, approaches, spec, design doc, spec-review loop |
| 1d | `silver:multai` [arch-significant or user-requested] | 7-AI perspectives on architecture/approach before spec is locked. Distinct from Step 9c (gsd-review): 1d informs the spec pre-implementation; 9c reviews completed code post-execution. Both can fire independently. |
| 2 | `/testing-strategy` | Define test levels, tooling, coverage targets — must run before writing-plans so test requirements are baked into the plan |
| 2.5 | `silver:writing-plans` (superpowers:writing-plans) | Convert approved spec + test strategy → structured implementation plan |
| 3 | `silver:quality-gates` [pre-plan] | All 9 dimensions: reliability, security, scalability, usability, testability, modularity, reusability, extensibility, plus devops-quality-gates for infra-touching changes. `silver:security` always mandatory regardless of §5. `silver:testability` is one of the 9 dimensions — not a separate step. |
| 4 | `gsd-discuss-phase` | Adaptive questioning → CONTEXT.md with locked decisions for planner |
| 5 | `gsd-analyze-dependencies` | Map phase dependencies before GSD creates the plan |
| 6 | `gsd-plan-phase` | PLAN.md with verification loop |
| 7 | `gsd-execute-phase` | Wave-based execution with worktrees |
| 7a | `silver:tdd` [impl plans only] | TDD red-green-refactor per implementation task |
| 7b | [config/infra/doc plans] | Skip TDD — not applicable |
| 8 | `gsd-code-review-fix` [if issues in REVIEW.md] | Auto-fix findings atomically before human review |
| 9a | `silver:request-review` (superpowers:requesting-code-review) | Frame review scope and focus rigorously |
| 9b | `gsd-code-review` | Spawn reviewer agents → REVIEW.md |
| 9c | `gsd-review` [arch-significant] | Cross-AI adversarial peer review — post-execution code review, distinct from Step 1d pre-spec MultAI |
| 9d | `silver:receive-review` (superpowers:receiving-code-review) | Disciplined response to findings — no blind agreement |
| 10 | `gsd-add-tests` [if coverage gaps remain] | Fill test coverage gaps post-execution |
| 11 | `gsd-secure-phase` | Retroactive threat mitigation verification |
| 12 | `gsd-validate-phase` | Nyquist validation gap filling |
| 13 | `gsd-verify-work` | UAT, must-haves, artifact checks |
| 14 | `silver:quality-gates` [pre-ship] | Full 9-dimension sweep before shipping |
| 15a | `silver:finishing-branch` (superpowers:finishing-a-development-branch) | Merge / PR / cleanup decision |
| 15b | `gsd-pr-branch` [ask user; save pref to §5] | Clean PR branch stripping .planning/ commits |
| 16 | `gsd-ship` | Push branch, create PR, prepare for merge (phase-level) |
| 17 [last phase of milestone only] | `gsd-audit-uat` → `gsd-audit-milestone` → [gaps] `gsd-plan-milestone-gaps` → back to step 1 of gap phases (max 2 gap-closure iterations) → `gsd-complete-milestone` | Milestone completion lifecycle |

**Error path:** If `gsd-execute-phase` fails mid-wave, SB routes to `silver:bugfix` triage (Step 0 classification). The phase is not marked complete until `gsd-verify-work` passes.

---

### 4.2 `silver:bugfix` — Bug, Regression, Test Failure

**Entry triggers:** "bug", "broken", "crash", "error", "regression", "failing test", "not working"

| Step | Skill(s) | Purpose |
|------|----------|---------|
| 0 | SB triage | Classify failure type — determines path |
| 1A [known symptom, unknown fix] | `superpowers:systematic-debugging` → `gsd-debug` | Structure hypothesis first; then execute investigation with persistent state across context resets |
| 1B [unknown cause, needs reconstruction] | `silver:forensics` → then path 1A | `silver:forensics` (SB-owned, wraps `skills/forensics/SKILL.md`): reconstructs cause from git history, artifacts, and state. Outputs a cause classification report, then hands off to 1A. |
| 1C [failed GSD workflow specifically] | `gsd-forensics` → then path 1A | GSD-owned post-mortem for failed GSD workflows (failed plans, broken state, incomplete phases). Outputs diagnosis, then hands off to 1A. |
| 2 | `silver:tdd` | Write failing regression test first — red must appear before writing any fix |
| 3 | `gsd-plan-phase` [lightweight, 1-2 tasks] | Plan the fix |
| 4 | `gsd-execute-phase` + `silver:tdd` | Execute fix, verify green |
| 5 | `silver:request-review` + `gsd-code-review` + `silver:receive-review` | Review the fix |
| 6 | `gsd-verify-work` | Confirm fix, zero regression |
| 7 | `silver:quality-gates` [pre-ship] | Security + affected quality dimensions |
| 8 | `gsd-ship` | Push branch, create PR |

---

### 4.3 `silver:ui` — Frontend, Component, Interface Work

**Entry triggers:** "UI", "frontend", "component", "screen", "design", "interface", "page", "layout", "animation", "responsive"

| Step | Skill(s) | Purpose |
|------|----------|---------|
| 0 | `silver:intel` + `silver:scan` [brownfield] | Orient in codebase |
| 1a | `silver:explore` [fuzzy] | Clarify fuzzy UI intent |
| 1b | `/product-brainstorming` | User flows, personas, success criteria |
| 1c | `silver:brainstorm` | UI architecture, component hierarchy, interaction design, spec |
| 1d | `silver:multai` [major UI system] | Multi-AI UX pattern perspectives |
| 2 | `/testing-strategy` | Test levels for UI (component, visual, e2e) — before writing-plans |
| 2.5 | `silver:writing-plans` | Spec + test strategy → implementation plan |
| 3 | `silver:quality-gates` [pre-plan] | Usability + testability emphasis; `silver:security` mandatory |
| 4 | `gsd-discuss-phase` | UI phase context → CONTEXT.md |
| 5 | `gsd-ui-phase` | UI-SPEC.md design contract |
| 6 | `gsd-plan-phase` | Implementation PLAN.md |
| 7 | `gsd-execute-phase` + `silver:tdd` [component logic] | Execute with TDD for testable component units |
| 8 | `silver:request-review` + `gsd-code-review` + [arch-sig] `gsd-review` + `silver:receive-review` | Layered code review |
| 9 | `gsd-ui-review` | 6-pillar visual audit of implemented UI |
| 10 | `gsd-secure-phase` | Frontend security: XSS, CSP, auth surface |
| 11 | `gsd-verify-work` + `gsd-add-tests` [gaps] | UAT + test gap filling |
| 12 | `gsd-validate-phase` | Nyquist gap filling |
| 13 | `silver:quality-gates` [pre-ship] | Full sweep |
| 14 | `silver:finishing-branch` + [ask] `gsd-pr-branch` | Merge/PR decision |
| 15 | `gsd-ship` + milestone steps if last phase | Ship |

---

### 4.4 `silver:devops` — Infrastructure, CI/CD, IaC, Cloud

**Entry triggers:** "infra", "CI/CD", "deploy", "pipeline", "terraform", "IaC", "kubernetes", "container", "cloud", "ops"

> **SB-owned skills used here:** `silver:blast-radius` (maps change scope, failure modes, rollback), `silver:devops-skill-router` (routes to right IaC/cloud skill), `silver:devops-quality-gates` (7 IaC-adapted dimensions). All three are defined in `skills/blast-radius/`, `skills/devops-skill-router/`, `skills/devops-quality-gates/` respectively. See Section 9 for ownership.

**`silver:devops-quality-gates` dimensions (7):** reliability, security, scalability, modularity, testability, observability, change-safety. Usability is omitted (no user-facing interface in IaC). Extensibility is omitted (IaC is declarative, not extensible). These 7 replace the standard 9 for devops workflows.

| Step | Skill(s) | Purpose |
|------|----------|---------|
| 1 | `silver:blast-radius` | Map change scope, downstream deps, failure modes, rollback plan |
| 2 | `silver:devops-skill-router` | Route to right IaC/cloud skill (Terraform, Pulumi, AWS, k8s…) |
| 3 | `silver:devops-quality-gates` | 7 IaC-adapted quality dimensions |
| 3b | `silver:security` [always] | Infrastructure security mandatory — runs even though security is in devops-quality-gates, as an independent hard gate |
| 4 | `gsd-discuss-phase` | DevOps phase context → CONTEXT.md |
| 5 | `gsd-plan-phase` | PLAN.md |
| 6 | `gsd-execute-phase` [TDD skipped] | Execute — TDD not applicable for infra plans |
| 7 | `silver:request-review` + `gsd-code-review` + [arch-sig] `gsd-review` + `silver:receive-review` | IaC review |
| 8 | `gsd-secure-phase` | IaC security + secrets verification |
| 9 | `gsd-verify-work` | Deployment verification |
| 10 | `silver:quality-gates` [pre-ship, standard 9] | Full standard sweep pre-deploy |
| 11 | `gsd-ship` | Deploy |

---

### 4.5 `silver:research` — Tech Decisions, Architecture Spikes, Comparisons

**Entry triggers:** "how should we", "which technology", "compare X vs Y", "spike", "investigate", "architecture decision", "should we use", "what's the best approach for"

| Step | Skill(s) | Purpose |
|------|----------|---------|
| 1 | `silver:explore` (gsd-explore) | Socratic: clarify the research question precisely before choosing research mode |
| 2a [market/landscape question] | `multai:landscape-researcher` → `multai:consolidator` | 9-section market landscape report synthesized into unified findings |
| 2b [tech selection question] | `multai:orchestrator` → `multai:comparator` → `multai:consolidator` | 7-AI perspectives → weighted comparison matrix → unified recommendation report |
| 2c [competitive/product intelligence] | `multai:solution-researcher` | 7-AI competitive intelligence CIR |
| 3 | `silver:brainstorm` | Apply research findings to engineering design — what do we actually build and how? |
| 4 | Hand off to `silver:feature` or `silver:devops` | Research artifacts (landscape report / comparison matrix / CIR) are written to `.planning/research/<date>-<topic>/` and referenced by path in the receiving workflow's `gsd-discuss-phase` context |

---

### 4.6 `silver:release` — Ship, Version, Publish, Go Live

**Entry triggers:** "release", "publish", "version", "changelog", "go live", "cut a release", "tag v", "ship to users", "deploy to prod"

> **`gsd-ship` vs `silver:release`:** `gsd-ship` inside other workflows = phase-level merge (push branch → create PR → prepare for merge). `silver:release` = milestone-level publishing (versioned release, docs, changelog, GitHub Release, milestone archival). These are distinct operations at different abstraction levels. SB disambiguates "ship" intent at routing time per Section 6.2.

**Gap-closure loop limit:** Step 2b may trigger at most 2 gap-closure iterations. If gaps remain after 2 iterations of `gsd-plan-milestone-gaps` → `silver:feature`, SB surfaces to the user with a structured report of remaining gaps and options: A. Release anyway with known gaps documented, B. Extend milestone, C. Abort release.

| Step | Skill(s) | Purpose |
|------|----------|---------|
| 0 | `silver:quality-gates` | Full 9-dimension pre-release sweep |
| 1 | `gsd-audit-uat` | Cross-phase UAT — surface all outstanding gaps before release |
| 2 | `gsd-audit-milestone` | Milestone completion vs original intent |
| 2b [gaps found, ≤2 iterations] | `gsd-plan-milestone-gaps` → `silver:feature` (gap phases) → return to step 0 | Gap closure loop with iteration limit |
| 3a | `gsd-docs-update` | Verify all existing docs are accurate against codebase |
| 3b | `/documentation` | Generate/update GitHub README, user guide, website help section, project page. Runs after gsd-docs-update so it generates content on top of verified accuracy. |
| 4 | `gsd-milestone-summary` | Milestone narrative for release notes |
| 5 | `silver:create-release` | Git-history release notes + GitHub Release creation (SB-owned, defined in `skills/create-release/SKILL.md`) |
| 6 | [ask user] `gsd-pr-branch` | Clean PR branch? Save preference to §5 |
| 7 | `gsd-complete-milestone` | Archive milestone, prepare for next version |
| 8 | `gsd-ship` | Deploy, CI green, tag pushed |

---

### 4.7 `silver:fast` — Trivial Changes (non-workflow path)

**Entry triggers:** ≤3 files, typo fix, config value, rename, one-liner

`silver:fast` bypasses all workflow steps and invokes `gsd-fast` directly. No planning, no quality gates, no review. SB confirms the change is within the trivial threshold before proceeding. If SB judges the change is not trivial, it re-routes to the appropriate workflow.

---

## 5. `silver:init` Additions

`silver:init` already performs plugin checks, mode selection, and session setup. The following steps are added in the specified positions:

| When | After which existing step | Addition |
|------|--------------------------|----------|
| New project detected (no .planning/) | After dependency check | Run `gsd-new-project` to scaffold ROADMAP, STATE.md, project structure |
| Existing project, no .planning/codebase/ | After dependency check | Run `gsd-map-codebase` → `gsd-scan` to build codebase intelligence |
| Dependency check | Phase 1.5 (existing) | Add MultAI, Anthropic Engineering plugin, Anthropic Product Management plugin to version freshness checks |
| Mode selection | Existing mode question | If Autonomous selected: note that `gsd-autonomous` will drive all remaining phases end-to-end |
| Session start §0 | Existing §0 update check | Add MultAI update check alongside GSD and Superpowers |

---

## 6. `/silver` Router — Classification & Dispatch

### 6.1 Classification Table (first match wins)

| User intent signals | Route to | Notes |
|---------------------|----------|-------|
| "what if", "I'm thinking about", "not sure how to", "help me think" | `silver:explore` | Too fuzzy; clarify first |
| "add X", "build X", "implement X", "new feature", "enhance X" | `silver:feature` | Core dev path |
| "bug", "broken", "crash", "error", "regression", "failing test", "not working" | `silver:bugfix` | Triage internally |
| "UI", "frontend", "component", "screen", "design", "interface", "page", "layout", "animation", "responsive" | `silver:ui` | Includes mobile, web, design systems |
| "infra", "CI/CD", "deploy", "pipeline", "terraform", "IaC", "kubernetes", "container", "cloud", "ops" | `silver:devops` | Includes containers, networking, monitoring |
| "how should we", "which technology", "compare X vs Y", "spike", "investigate", "architecture decision", "should we use", "what's the best approach for" | `silver:research` | Tech decisions, architecture choices |
| "release", "publish", "version", "go live", "cut a release", "tag v", "ship to users", "deploy to prod" | `silver:release` | Milestone-level only |
| "merge this", "push this PR", "ship this feature" [active phase context] | `gsd-ship` (in-workflow) | Phase-level only |
| "trivial", "quick fix", "typo", "one-liner", "config value", ≤3 files | `silver:fast` (gsd-fast) | No planning overhead |
| "where are we", "what's left", "show progress", "current status" | `gsd-progress` | Status only |
| "pick up", "resume", "continue where" | `gsd-resume-work` | Session restore |

### 6.2 Disambiguation: "Ship" Intent

| Signal | Route |
|--------|-------|
| Contains version number (v2.0, 1.4.0…) | `silver:release` |
| Contains "changelog" or "release notes" | `silver:release` |
| Contains "go live", "to production", "to users", "publicly" | `silver:release` |
| Active phase in progress, no version signal | `gsd-ship` (phase-merge) |
| No active phase, end of milestone | `silver:release` |

### 6.3 MultAI Auto-Trigger Conditions

SB proactively offers MultAI when:
- Choosing between 2+ fundamentally different architectures
- Selecting a technology stack from scratch
- Domain is novel (no prior intel in `.planning/`)
- Change affects public API or data model fundamentally
- User explicitly requests external perspectives

### 6.4 Complexity Triage

| Classification | Signals | Action |
|----------------|---------|--------|
| Trivial | Typo, config, rename, ≤3 files | `silver:fast` — bypass workflow |
| Simple | Clear scope, ≤1 phase | Route to workflow, skip `silver:explore` |
| Complex | Multi-phase, cross-cutting | Full workflow including explore + brainstorm |
| Fuzzy | Vague intent, unclear scope | `silver:explore` first, then re-classify |

### 6.5 Step-Skip Protocol

When user requests skipping a workflow step, SB always:
1. Explains why the step exists (one sentence)
2. Offers lettered options: A. Accept skip, B. Lightweight alternative, C. Show me what you have
3. Records the decision in §5 if user chooses A permanently

**Non-skippable gates** (hard stops regardless of §5): `silver:security`, `silver:quality-gates` pre-ship, `gsd-verify-work`.

### 6.6 Multi-Signal Conflict Resolution

When an instruction matches multiple workflows:

| Conflict | Winner | Rationale |
|----------|--------|-----------|
| `silver:bugfix` + any other | `silver:bugfix` | Fixes take precedence — broken things block everything |
| `silver:ui` + `silver:feature` | `silver:ui` | UI is more specific; feature is the fallback |
| `silver:devops` + `silver:feature` | Ask user | Both equally valid; neither is a subset of the other |
| `silver:research` + any | `silver:research` first | Research informs the implementation workflow |

---

## 7. Testing Skill Chain

Five testing skill invocations form a non-overlapping chain across each feature/UI workflow:

| When | Skill | Purpose |
|------|-------|---------|
| Pre-planning quality gate (Step 3) | `silver:testability` (embedded in `silver:quality-gates`) | Design-time: ensures architecture CAN be tested — DI, pure functions, seams, observable state |
| After spec approval, before writing-plans (Step 2) | `/testing-strategy` | Planning-time: defines WHAT to test and HOW — test levels, tooling, coverage targets, test data strategy |
| During execution, impl plans only (Step 7a) | `silver:tdd` | Execution-time: red-green-refactor discipline per task |
| Post-execution, if coverage gaps (Step 10) | `gsd-add-tests` | Gap-filling: generate tests from UAT criteria |
| Pre-ship quality gate (Step 14) | `silver:testability` (embedded in `silver:quality-gates`) | Final check: shipped code still has testable architecture |

> Note: `silver:testability` is one of the 9 standard quality dimensions — it runs as part of `silver:quality-gates`, not as a separate step. The 9 dimensions are: reliability, security, scalability, usability, testability, modularity, reusability, extensibility, plus `silver:devops-quality-gates` replaces all 9 with its 7 IaC-specific dimensions for devops workflows.

---

## 8. Preference System — `silver-bullet.md §5`

A new `§5 User Workflow Preferences` section in `silver-bullet.md` and `templates/silver-bullet.md.base`.

### 8.1 Preference Categories

- **§5a Routing Preferences** — override which workflow handles a given work type
- **§5b Step Skip Preferences** — permanent skip of specific steps under stated conditions
- **§5c Tool Preferences** — preferred tool at decision points (e.g. always cross-AI review)
- **§5d MultAI Preferences** — when to always/never trigger MultAI
- **§5e Mode Preferences** — default session mode, PR branch behavior, TDD enforcement

### 8.2 Capture Protocol

When user expresses a preference:
1. SB identifies the preference type
2. Confirms: "Save as permanent preference? A. Yes, save it  B. Just this session"
3. If A: writes to `silver-bullet.md §5` + `templates/silver-bullet.md.base §5`, commits both
4. Applied silently at every relevant decision point thereafter

### 8.3 Conflict Resolution

`§5` overrides workflow defaults. Hard gates (`silver:security`, `silver:quality-gates` pre-ship, `gsd-verify-work`) are never overridable.

---

## 9. Plugin Role Summary

| Plugin | Role | Owns |
|--------|------|------|
| GSD | Execution backbone | Planning, execution, verification, state, worktrees, shipping, debugging (gsd-debug, gsd-forensics), code review agents (gsd-code-review), UI spec (gsd-ui-phase), milestone lifecycle |
| Superpowers | Craft discipline | Brainstorming (silver:brainstorm), TDD (silver:tdd), code review framing (silver:request-review, silver:receive-review), systematic debugging hypothesis, plan writing (silver:writing-plans), branch finishing (silver:finishing-branch) |
| SB (Silver Bullet) | Orchestration + quality enforcement | Workflow sequencing, 9 standard quality dimensions (silver:quality-gates), SB-specific forensics (silver:forensics), blast radius (silver:blast-radius), devops routing (silver:devops-skill-router), devops quality gates (silver:devops-quality-gates), release creation (silver:create-release), preference memory, step enforcement, routing |
| MultAI | Multi-AI intelligence | Landscape research (multai:landscape-researcher), solution research (multai:solution-researcher), 7-AI orchestration (multai:orchestrator), comparison matrices (multai:comparator), consolidation (multai:consolidator) |
| Product Management (`/product-brainstorming`) | PM lens | Problem definition, user value, personas, success metrics, scope boundaries |
| Engineering (`/documentation`, `/testing-strategy`) | Engineering practices | Documentation generation (`/documentation`), test strategy planning (`/testing-strategy`) |
| Context7 | Live documentation | Library/framework docs during planning and implementation — invoked by GSD executors inline, not orchestrated by SB |
| Episodic Memory | Cross-session recall | Past decisions, lessons learned — passive SessionStart hook, not orchestrated by SB |
| LSP plugins | Language intelligence | Code intelligence — auto-activated by Claude Code, not orchestrated by SB |

---

## 10. Implementation Phases

### Phase A — Workflow Definitions in `silver-bullet.md` (ship first)

- Add `§2h SB Orchestrated Workflows` to `silver-bullet.md` + `templates/silver-bullet.md.base`: the 6 workflow step tables, testing skill chain, and disambiguation rules
- Add `§5 User Workflow Preferences` section (initially empty, structure defined)
- Expand `/silver` router (`skills/silver/SKILL.md`) classification table, disambiguation rules, and conflict resolution rules
- Add MultAI, Engineering plugin, Product Management plugin to `silver:init` dependency checks and version freshness (§1.5)
- Add `gsd-new-project` and `gsd-map-codebase` into `silver:init` flow (after existing dependency check step)
- Update `silver-bullet.md §0` to include MultAI update check alongside GSD and Superpowers

### Phase B — Named Orchestration Skills (follow-on)

Each skill file maps folder name → slash command: `skills/silver-feature/SKILL.md` → `/silver:feature`

- `skills/silver-feature/SKILL.md` — thin orchestrator chaining Phase A steps
- `skills/silver-bugfix/SKILL.md`
- `skills/silver-ui/SKILL.md`
- `skills/silver-devops/SKILL.md`
- `skills/silver-research/SKILL.md`
- `skills/silver-release/SKILL.md`

---

## 11. Non-Goals

- SB does not implement features directly — it orchestrates only
- SB does not replace GSD's execution machinery — GSD governs execution
- Superpowers parallel agents and subagent-driven-development are not used (GSD handles parallelism)
- `/using-git-worktrees` is not used (GSD has native worktree support)
- LSP plugins, Context7, and Episodic Memory are not orchestrated by SB — they activate passively or are invoked by GSD executors
