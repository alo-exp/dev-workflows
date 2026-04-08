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
- **Single namespace**: all SB skills use `silver:` prefix consistently
- **Enforced but customizable**: workflows are enforced by SB; users can override steps with preferences saved to §5
- **Full coverage**: every common dev task has a pre-designed workflow; ad-hoc tasks route through `/silver` to the best available skill

---

## 3. New Plugin Dependencies

The following plugins must be added as formal SB dependencies, checked at `silver:init` and `silver:update`:

| Plugin | Required skill(s) | Status |
|--------|-------------------|--------|
| MultAI | orchestrator, landscape-researcher, solution-researcher, comparator, consolidator | Already installed |
| Anthropic Product Management | /product-brainstorming | In slash menu, not cached |
| Anthropic Engineering | /documentation, /testing-strategy | In slash menu, not cached |

`silver:init` must verify all three are accessible before proceeding. If missing, offer to install before continuing.

---

## 4. The Six Workflows

### 4.1 `silver:feature` — New Feature Development

**Entry triggers:** "add X", "build X", "implement X", "new feature", "enhance X", "extend X"

| Step | Skill(s) | Purpose |
|------|----------|---------|
| 0 | `silver:intel` (gsd-intel) | Query codebase intelligence to orient planning |
| 0b | `silver:scan` [brownfield only] | Rapid structure assessment if no intel files exist |
| 1a | `silver:explore` [fuzzy ideas only] | Socratic clarification before structured brainstorming |
| 1b | `/product-brainstorming` | PM lens: problem definition, user value, personas, success metrics, scope |
| 1c | `silver:brainstorm` (superpowers:brainstorming) | Engineering lens: architecture, approaches, spec, design doc, spec-review loop |
| 1d | `silver:multai` [arch-significant or user-requested] | 7-AI perspectives on architecture/approach before spec is locked |
| 2 | `silver:writing-plans` (superpowers:writing-plans) | Convert approved spec → structured implementation plan |
| 2.5 | `/testing-strategy` | Define test levels, tooling, coverage targets — informs writing-plans |
| 3 | `silver:quality-gates` [pre-plan] | All 9 dimensions (8 standard + extensibility); silver:security always mandatory |
| 4 | `gsd-discuss-phase` | Adaptive questioning → CONTEXT.md with locked decisions for planner |
| 5 | `gsd-analyze-dependencies` | Map phase dependencies before GSD creates the plan |
| 6 | `gsd-plan-phase` | PLAN.md with verification loop |
| 7 | `gsd-execute-phase` | Wave-based execution with worktrees |
| 7a | `silver:tdd` [impl plans] | TDD red-green-refactor per implementation task |
| 7b | [config/infra/doc plans] | Skip TDD |
| 8 | `gsd-code-review-fix` [if issues] | Auto-fix REVIEW.md findings atomically before review |
| 9a | `silver:request-review` (superpowers:requesting-code-review) | Frame review scope and focus rigorously |
| 9b | `gsd-code-review` | Spawn reviewer agents → REVIEW.md |
| 9c | `gsd-review` [arch-significant] | Cross-AI adversarial peer review |
| 9d | `silver:receive-review` (superpowers:receiving-code-review) | Disciplined response to findings — no blind agreement |
| 10 | `gsd-add-tests` [if coverage gaps] | Fill test coverage gaps post-execution |
| 11 | `gsd-secure-phase` | Retroactive threat mitigation verification |
| 12 | `gsd-validate-phase` | Nyquist validation gap filling |
| 13 | `gsd-verify-work` | UAT, must-haves, artifact checks |
| 14 | `silver:quality-gates` [pre-ship] | Full 9-dimension sweep before shipping |
| 15a | `silver:finishing-branch` (superpowers:finishing-a-development-branch) | Merge / PR / cleanup decision |
| 15b | `gsd-pr-branch` [ask user; pref saved to §5] | Clean PR branch stripping .planning/ commits |
| 16 | `gsd-ship` | Push branch, create PR, prepare for merge |
| 17 [last phase of milestone] | `gsd-audit-uat` → `gsd-audit-milestone` → [gaps] `gsd-plan-milestone-gaps` → `gsd-complete-milestone` | Milestone completion lifecycle |

---

### 4.2 `silver:bugfix` — Bug, Regression, Test Failure

**Entry triggers:** "bug", "broken", "crash", "error", "regression", "failing test", "not working"

