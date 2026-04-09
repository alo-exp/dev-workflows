# Architecture Research

**Domain:** AI-driven spec creation, external artifact ingestion, multi-repo orchestration (Silver Bullet v0.14.0)
**Researched:** 2026-04-09
**Confidence:** HIGH (based on direct inspection of existing plugin, skills, hooks, and workflow files)

---

## Standard Architecture

### System Overview — Current State (v0.13.2)

```
┌──────────────────────────────────────────────────────────────────┐
│                      User Entry Point                            │
│        /silver (smart router) → routes to skill                  │
├──────────────────────────────────────────────────────────────────┤
│                  SB Orchestration Skills Layer                   │
│  ┌──────────────┐ ┌────────────┐ ┌──────────────┐ ┌──────────┐  │
│  │silver-feature│ │silver-fast │ │ silver-bugfix │ │silver-ui │  │
│  └──────┬───────┘ └─────┬──────┘ └──────┬───────┘ └────┬─────┘  │
│         │               │               │               │        │
├─────────┴───────────────┴───────────────┴───────────────┴────────┤
│              Delegate to GSD Execution Engine                    │
│  gsd-plan-phase / gsd-execute-phase / gsd-verify-work / etc.    │
├──────────────────────────────────────────────────────────────────┤
│         SB Enforcement Hooks (fire automatically)                │
│  SessionStart: session-start                                     │
│  PreToolUse:  forbidden-skill-check, completion-audit,           │
│               dev-cycle-check, ci-status-check                   │
│  PostToolUse: semantic-compress, record-skill, compliance-status,│
│               timeout-check, session-log-init                    │
│  Stop:        stop-check                                         │
│  UserPrompt:  prompt-reminder                                    │
├──────────────────────────────────────────────────────────────────┤
│              silver-bullet.md §0–§10 Enforcement                 │
│  §0 Identity  §1 Routing  §2 Workflows  §3 DevOps               │
│  §4 Forensics §5 Quality  §6 Session    §7 Security              │
│  §8 Boundary  §9 Pre-release  §10 User Prefs                    │
├──────────────────────────────────────────────────────────────────┤
│              .planning/ Project State                            │
│  PROJECT.md  REQUIREMENTS.md  ROADMAP.md  STATE.md              │
└──────────────────────────────────────────────────────────────────┘
```

### Target Architecture — v0.14.0 Additions

```
┌──────────────────────────────────────────────────────────────────┐
│                      User Entry Point                            │
│    /silver (extended router) → existing + new spec skills        │
├──────────────────────────────────────────────────────────────────┤
│              NEW: Spec Creation Skills Layer                     │
│  ┌─────────────────┐  ┌──────────────────┐  ┌────────────────┐  │
│  │  silver-spec     │  │ silver-ingest    │  │silver-validate │  │
│  │ (AI-guided spec  │  │ (JIRA/Figma/     │  │(pre-build gap  │  │
│  │  elicitation)    │  │  GDoc ingestion) │  │ analysis)      │  │
│  └────────┬─────────┘  └───────┬──────────┘  └───────┬────────┘  │
│           │                    │                      │           │
├───────────┴────────────────────┴──────────────────────┴───────────┤
│              Existing Orchestration Skills (unchanged)            │
│    silver-feature + silver-bugfix + silver-ui + silver-devops     │
│    — now consume spec artifacts before brainstorm                 │
├──────────────────────────────────────────────────────────────────┤
│              NEW: Spec Artifacts in .planning/                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │ SPEC.md      │  │ DESIGN.md    │  │ REQUIREMENTS.md (std)│   │
│  │ (final spec) │  │ (UX/Figma)   │  │ (elicited)           │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
├──────────────────────────────────────────────────────────────────┤
│              NEW: Enforcement Hooks (added to hooks.json)        │
│  PreToolUse:  spec-floor-check.sh (blocks gsd-plan without spec) │
│  PostToolUse: pr-traceability.sh (links PR to spec on gsd-ship)  │
├──────────────────────────────────────────────────────────────────┤
│              Existing Enforcement Layer (unchanged)               │
│  All 7 compliance layers remain intact                           │
├──────────────────────────────────────────────────────────────────┤
│              NEW: Cross-Repo Spec Bridge                         │
│  Main repo .planning/SPEC.md → mobile repo references           │
│  Via git submodule OR documented fetch convention                │
└──────────────────────────────────────────────────────────────────┘
```

