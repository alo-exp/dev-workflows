# Project Documentation Scheme

Defines the documentation architecture that Silver Bullet scaffolds and enforces for any software engineering project. This is the canonical reference for what docs exist in a user project, when they're created, when they're updated, and how they stay bounded.

## Governing Principles

1. **Docs are artifacts, not afterthoughts** — every document is produced by a specific workflow step and reviewed by the artifact reviewer framework
2. **No doc grows unbounded** — every file uses a scalability pattern (see below)
3. **Separation of concerns** — planning artifacts (`.planning/`) are ephemeral per-milestone; project docs (`docs/`) are durable across milestones
4. **LLM-friendly** — no file exceeds 300 lines in its active section; large docs use summary + archive pattern

## Scalability Patterns

| Pattern | Mechanism | Cap |
|---------|-----------|-----|
| **Snapshot** | Overwritten each milestone; previous version archived | No growth |
| **Capped Table** | Max N rows; oldest archived when exceeded | N rows max |
| **Rotation** | File archived at line threshold; fresh file started | Threshold lines |
| **Summary + Archive** | Only current content inline; older collapsed to links | ~100 lines active |
| **Fixed** | Structurally bounded by nature | No growth |

---

## Layer 1: Planning Artifacts (`.planning/`)

Managed by GSD. Created and consumed during the SDLC. Scalability enforced by SB on milestone completion.

### Core Project Files

| File | Created By | Updated By | Purpose | Scalability |
|------|-----------|-----------|---------|-------------|
| `PROJECT.md` | `gsd-new-project` | milestone transitions | Vision, core value, validated requirements | **Summary + Archive** — requirements older than 2 milestones collapsed to count |
| `ROADMAP.md` | `gsd-new-project` | `gsd-add-phase`, milestone completion | Phase structure, dependencies, status | **Summary + Archive** — completed milestone phases collapsed to one-liners |
| `STATE.md` | `gsd-new-project` | every workflow step | Progress, decisions, quick tasks | **Capped Table** — 20 quick task rows max; reset on milestone completion |
| `REQUIREMENTS.md` | `gsd-new-milestone` | planning workflows | Scoped requirements with AC traceability | **Snapshot** — recreated each milestone |
| `config.json` | `gsd-new-project` | `gsd-settings` | Workflow toggles, review depth | **Fixed** |

### Spec & Design (per-feature, version-tracked)

| File | Created By | Purpose | Scalability |
|------|-----------|---------|-------------|
| `SPEC.md` | `silver-spec` / `silver-ingest` | Canonical spec: user stories, ACs, assumptions | **Fixed** — one per feature, version-replaced |
| `DESIGN.md` | `silver-spec` / `silver-ingest` | Architecture decisions, component design | **Fixed** — one per feature |
| `INGESTION_MANIFEST.md` | `silver-ingest` | Status of ingested external artifacts | **Fixed** — overwritten per ingestion |
| `VALIDATION.md` | `silver-validate` | Pre-build gap analysis (SPEC ACs vs PLAN tasks) | **Fixed** — overwritten per run |
| `UAT.md` | `gsd-audit-uat` | AC-to-evidence test matrix | **Fixed** — one per milestone |

### Phase Artifacts (in `.planning/phases/{NN}-{slug}/`)

Each phase produces a bounded set of artifacts. All are **fixed** — one per phase, never appended to.

| File | Created By | Purpose |
|------|-----------|---------|
| `{NN}-{M}-CONTEXT.md` | `gsd-discuss-phase` | Locked decisions, assumptions, open questions |
| `{NN}-{M}-RESEARCH.md` | `gsd-research-phase` | Implementation research, pitfalls, recommendations |
| `{NN}-{M}-PLAN.md` | `gsd-plan-phase` | Executable task list, dependencies, verification criteria |
| `{NN}-{M}-SUMMARY.md` | `gsd-execute-phase` | Post-execution: files changed, deviations, lessons |
| `{NN}-{M}-VERIFICATION.md` | `gsd-verify-work` | Goal-backward verification: must-haves, test results |
| `{NN}-{M}-REVIEW.md` | `gsd-code-review` | Code review findings by severity |
| `{NN}-SECURITY.md` | `gsd-secure-phase` | Threat model verification |
| `{NN}-UI-SPEC.md` | `gsd-ui-phase` | Frontend design contract (UI phases only) |

### Review & Analytics

| File | Created By | Purpose | Scalability |
|------|-----------|---------|-------------|
| `REVIEW-ROUNDS.md` | review-loop | Audit trail of all review rounds | **Rotation** — archived at 200 lines; reset on milestone completion |
| `review-analytics.jsonl` | review-loop | JSON Lines metrics per review round | **Rotation** — archived at 1000 lines |

