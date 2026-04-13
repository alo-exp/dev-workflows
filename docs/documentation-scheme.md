# Silver Bullet Documentation Scheme

Defines the documentation architecture for Silver Bullet — what docs exist, who they serve, how they stay bounded, and how they avoid redundancy with GSD/Superpowers/Engineering/Design plugins.

## Governing Principles

1. **SB documents the orchestration layer** — enforcement, wiring, quality posture, SDLC coverage. GSD documents execution mechanics. Superpowers documents autonomous patterns. No overlap.
2. **Every document has a size cap** — enforced by consistent scalability patterns (see below).
3. **Three audiences** — End Users (Help Center), Project Operators (`docs/`), LLM Consumption (`.planning/`).

## Universal Scalability Strategy: The Rolling Window

Every growing document uses one of these bounded patterns:

| Pattern | Mechanism | Used For |
|---------|-----------|----------|
| **Snapshot** | Overwritten each milestone; previous version archived to `milestones/v{N}-{file}` | STATE.md, REQUIREMENTS.md |
| **Capped Table** | Max N rows; oldest trimmed when exceeded; trimmed rows archived | Quick tasks log (20 rows), tech-debt register (20 items) |
| **Rotation** | File archived at size threshold; new file started | review-analytics.jsonl (1000 lines), REVIEW-ROUNDS.md (200 lines) |
| **Summary + Archive** | Active doc holds only current milestone's content; completed milestone content collapsed to one-line + archive link | ROADMAP.md, PROJECT.md |
| **Fixed** | Structurally bounded, never grows | config.json, SPEC.md (version-replaced), per-phase artifacts |

**Cap targets**: No `.planning/` file should exceed 300 lines in its active section. No `docs/` file should exceed 500 lines.

---

## Tier 1: End-User Documentation (Help Center — `site/help/`)

**Owner**: SB team. **Audience**: Users of Silver Bullet.

| Document | SDLC Stage | Purpose | Scalability |
|----------|-----------|---------|-------------|
| `getting-started/` | Onboarding | Zero-to-productive guide | **Fixed** — rewritten per major version |
| `concepts/` (6 pages) | All | Core mental model: enforcement layers, routing, verification, cost, preferences, session startup | **Fixed** — concept pages are stable |
| `workflows/` (7 pages) | Planning - Deploy | Per-workflow guide (feature, bugfix, UI, devops, research, release, fast) | **Fixed** — one page per workflow type |
| `dev-workflow/` | Full cycle | End-to-end dev walkthrough | **Fixed** — narrative guide |
| `devops-workflow/` | Infra cycle | End-to-end DevOps walkthrough | **Fixed** — narrative guide |
| `reference/` | All | Command reference, config options, hook list | **Fixed** — regenerated per release |
| `troubleshooting/` | All | Common issues + fixes | **Capped** — max 30 entries, oldest archived |
| `changelog/` | Release | User-facing what's new | **Summary + Archive** — last 3 versions inline, older linked |

**Non-redundant because**: Help Center explains SB-specific UX (enforcement, routing, workflows). It never explains GSD phase mechanics or Superpowers spec philosophy — it links to them.

---

## Tier 2: Project Operator Documentation (`docs/`)

**Owner**: SB maintainers. **Audience**: Contributors, auditors, future maintainers.

| Document | SDLC Stage | Purpose | Scalability |
|----------|-----------|---------|-------------|
| `ARCHITECTURE.md` | Design | Component model, hook pipeline, skill routing, plugin integration points | **Snapshot** — rewritten when architecture changes |
| `ENFORCEMENT.md` | All (cross-cutting) | The 7 enforcement layers: what each does, how they compose, bypass detection | **Fixed** — layers are structural |
| `SDLC-MAP.md` | All | Single-page map: each SDLC stage to skills, artifacts, enforcement layers | **Fixed** — matrix updated per release |
| `PLUGIN-BOUNDARIES.md` | Design | What GSD owns vs Superpowers vs Engineering vs Design vs SB | **Fixed** — updated when plugin responsibilities shift |
| `SECURITY.md` | Security | Current threat model posture + audit archive index | **Snapshot** — rewritten each release; historical audits in `docs/audits/` |
| `RELEASE.md` | Release | Release process, quality gate checklist, versioning policy, CI pipeline | **Fixed** — process doc |
| `TESTING.md` | Verification | Test pyramid, coverage goals, skip policy | **Fixed** — updated per test infrastructure change |
| `tech-debt.md` | Maintenance | Active debt register with severity scores | **Capped Table** — max 20 items; resolved items deleted (tracked in git history) |
| `CHANGELOG.md` | Release | Maintainer-facing changelog | **Summary + Archive** — last 5 versions inline, older in `docs/archive/` |
| `PRD-Overview.md` | Ideation | Product vision, requirement areas, scope | **Fixed** — updated per major version |