---

## Component Responsibilities

### New Components (v0.14.0)

| Component | Type | Responsibility | Integration Point |
|-----------|------|----------------|-------------------|
| `silver-spec` | New skill | AI-guided spec elicitation — Socratic dialogue to produce REQUIREMENTS.md + SPEC.md + DESIGN.md | Invoked by silver-feature (Step 1c-i extension), directly by /silver router |
| `silver-ingest` | New skill | Pull JIRA ticket + linked artifacts (Figma, Google Docs, PPT) via MCP connectors; normalize to .md; store in .planning/ | Entry point alternative to silver-spec; can also be chained before silver-spec |
| `silver-validate` | New skill | Pre-build gap analysis: diff spec vs PLAN.md, surface assumptions, detect conflicts, surface missing acceptance criteria | Invoked by silver-feature between Steps 2.5 (writing-plans) and Step 3 (quality-gates) |
| `spec-floor-check.sh` | New hook (PreToolUse/Bash) | Block gsd-plan-phase if .planning/SPEC.md does not exist or fails minimum viability check; enforce on fast-path too via separate gate | Registered in hooks.json PreToolUse matcher on Bash |
| `pr-traceability.sh` | New hook (PostToolUse/Bash) | After gsd-ship: read .planning/SPEC.md frontmatter, append PR URL to spec's Implementations section, commit linkage | Registered in hooks.json PostToolUse matcher on Bash |
| `uat-gate.sh` | New hook (PreToolUse/Skill) | Block gsd-complete-milestone if gsd-audit-uat has not been run in this milestone session or its output contains FAIL | Registered in hooks.json PreToolUse matcher on Skill |
| SPEC.md | New artifact | Standardized spec output: problem statement, user personas, acceptance criteria, out-of-scope, open questions, linked PR list | Stored in .planning/ per repo |
| DESIGN.md | New artifact | UX flows, Figma references, visual specs extracted from ingestion | Stored in .planning/ per repo |

### Modified Components (v0.14.0)

| Component | Change | Rationale |
|-----------|--------|-----------|
| `silver-feature` | Insert silver-ingest (optional) before Step 1c, silver-validate between Steps 2.5 and 3, UAT gate check at Step 17 | New capabilities plug into existing orchestration at clearly defined seam points |
| `silver` router | Add routing rules for spec/ingest/validate intent signals | New skills need discoverability via the universal entry point |
| `silver-fast` | Add spec-floor check before Step 1: if SPEC.md absent and change is non-trivial, surface warning (not hard block — fast path intent is preserved) | Minimum spec floor feature H |
| `silver-bullet.md §2` | Add spec lifecycle section: when silver-spec runs, artifact locations, reference convention | Enforcement documentation layer |
| `hooks.json` | Register spec-floor-check, pr-traceability, uat-gate hooks | New hooks must be declared to fire automatically |

---

## Recommended Project Structure

```
silver-bullet/
├── skills/
│   ├── silver-spec/           # NEW: AI-driven spec elicitation
│   │   └── SKILL.md
│   ├── silver-ingest/         # NEW: JIRA/Figma/GDoc artifact ingestion
│   │   └── SKILL.md
│   ├── silver-validate/       # NEW: Pre-build spec validation
│   │   └── SKILL.md
│   ├── silver-feature/        # MODIFIED: 3 new steps inserted
│   │   └── SKILL.md
│   └── silver/               # MODIFIED: new routing rules
│       └── SKILL.md
├── hooks/
│   ├── spec-floor-check.sh    # NEW: blocks gsd-plan without spec
│   ├── pr-traceability.sh     # NEW: links PR to spec on ship
│   ├── uat-gate.sh            # NEW: blocks milestone-complete without UAT
│   └── hooks.json             # MODIFIED: register 3 new hooks
├── templates/
│   ├── silver-bullet.md.base  # MODIFIED: add spec lifecycle §2 extension
│   ├── specs/                 # NEW: spec output templates
│   │   ├── SPEC.md.template
│   │   ├── REQUIREMENTS.md.template
│   │   └── DESIGN.md.template
│   └── workflows/
│       └── full-dev-cycle.md  # MODIFIED: document spec steps
└── .planning/                 # Per-project (not in plugin, but referenced)
    ├── SPEC.md                # Produced by silver-spec or silver-ingest
    ├── REQUIREMENTS.md        # Produced by elicitation
    └── DESIGN.md              # Produced by Figma/UX ingestion
```