| Step | Skill(s) | Purpose |
|------|----------|---------|
| 0 | SB triage | Classify failure: known-symptom / unknown-cause / failed-GSD-workflow |
| 1A | `superpowers:systematic-debugging` → `gsd-debug` | Known symptom: hypothesis → execute investigation with persistent state |
| 1B | `silver:forensics` → then 1A | Unknown cause: reconstruct from git/artifacts/state, then investigate |
| 1C | `gsd-forensics` → then 1A | Failed GSD workflow: GSD-specific post-mortem, then investigate |
| 2 | `silver:tdd` | Write failing regression test first — red must appear before fix |
| 3 | `gsd-plan-phase` [lightweight] | Plan the fix (1-2 tasks) |
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
| 1a | `silver:explore` [fuzzy] | Clarify fuzzy UI intent |
| 1b | `/product-brainstorming` | User flows, personas, success criteria |
| 1c | `silver:brainstorm` | UI architecture, component hierarchy, interaction design, spec |
| 1d | `silver:multai` [major UI system] | Multi-AI UX pattern perspectives |
| 2 | `silver:writing-plans` | Spec → implementation plan |
| 2.5 | `/testing-strategy` | Test levels for UI (component, visual, e2e) |
| 3 | `silver:quality-gates` [pre-plan] | Usability + testability emphasis; silver:security mandatory |
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
| 15 | `gsd-ship` + milestone steps if applicable | Ship |

---

### 4.4 `silver:devops` — Infrastructure, CI/CD, IaC, Cloud

**Entry triggers:** "infra", "CI/CD", "deploy", "pipeline", "terraform", "IaC", "kubernetes", "container", "cloud", "ops"

| Step | Skill(s) | Purpose |
|------|----------|---------|
| 1 | `silver:blast-radius` | Map change scope, downstream deps, failure modes, rollback plan |
| 2 | `silver:devops-skill-router` | Route to right IaC/cloud skill (Terraform, Pulumi, AWS, k8s…) |
| 3 | `silver:devops-quality-gates` | 7 IaC-adapted quality dimensions |
| 3b | `silver:security` [always] | Infrastructure security mandatory |
| 4 | `gsd-discuss-phase` | DevOps phase context → CONTEXT.md |
| 5 | `gsd-plan-phase` | PLAN.md |
| 6 | `gsd-execute-phase` [no TDD] | Execute — TDD not applicable for infra plans |
| 7 | `silver:request-review` + `gsd-code-review` + [arch-sig] `gsd-review` + `silver:receive-review` | IaC review |
| 8 | `gsd-secure-phase` | IaC security + secrets verification |
| 9 | `gsd-verify-work` | Deployment verification |
| 10 | `silver:quality-gates` [pre-ship] | Full sweep pre-deploy |
| 11 | `gsd-ship` | Deploy |

---

### 4.5 `silver:research` — Tech Decisions, Architecture Spikes, Comparisons

**Entry triggers:** "how should we", "which technology", "compare X vs Y", "spike", "investigate", "architecture decision", "should we use"

| Step | Skill(s) | Purpose |
|------|----------|---------|
| 1 | `silver:explore` (gsd-explore) | Socratic: clarify the research question precisely |
| 2a [market/landscape] | `multai:landscape-researcher` → `multai:consolidator` | 9-section market landscape report |
| 2b [tech selection] | `multai:orchestrator` → `multai:comparator` → `multai:consolidator` | 7-AI perspectives → weighted comparison → unified recommendation |
| 2c [competitive/product] | `multai:solution-researcher` | 7-AI competitive intelligence CIR |
| 3 | `silver:brainstorm` | Apply research findings to engineering design |
| 4 | → Hand off to `silver:feature` or `silver:devops` | Research artifacts injected as additional context into discuss-phase |

---

### 4.6 `silver:release` — Ship, Version, Publish, Go Live

**Entry triggers:** "release", "publish", "version", "changelog", "go live", "cut a release", "tag v", "ship to users", "deploy to prod"

> **Note:** `gsd-ship` inside other workflows = phase-level merge (push → PR). `silver:release` = milestone-level publishing (versioned release, docs, changelog, GitHub Release, milestone archival). These are distinct operations at different levels. SB disambiguates "ship" intent at routing time.

| Step | Skill(s) | Purpose |
|------|----------|---------|
| 0 | `silver:quality-gates` | Full 9-dimension pre-release sweep |
| 1 | `gsd-audit-uat` | Cross-phase UAT — no outstanding gaps before release |
| 2 | `gsd-audit-milestone` | Milestone completion vs original intent |
| 2b [gaps found] | `gsd-plan-milestone-gaps` → `silver:feature` | Create and execute gap phases, then return to step 0 |
| 3a | `gsd-docs-update` | Verify all docs against codebase (accuracy) |
| 3b | `Engineering:/documentation` | Generate/update GitHub README, user guide, website help section, project page (content) |
| 4 | `gsd-milestone-summary` | Milestone narrative for release notes |
| 5 | `silver:create-release` | Git-history release notes + GitHub Release creation |
| 6 | [ask user] `gsd-pr-branch` | Clean PR branch? Preference saved to §5 |
| 7 | `gsd-complete-milestone` | Archive milestone, prepare for next version |
| 8 | `gsd-ship` | Deploy, CI green, tag pushed |

---

## 5. `silver:init` Additions

| Step | Skill(s) | Purpose |
|------|----------|---------|
| [new project] | `gsd-new-project` | Full project scaffold + ROADMAP |
| [existing code] | `gsd-map-codebase` → `gsd-scan` | Parallel codebase mapping → .planning/codebase/ documents |
| [deps check] | Verify MultAI, Engineering plugin, Product Management plugin | New formal SB dependencies |
| [mode select] | Interactive → step-by-step guided | Session mode at init |
| [mode select] | Autonomous → `gsd-autonomous` drives all remaining phases | |