### Knowledge & Lessons directories

| Directory | Purpose | Scalability |
|-----------|---------|-------------|
| `docs/knowledge/` | Project-scoped intelligence: architecture patterns, gotchas, decisions, open questions | Monthly files (`YYYY-MM.md`) — naturally bounded |
| `docs/knowledge/INDEX.md` | Gateway index — doc path table | **Fixed** — updated when docs added/removed |
| `docs/lessons/` | Portable lessons learned: domain, stack, practice, devops, design | Monthly files (`YYYY-MM.md`) — naturally bounded |

### Supporting directories

| Directory | Contents | Scalability |
|-----------|----------|-------------|
| `docs/audits/` | Historical SENTINEL security audit reports | One file per audit, never modified. Cap: max 20 files; oldest removed when exceeded (findings in git history) |
| `docs/specs/` | Point-in-time design specs | Inherently bounded (one per design decision) |
| `docs/sessions/` | Per-session notes | Kept as reference |
| `docs/internal/` | QA reports, guidelines, superseded docs | Reference archive — not actively maintained |
| `docs/workflows/` | Active workflow copies (full-dev-cycle, devops-cycle) | **Fixed** — rewritten when workflow changes |

---

## Tier 3: Per-Project SDLC Artifacts (`.planning/`)

Defined by GSD. SB enforces scalability via milestone-completion cleanup:

| Artifact | Risk | SB Enforcement |
|----------|------|----------------|
| **STATE.md** | Quick tasks table + decisions grow unbounded | **Capped Table**: max 20 rows. Archived to `milestones/v{N}-STATE.md` on milestone completion. Decisions trimmed to current milestone only |
| **ROADMAP.md** | Phases accumulate | **Summary + Archive**: completed milestone phases collapsed to one-line summaries with archive link. Only current milestone phases in detail |
| **PROJECT.md** | Requirements grow | **Summary + Archive**: requirements older than 2 milestones collapsed to count. Only current + previous milestone inline |
| **REVIEW-ROUNDS.md** | Append-only, no rotation | **Rotation**: archived at 200 lines to `.planning/archive/review-rounds-{date}.md`. Reset to empty on milestone completion |
| **review-analytics.jsonl** | Already rotates at 1000 lines | No change needed — rotation exists |
| **`phases/` directories** | Accumulate | Already archived by `phase-archive.sh` on milestone completion |
| **`quick/` directories** | Accumulate with no cleanup | Directories from prior milestones deleted on milestone completion (summaries preserved in archived STATE.md) |
| **Codebase intel files** | Can grow with codebase | **Snapshot**: overwritten (not appended) on each `gsd-map-codebase` run |

---

## Non-Redundancy Contract

| Concern | Authoritative Owner | SB's Role |
|---------|-------------------|-----------|
| Phase planning mechanics | GSD | Enforces (dev-cycle gate) |
| Phase execution | GSD | Enforces (model routing) |
| Spec creation philosophy | Superpowers | Orchestrates (silver-spec) |
| TDD methodology | Superpowers | Enforces (required_deploy) |
| System design | Engineering plugin | Triggers at workflow step |
| UI/UX review | Design plugin | Triggers conditionally |
| 7-layer enforcement | **Silver Bullet** | Owns and documents |
| Workflow sequencing | **Silver Bullet** | Owns and documents |
| Artifact reviewer framework | **Silver Bullet** | Owns and documents |
| SDLC coverage mapping | **Silver Bullet** | Owns and documents |

**Rules:**
1. SB docs never explain GSD phase mechanics — they reference GSD
2. SB docs never explain Superpowers spec philosophy — they reference Superpowers
3. SB docs never document Engineering/Design skill behavior — they reference the skills
4. SB documents only: enforcement layers, orchestration wiring, quality posture, SDLC coverage
5. If content belongs to a plugin, SB links to it rather than duplicating it