---

## Architectural Patterns

### Pattern 1: Skill as Step Wrapper (Existing, extend)

**What:** A skill invokes a sequence of GSD commands and other skills in a defined order. It never executes directly.

**When to use:** All new orchestration capabilities — silver-spec, silver-ingest, silver-validate all follow this pattern.

**Trade-offs:** Composable and testable. Each invoked step can be individually inspected. No direct implementation in the SKILL.md means the skill is purely orchestration.

**Example (silver-validate):**
```
Step 1: Read .planning/SPEC.md
Step 2: Read current PLAN.md (from gsd-plan-phase output)
Step 3: Run diff analysis (Claude intrinsic reasoning, not a tool call)
Step 4: Surface: gaps | conflicts | assumptions | missing ACs
Step 5: Ask user: A. Accept findings B. Return to silver-spec to close gaps
```

### Pattern 2: Hook as Hard Gate (Existing, extend)

**What:** A bash script registered in hooks.json fires before a specific tool use. Exit code non-zero blocks the tool call entirely.

**When to use:** spec-floor-check.sh (blocks gsd-plan without spec), uat-gate.sh (blocks milestone-complete without UAT). These must be zero-bypass — hooks cannot be skipped by user instruction unlike skill steps.

**Trade-offs:** Zero-bypass enforcement. Cannot be "turned off" by user preference §10. Adds latency to every matched tool call. Keep checks fast (file existence + simple parse, <100ms).

**Example (spec-floor-check.sh logic):**
```bash
# Check: does .planning/SPEC.md exist with minimum sections?
SPEC=".planning/SPEC.md"
if [ ! -f "$SPEC" ]; then
  echo "SPEC FLOOR VIOLATION: .planning/SPEC.md missing. Run /silver:spec before planning."
  exit 1
fi
# Check minimum viable sections present
for section in "## Problem Statement" "## Acceptance Criteria"; do
  if ! grep -q "$section" "$SPEC"; then
    echo "SPEC FLOOR VIOLATION: $SPEC missing section: $section"
    exit 1
  fi
done
exit 0
```

### Pattern 3: Artifact Normalization via Ingestion Skill

**What:** silver-ingest acts as an adapter — it pulls external artifacts (JIRA API via MCP, Figma via MCP, Google Docs via MCP) and normalizes them into the standard .planning/SPEC.md + DESIGN.md format. The downstream pipeline (silver-validate, silver-feature, gsd-plan-phase) always reads from .planning/ — never from external APIs directly.

**When to use:** Any external artifact source (JIRA, Figma, Google Docs, PPT). The MCP connectors are tool-level capabilities; the normalization logic lives in silver-ingest.

**Trade-offs:** Clean separation of ingestion from consumption. Adds a mandatory normalization step but means all downstream skills are source-agnostic. Requires MCP connectors to be installed (Claude Desktop JIRA MCP, Figma MCP, Google Workspace MCP) — silver-ingest should surface clear error if connector is unavailable.

### Pattern 4: Cross-Repo Spec Reference Convention

**What:** Main repo owns .planning/SPEC.md. Mobile repos reference it via a documented fetch convention — not a git submodule (too much overhead). Convention: at session start in a mobile repo, silver-ingest can be invoked with a GitHub raw URL to fetch and cache the main repo's SPEC.md into the mobile repo's .planning/SPEC.main.md (read-only, never modified locally).

**When to use:** Any mobile or satellite repo that implements features specified in the main repo.