---

## 6. `/silver` Router — Classification & Dispatch

### 6.1 Classification Table (first match wins)

| User intent signals | Route to | Notes |
|---------------------|----------|-------|
| "what if", "I'm thinking about", "not sure how to", "help me think" | `silver:explore` | Too fuzzy; clarify first |
| "add X", "build X", "implement X", "new feature", "enhance X" | `silver:feature` | Core dev path |
| "bug", "broken", "crash", "error", "regression", "failing test" | `silver:bugfix` | Triage internally |
| "UI", "frontend", "component", "screen", "design", "interface" | `silver:ui` | Includes mobile, web, design systems |
| "infra", "CI/CD", "deploy", "pipeline", "terraform", "IaC", "cloud" | `silver:devops` | Includes containers, networking, monitoring |
| "how should we", "which technology", "compare X vs Y", "spike" | `silver:research` | Tech decisions, architecture choices |
| "release", "publish", "version", "go live", "cut a release", "tag v" | `silver:release` | Milestone-level only |
| "merge this", "push this PR", "ship this feature [branch context]" | `gsd-ship` (in-workflow) | Phase-level only |
| "trivial", "quick fix", "typo", "one-liner", "config value", ≤3 files | `silver:fast` (gsd-fast) | No planning overhead |
| "where are we", "what's left", "show progress" | `gsd-progress` | Status only |
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

SB offers MultAI proactively when:
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

Non-skippable gates (hard stops regardless of §5): `silver:security`, `silver:quality-gates` pre-ship, `gsd-verify-work`.

---

## 7. Testing Skill Chain

Four testing skills form a non-overlapping chain:

| When | Skill | Purpose |
|------|-------|---------|
| Pre-planning quality gate | `silver:testability` | Design-time: ensures architecture CAN be tested (DI, pure functions, seams) |
| After spec, before writing-plans | `/testing-strategy` | Planning-time: defines WHAT to test and HOW (levels, tooling, coverage targets) |
| During execution (impl plans only) | `silver:tdd` | Execution-time: red-green-refactor discipline per task |
| Post-execution (if gaps) | `gsd-add-tests` | Gap-filling: generate tests from UAT criteria |
| Pre-ship quality gate | `silver:testability` | Final check: shipped code still has testable architecture |

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
| GSD | Execution backbone | Planning, execution, verification, state, worktrees, shipping, debugging, forensics, code review agents, UI spec |
| Superpowers | Craft discipline | Brainstorming, TDD, code review framing (request + response), systematic debugging hypothesis, plan writing, branch finishing |
| SB (Silver Bullet) | Orchestration + quality enforcement | Workflow sequencing, all 9 quality dimensions, preference memory, step enforcement, routing |
| MultAI | Multi-AI intelligence | Landscape research, solution research, 7-AI orchestration, comparison matrices, consolidation |
| Product Management (/product-brainstorming) | PM lens | Problem definition, user value, personas, success metrics, scope |
| Engineering (/documentation, /testing-strategy) | Engineering practices | Documentation generation, test strategy planning |
| Context7 | Live documentation | Library/framework docs during planning and implementation (invoked by GSD executors) |
| Episodic Memory | Cross-session recall | Past decisions, lessons learned (passive hook at session start) |
| LSP plugins | Language intelligence | Code intelligence (auto-activated by Claude Code, not orchestrated by SB) |

---

## 10. Implementation Phases

### Phase A — Workflow Definitions in `silver-bullet.md` (ship first)
- Add `§2h SB Orchestrated Workflows` to `silver-bullet.md` + `templates/silver-bullet.md.base`
- Add `§5 User Workflow Preferences` section (initially empty, structure defined)
- Expand `/silver` router classification table and disambiguation rules
- Add MultAI, Engineering, Product Management to `silver:init` dependency checks
- Update `gsd-new-project` + `gsd-map-codebase` into `silver:init` flow
- Update `silver-bullet.md §0` to include MultAI update check

### Phase B — Named Orchestration Skills (follow-on)
- Create `skills/silver-feature/SKILL.md`
- Create `skills/silver-bugfix/SKILL.md`
- Create `skills/silver-ui/SKILL.md`
- Create `skills/silver-devops/SKILL.md`
- Create `skills/silver-research/SKILL.md`
- Create `skills/silver-release/SKILL.md`
- Each skill is a thin SB orchestrator that chains the steps defined in Phase A

---

## 11. Non-Goals

- SB does not implement features directly — it orchestrates only
- SB does not replace GSD's execution machinery — GSD governs execution
- Superpowers parallel agents and subagent-driven-development are not used (GSD handles parallelism)
- `/using-git-worktrees` is not used (GSD has native worktree support)
- LSP plugins, Context7, and Episodic Memory are not orchestrated by SB — they activate passively or are invoked by GSD executors