### Quick Tasks (in `.planning/quick/{id}-{slug}/`)

| File | Created By | Purpose | Scalability |
|------|-----------|---------|-------------|
| `PLAN.md` | `gsd-quick` | Quick task plan | **Fixed** — one per task |
| `SUMMARY.md` | `gsd-quick` | Quick task result | **Fixed** — one per task |
| *(directories)* | — | — | **Cleaned** on milestone completion |

### Archives

| Location | Created By | Purpose |
|----------|-----------|---------|
| `.planning/milestones/v{N}-ROADMAP.md` | milestone completion | Archived roadmap snapshot |
| `.planning/milestones/v{N}-REQUIREMENTS.md` | milestone completion | Archived requirements |
| `.planning/milestones/v{N}-STATE.md` | milestone completion | Archived state snapshot |
| `.planning/archive/{milestone-slug}/` | `phase-archive.sh` | Phase directory snapshots |
| `.planning/archive/review-rounds-{date}.md` | rotation | Rotated review rounds |
| `.planning/archive/review-analytics-{date}.jsonl` | rotation | Rotated analytics |

---

## Layer 2: Project Documentation (`docs/`)

Durable across milestones. Updated during the Documentation step of finalization. Each doc serves a specific SDLC concern.

### Required Docs (scaffolded by `/silver:init`)

| File | SDLC Stage | Created | Updated | Purpose | Scalability |
|------|-----------|---------|---------|---------|-------------|
| `docs/ARCHITECTURE.md` | Design | `/silver:init` | Documentation step | Component model, layers, data flow, integration points, design principles | **Snapshot** — rewritten when architecture changes |
| `docs/TESTING.md` | Verification | `/silver:init` | Documentation step, after test infrastructure changes | Test pyramid, coverage goals, test classification | **Fixed** |
| `docs/CHANGELOG.md` | Release | `/silver:init` | Documentation step (every task) | Rolling task log: what, commits, skills, cost | **Capped Table** — 50 entries max; older entries archived to `docs/archive/` |
| `docs/knowledge/INDEX.md` | All | `/silver:init` | When docs added/removed | Gateway index — doc path table | **Fixed** |
| `docs/knowledge/YYYY-MM.md` | All | Documentation step | Documentation step (every task) | Project-scoped intelligence: architecture, gotchas, decisions | Monthly files — naturally bounded |
| `docs/lessons/YYYY-MM.md` | All | Documentation step | Documentation step (every task) | Portable lessons: domain, stack, practice, devops, design | Monthly files — naturally bounded |
| `docs/CICD.md` | Deploy | `/silver:init` (if CI exists) | When pipeline changes | Pipeline stages, what runs where | **Fixed** |

### Recommended Docs (created when relevant)

| File | SDLC Stage | Created When | Purpose | Scalability |
|------|-----------|-------------|---------|-------------|
| `docs/API.md` | Implementation | First API endpoint created | API reference: endpoints, auth, examples | **Snapshot** — regenerated from code/spec |
| `docs/DEPLOYMENT.md` | Deploy | First deployment | Environment setup, deployment steps, rollback | **Fixed** |
| `docs/CONTRIBUTING.md` | Maintenance | Open-source or multi-contributor | Contribution guide, coding standards, PR process | **Fixed** |
| `docs/SECURITY.md` | Security | After first security audit | Threat model, security posture, audit history | **Snapshot** — rewritten each release |
| `docs/ADR/` | Architecture | First significant architecture decision | Architecture Decision Records (one file per decision) | **Fixed** per decision — bounded by nature |

### Supporting Directories

| Directory | Purpose | Scalability |
|-----------|---------|-------------|
| `docs/specs/` | Point-in-time design specs from `.planning/` phases | **Fixed** per spec — one file per design decision |
| `docs/sessions/` | Per-session work logs | **Capped** — 30 sessions max; older archived |
| `docs/archive/` | Archived changelog entries, old sessions | Reference only |

---

## Layer 3: Public-Facing Documentation

Updated during finalization (Documentation step) and verified during pre-release quality gate Stage 3.

| File | Purpose | Scalability |
|------|---------|-------------|
| `README.md` | Project overview, getting started, badges | **Fixed** — rewritten to reflect current state |
| `CHANGELOG.md` (root) | User-facing version history (if publishing) | **Summary + Archive** — last 5 versions inline |

---

## Knowledge & Lessons Management

Project intelligence is split into two directories to separate project-specific knowledge from portable lessons.