**Trade-offs:** Simple to implement (file fetch, no submodule complexity). Requires convention discipline — mobile repo developers must know to run silver-ingest with the main repo URL. No automatic sync — mobile repos pull on demand. Accept this trade-off for v0.14.0; automatic sync is v2.

**Data flow:**
```
main-repo/.planning/SPEC.md
    → GitHub raw URL
    → silver-ingest --source-url <url> (in mobile repo session)
    → mobile-repo/.planning/SPEC.main.md (read-only cache)
    → silver-validate reads SPEC.main.md as authoritative spec
    → mobile PLAN.md must trace to SPEC.main.md requirements
```

---

## Data Flow

### Spec Creation Flow (Feature A + B + D)

```
User intent: "build X"
    ↓
/silver router
    ↓
silver-ingest (if JIRA ticket provided)
    → JIRA MCP → ticket + linked artifacts
    → Figma MCP → design files
    → Google Workspace MCP → docs/PPTs
    → normalize → .planning/SPEC.md + DESIGN.md
    ↓
silver-spec (if no JIRA, or to augment ingested draft)
    → Socratic elicitation dialogue
    → PM/BA provides answers
    → produces/extends .planning/REQUIREMENTS.md + SPEC.md
    ↓
.planning/SPEC.md (source of truth)
    ↓
silver-feature Step 1c (brainstorm reads SPEC.md as input)
```

### Pre-Build Validation Flow (Feature F)

```
silver-feature Step 2.5 (writing-plans / gsd-plan-phase output)
    ↓ PLAN.md created
silver-validate (NEW — inserted between Steps 2.5 and 3)
    → read .planning/SPEC.md
    → read current PLAN.md
    → diff: missing requirements, conflicting assumptions, untestable ACs
    → surface findings to user
    ↓
User decision:
    A. Approve → continue to Step 3 (quality-gates)
    B. Return to spec → invoke silver-spec to close gaps
    C. Accept risk → note exception in PLAN.md, continue
```

### PR Traceability Flow (Feature G)

```
gsd-ship completes (PostToolUse hook fires)
    ↓
pr-traceability.sh
    → read .planning/SPEC.md frontmatter for spec-id
    → read last git push output for PR URL
    → append to SPEC.md "## Implementations" section:
      - PR: <url> | Phase: <gsd-phase-id> | Date: <date>
    → git commit "trace: link PR <url> to SPEC.md"
```

### UAT Gate Flow (Feature I)

```
silver-feature Step 17 (milestone completion)
    ↓
gsd-audit-uat invoked (existing)
    ↓
uat-gate.sh (PreToolUse hook on gsd-complete-milestone)
    → check: was gsd-audit-uat run in this session?
    → check: did output contain FAIL?
    → if not run OR contains FAIL → block gsd-complete-milestone
    → message: "UAT gate: run /gsd:audit-uat and resolve failures before completing milestone"
```

### Spec Floor Flow on Fast Path (Feature H)

```
silver-fast Step 0 (complexity triage gate)
    + spec-floor-check.sh fires on gsd-fast Bash invocation (PreToolUse)
    → if SPEC.md absent: emit WARNING (not hard block on fast path)
    → fast path preserves its bypass intent
    → WARNING: "No SPEC.md found. Fast path proceeding without spec floor. For tracked work, run /silver:spec first."

silver-feature Step 6 (gsd-plan-phase Bash call)
    + spec-floor-check.sh fires (PreToolUse/Bash)
    → HARD BLOCK if SPEC.md absent or missing required sections
    → "Run /silver:spec or /silver:ingest before planning"
```

---

## Integration Points

### New Capabilities → Existing Architecture

| Capability | Integration Point | New Component | Existing Component Modified |
|------------|------------------|---------------|-----------------------------|
| A: JIRA ingestion | Before silver-feature Step 1c | silver-ingest skill | silver-feature: optional step 0.5 |
| B: AI-driven spec | Before silver-feature Step 1c | silver-spec skill | silver-feature: optional step 0.5, /silver router: new routes |
| C: External artifact ingestion | Within silver-ingest | silver-ingest (handles all sources) | None |
| D: Standardized spec output | Output of silver-spec/ingest | SPEC.md template + normalization logic in silver-ingest | silver-bullet.md §2: spec lifecycle docs |
| E: Multi-repo spec referencing | silver-ingest --source-url mode | silver-ingest (new flag/mode) | None |
| F: Pre-build validation | Between silver-feature Steps 2.5 and 3 | silver-validate skill | silver-feature: new Step 2.7 |
| G: PR traceability | PostToolUse on gsd-ship | pr-traceability.sh hook | hooks.json |
| H: GSD spec floor | PreToolUse on gsd-plan-phase + warning on gsd-fast | spec-floor-check.sh hook | hooks.json, silver-fast: warning path |
| I: UAT gate | PreToolUse on gsd-complete-milestone | uat-gate.sh hook | hooks.json, silver-feature Step 17 references gate |

### External Service Integration (via MCP)

| Service | MCP Connector | Ingestion in silver-ingest | Notes |
|---------|--------------|---------------------------|-------|
| JIRA | Claude Desktop JIRA MCP | Pull ticket + subtasks + linked artifacts | MCP must be installed by user; silver-ingest checks availability and fails gracefully |
| Figma | Claude Desktop Figma MCP | Pull frames/components from file URL | Figma MCP extracts design tokens, component names, layout annotations |
| Google Docs | Claude Desktop Google Workspace MCP | Pull doc content as markdown | Works for Docs and Slides (PPT equivalent) |
| GitHub (cross-repo) | gh CLI (already available) | Fetch raw SPEC.md from main repo | No MCP needed — gh CLI or curl to GitHub raw URL |

### Enforcement Integrity

All 7 existing compliance layers remain untouched. New hooks are additive:

| New Hook | Event | Matcher | Exit Behavior |
|----------|-------|---------|---------------|
| spec-floor-check.sh | PreToolUse | Bash | Exit 1 = hard block (on gsd-plan calls) |
| pr-traceability.sh | PostToolUse | Bash | Exit non-0 = warning only (PR already shipped) |
| uat-gate.sh | PreToolUse | Skill | Exit 1 = hard block (on gsd-complete-milestone) |

---

## Build Order and Dependencies

The capabilities have a clear dependency chain that dictates build order:

```
Phase 1: Foundation — Spec Artifacts
  Build: SPEC.md template, DESIGN.md template, REQUIREMENTS.md template
  Why first: All downstream capabilities depend on a known spec format.
             Nothing else can be validated/traced without this standard.

Phase 2: Ingestion — silver-ingest
  Build: silver-ingest skill (JIRA + Figma + Google Docs + cross-repo URL mode)
  Depends on: Phase 1 (knows the output format to produce)
  Registers: No new hooks yet — skill only

Phase 3: Spec Creation — silver-spec
  Build: silver-spec skill (Socratic elicitation → SPEC.md)
  Depends on: Phase 1 (output format), independent of Phase 2
  Can be built in parallel with Phase 2 if needed

Phase 4: Router Extension — /silver + silver-feature
  Build: Add routing rules to /silver, insert silver-ingest/silver-spec steps
         and silver-validate placeholder into silver-feature
  Depends on: Phases 2 and 3 (skills must exist before routing to them)

Phase 5: Pre-Build Validation — silver-validate + spec-floor hook
  Build: silver-validate skill, spec-floor-check.sh, register in hooks.json
  Depends on: Phase 1 (reads SPEC.md), Phase 4 (knows where in silver-feature it plugs in)

Phase 6: Traceability + UAT Gate — hooks
  Build: pr-traceability.sh, uat-gate.sh, register in hooks.json
  Depends on: Phase 1 (reads SPEC.md format for traceability), Phase 5 (spec floor in place)

Phase 7: silver-bullet.md + docs
  Build: Update §2 in silver-bullet.md.base with spec lifecycle, template parity
  Depends on: All above phases complete (documents the full flow)
```

---

## Anti-Patterns

### Anti-Pattern 1: Ingesting Directly Inside silver-feature

**What people do:** Embed JIRA MCP calls inside the silver-feature skill inline, rather than delegating to silver-ingest.