### `docs/knowledge/` — Project-Scoped Intelligence

**Content:** Things learned about THIS project — architecture patterns, gotchas, key decisions, recurring patterns, open questions. Not redundant with `ARCHITECTURE.md` (current state, not journey), phase `CONTEXT.md` (single-phase, archived), or `tech-debt.md` (actionable items).

**File convention:** `YYYY-MM.md` — one file per month, append-only within that month, frozen after.

**Categories per file:** Architecture Patterns, Known Gotchas, Key Decisions, Recurring Patterns, Open Questions (with `[RESOLVED]` tracking).

**Gateway:** `docs/knowledge/INDEX.md` — doc path table, updated when docs added/removed.

### `docs/lessons/` — Portable Lessons Learned

**Content:** General lessons applicable beyond this project. Written as if explaining to someone who has never seen this codebase. No project-specific file paths, feature names, or requirement IDs.

**File convention:** `YYYY-MM.md` — same monthly segmentation.

**Category taxonomy (extensible):**
- `domain:{area}` — business domain lessons (regulations, patterns, terminology)
- `stack:{technology}` — language/framework/tool-specific
- `practice:{area}` — software engineering practices
- `devops:{area}` — CI, deployment, monitoring, infrastructure
- `design:{area}` — UI, UX, accessibility patterns

### Scalability

- Monthly files stay bounded (~50-150 lines for active projects)
- No rotation needed — natural monthly segmentation handles growth
- Safety cap: if a monthly file exceeds 300 lines, split into `YYYY-MM-a.md` / `YYYY-MM-b.md`
- Old files are never modified — frozen after their month ends
- LLM reads only current month's file + INDEX.md during sessions

---

## Milestone Completion Cleanup

On `gsd-complete-milestone`, SB enforces these scalability operations:

| Target | Action |
|--------|--------|
| `STATE.md` | Archive to `milestones/v{N}-STATE.md`. Reset with fresh milestone header. Quick tasks table max 20 rows |
| `ROADMAP.md` | Archive to `milestones/v{N}-ROADMAP.md`. Collapse completed phases to one-liners |
| `PROJECT.md` | Collapse old requirements to counts. Keep current + previous milestone inline |
| `REQUIREMENTS.md` | Archive to `milestones/v{N}-REQUIREMENTS.md`. Fresh file for new milestone |
| `REVIEW-ROUNDS.md` | Archive to `.planning/archive/{slug}/REVIEW-ROUNDS.md`. Start fresh |
| `quick/` dirs | Delete prior milestone directories (summaries in archived STATE.md) |
| `docs/CHANGELOG.md` | Archive entries beyond 50 to `docs/archive/` |
| `docs/sessions/` | Archive sessions beyond 30 to `docs/archive/` |

---

## Document Lifecycle by SDLC Stage

| SDLC Stage | Docs Created | Docs Updated |
|------------|-------------|-------------|
| **Project Setup** | knowledge/INDEX.md, ARCHITECTURE.md, TESTING.md, CICD.md, CHANGELOG.md | README.md |
| **Ideation** | SPEC.md, INGESTION_MANIFEST.md | — |
| **Requirements** | REQUIREMENTS.md, DESIGN.md | PROJECT.md |
| **Planning** | CONTEXT.md, RESEARCH.md, PLAN.md, VALIDATION.md | ROADMAP.md, STATE.md |
| **Implementation** | SUMMARY.md | STATE.md |
| **Review** | REVIEW.md, REVIEW-ROUNDS.md | review-analytics.jsonl |
| **Testing** | VERIFICATION.md | TESTING.md (if strategy changes) |
| **Security** | SECURITY.md (phase-level) | docs/SECURITY.md (if project has one) |
| **UAT** | UAT.md | — |
| **Finalization** | Session log | knowledge/YYYY-MM.md, lessons/YYYY-MM.md, CHANGELOG.md, ARCHITECTURE.md, README.md |
| **Release** | GitHub release notes | CHANGELOG.md (root), PROJECT.md |
| **Milestone Close** | Milestone archives | All planning docs (reset/collapse) |

---

## Non-Redundancy Rules

1. `.planning/` artifacts are the source of truth during active development — `docs/` are derived summaries
2. Never duplicate content between `.planning/REQUIREMENTS.md` and `docs/` — reference it
3. `knowledge/` captures intelligence NOT derivable from code or git history; `lessons/` captures portable learnings
4. `docs/ARCHITECTURE.md` captures high-level design only — phase-level designs stay in `.planning/phases/`
5. `docs/CHANGELOG.md` is the task log — git log is the commit log. Different granularity, no overlap