**Why it's wrong:** Violates the "orchestrate only, never implement" principle of SB skills. Makes JIRA ingestion unavailable as a standalone capability. Complicates the skill with API-specific logic that belongs in an adapter.

**Do this instead:** silver-feature calls silver-ingest via Skill tool (same as it calls gsd-plan-phase). silver-ingest owns all MCP connector logic and normalization.

### Anti-Pattern 2: Hard-Coding Spec Location Outside .planning/

**What people do:** Store SPEC.md in docs/ or project root for "visibility."

**Why it's wrong:** spec-floor-check.sh, pr-traceability.sh, and silver-validate all read from .planning/. Diverging the location breaks all three without config.

**Do this instead:** All spec artifacts live in .planning/. If visibility is needed, generate a docs/SPEC.md symlink or copy — but .planning/ is the source of truth.

### Anti-Pattern 3: Blocking Fast Path with Spec Floor

**What people do:** Make spec-floor-check.sh a hard block on gsd-fast (same as on gsd-plan-phase).

**Why it's wrong:** The fast path exists for trivial changes (typos, config, ≤3 files). A hard spec floor block on truly trivial work creates friction that defeats silver-fast's purpose and trains users to bypass the hook.

**Do this instead:** spec-floor-check.sh emits a WARNING (not exit 1) when triggered from gsd-fast context. The hook must detect context (check if $GSD_COMMAND == "fast" or similar env var) and downgrade to warning. Hard block only on gsd-plan-phase.

### Anti-Pattern 4: Git Submodule for Cross-Repo Spec

**What people do:** Add main repo as a git submodule in mobile repos to share SPEC.md.

**Why it's wrong:** Submodule management overhead is disproportionate for a single read-only markdown file. CI pipelines break, developers forget to update submodules, and mobile repos now have a hard dependency on main repo commit history.

**Do this instead:** silver-ingest --source-url fetches the raw file from GitHub at session start and caches it in .planning/SPEC.main.md. No submodule. No CI dependency. Refresh on demand.

### Anti-Pattern 5: Modifying GSD or Third-Party Plugin Files

**What people do:** Add spec-floor enforcement inside GSD's gsd-plan-phase command to guarantee it fires.

**Why it's wrong:** Violates §8 plugin boundary. GSD files must not be modified. This would also break on every GSD update.

**Do this instead:** The hook mechanism (PreToolUse on Bash) fires before any Bash call including those GSD makes internally. spec-floor-check.sh intercepts at the tool layer, above GSD — no GSD file modification needed.

---

## Scaling Considerations

This is a developer tooling plugin, not a user-facing service. "Scale" means: how does the architecture hold up as SB is used across many projects, many repos, and many team sizes?

| Concern | Current (single dev) | Team (5-20 devs) | Org (50+ devs) |
|---------|---------------------|-------------------|----------------|
| Spec conflicts | Not applicable | silver-validate catches within-repo conflicts; cross-repo is manual review | Need spec versioning convention (SPEC-v1.md, SPEC-v2.md) — future feature |
| Hook performance | Hooks run in ms | Same — hooks are stateless bash scripts | Same — no shared state to contend on |
| Cross-repo sync | Fetch on demand | Same, but mobile teams need sync trigger in silver-init | Automate sync via session-start hook (future) |
| JIRA MCP limits | Rate limits irrelevant | Per-developer MCP instance, no sharing | Same — MCP is per-session, not shared |

---

## Sources

- Direct inspection: `/Users/shafqat/Documents/Projects/silver-bullet/hooks/hooks.json` — existing 7-layer hook architecture
- Direct inspection: `skills/silver-feature/SKILL.md` — 17-step orchestration workflow, seam points identified
- Direct inspection: `skills/silver/SKILL.md` — router table and extension patterns
- Direct inspection: `skills/silver-fast/SKILL.md` — fast path bypass logic
- Direct inspection: `.planning/PROJECT.md` — v0.14.0 milestone scope, architecture principle "reuse via orchestration"
- Confidence: HIGH — all findings based on direct source inspection, no training data assumptions

---

*Architecture research for: Silver Bullet v0.14.0 AI-driven spec and multi-repo orchestration*
*Researched: 2026-04-09*
