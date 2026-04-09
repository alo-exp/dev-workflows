# Feature Research

**Domain:** AI-driven spec creation, JIRA ingestion, multi-repo orchestration, pre-build validation — agentic SDLC orchestrator
**Researched:** 2026-04-09
**Confidence:** MEDIUM (ecosystem patterns confirmed; SB-specific orchestration design is novel)

---

## Capability Area A: JIRA Ingestion

### Table Stakes

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Read JIRA ticket by ID via MCP | Teams expect AI to read what's already tracked | LOW | Atlassian MCP is available; endpoint migrates from /v1/sse → /v1/mcp after June 30 2026 — use /v1/mcp now |
| Extract title, description, acceptance criteria, labels, linked issues | Raw data needed for spec generation | LOW | JIRA MCP returns structured JSON; orchestration skill parses fields |
| Surface linked artifacts (Google Docs, Confluence pages) from ticket | Specs are rarely self-contained in JIRA; context lives elsewhere | MEDIUM | Requires follow-up fetches via Google Docs MCP or Confluence MCP; SB orchestrates chain |
| Display extracted ticket summary before proceeding | User must confirm what SB read before it runs | LOW | Verification step; prevents hallucination propagation |

### Differentiators

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Auto-classify ticket type (feature / bug / spike / chore) and route to correct SB workflow | Saves routing decision that currently requires human judgment | MEDIUM | Reuse silver router classification logic; add JIRA-context signals |
| Pull linked sub-tasks and treat as spec breakdown seed | Converts existing JIRA structure into SB phase outline automatically | MEDIUM | silver-feature Step 0 complexity triage can consume this |
| Cross-reference ticket with linked Confluence spec and flag inconsistencies | Catches drift between JIRA acceptance criteria and written spec | HIGH | Requires Confluence MCP + diff logic; strong differentiator vs Rovo Dev |

### Anti-Features

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Bidirectional JIRA sync (SB writes back to JIRA) | Feels complete | Creates write conflicts, permission risks, audit failures | SB generates a Markdown artifact; user pastes update to JIRA manually or via one-shot write at end of spec |
| Poll JIRA for updates during a session | "Always current" | Breaks determinism — mid-session ticket edits corrupt running context | Snapshot ticket at session start; treat as immutable input |

### Existing Skills to Reuse
- `silver` router (classification logic for ticket type → workflow)
- `silver-feature`, `silver-bugfix`, `silver-research` (downstream workflow targets after routing)

### New Skills Needed
- `silver-spec` — orchestration skill that wraps JIRA ingestion + spec creation pipeline (A+B+C+D)

---

## Capability Area B: AI-Driven Spec Creation

### Table Stakes

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Step-by-step requirements elicitation dialogue | PM/BA expects to be guided, not to know the questions | MEDIUM | Structured prompt sequence: problem statement → user goals → constraints → acceptance criteria |
| UX flow generation from requirements | Design step is part of spec, not separate | MEDIUM | Produces user-story-mapped flow; can reuse `design-handoff` Engineering/Design plugin |
| Assumption surfacing during elicitation | Critical gap — PMs often don't know what they're assuming | MEDIUM | Explicit "assumptions I'm making" list appended to each section |
| Structured .md output matching industry spec template | Repos need version-controllable specs, not chat transcripts | LOW | Template: Problem → Goals → Out of Scope → User Stories → UX Flow → Acceptance Criteria → Open Questions |

### Differentiators

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Multi-turn refinement loop (PM can push back, SB revises) | Spec quality requires iteration, not one-shot generation | MEDIUM | Session state management; .planning/spec-draft.md as live scratch |
| Spec versioning (v1, v2… tracked in git) | Audit trail for stakeholders | LOW | gsd-ship at end of each spec iteration; git history is the version log |
| Stakeholder-framing mode (write for eng vs write for exec) | Same spec, different audiences | LOW | Prompt parameter; reuse `stakeholder-update` skill framing |
| Guided brainstorm before spec (what should this feature even do?) | Many PMs arrive without clear problem definition | MEDIUM | Reuse `product-brainstorm` step already in silver-feature Step 1c |

### Anti-Features

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Fully autonomous spec (no PM input) | "Just generate a spec from the ticket" | Produces hallucinated requirements; uncatchable until implementation | Minimum 3 PM confirmation checkpoints in elicitation flow |
| Natural-language-only output (no structured .md) | Feels conversational | Breaks downstream validation and multi-repo referencing | Always produce structured .md; show conversational summary separately |

### Existing Skills to Reuse
- `product-brainstorm` (already in silver-feature; invoke before elicitation for fuzzy requests)
- `write-spec` (Engineering/Design plugin — invoke as sub-skill for formal output generation)
- `stakeholder-update` (framing for different audiences)
- `design-handoff`, `user-research` (Design plugin skills for UX flow generation)
- `architecture` (Engineering plugin — for technical constraints section of spec)

### New Skills Needed
- `silver-spec` orchestration skill (owns the elicitation dialogue, calls sub-skills above)

---

## Capability Area C: External Artifact Ingestion (Google Docs, PPT, Figma)

### Table Stakes

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Accept Google Doc URL, extract structured text for spec input | Teams store PRDs in Google Docs; SB must read them | MEDIUM | Google Docs MCP or Drive MCP; extract headings + body; skip embedded images initially |
| Accept Figma file URL, extract component hierarchy + design tokens | Designers deliver specs in Figma; engineers need structured output | MEDIUM | Figma MCP (available as of Jan 2026 interactive support); extracts spacing, colors, font tokens, Auto Layout, layer names |
| Incorporate artifact at any workflow step, not only at start | PMs add Figma links mid-spec; must not restart | MEDIUM | silver-spec maintains artifact registry; re-ingests and merges on demand |
| Summarize artifact before incorporating (user confirms) | Prevents bad input from silently corrupting spec | LOW | Show 3-bullet summary + ask "incorporate this?" |

### Differentiators

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Figma → acceptance criteria extraction (e.g., "button must be 44px minimum tap target") | Closes design-to-spec gap automatically | HIGH | Parse token values → derive testable criteria; HIGH value but HIGH complexity |
| Conflict detection between Figma and written spec | "Figma says modal, spec says drawer — which is authoritative?" | HIGH | Requires semantic comparison; flag conflicts, user resolves |
| PPT ingestion (extract slide titles + bullets as requirement seeds) | Stakeholder decks often contain implicit requirements | MEDIUM | Use file-read or export-to-text; lower fidelity than Figma MCP |

### Anti-Features

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Auto-apply Figma design tokens as CSS variables in the codebase | "Complete the loop" | Scope creep — this is silver-ui territory, not spec | Route to silver-ui after spec is finalized; keep spec pure |
| Parse image content from PPT slides | Full visual understanding | Unreliable without vision pipeline; results vary by slide design | Text-only extraction; flag "slides with only images — manual review needed" |

### Existing Skills to Reuse
- `silver-ui` (Figma → code implementation after spec is done; NOT during spec)
- `design-critique`, `accessibility-review` (Design plugin; invoke against extracted Figma output)

### New Skills Needed
- Artifact ingestion logic lives inside `silver-spec` as a sub-routine, not a standalone skill
- New router signal in `silver` for "I have a Figma/Google Doc/PPT" intent → `silver-spec`

---

## Capability Area D: Standardized Spec Output

### Table Stakes

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Single canonical .md spec file per feature in repo | Version-control spec alongside code | LOW | Location: `.planning/specs/{feature-slug}.md` |
| Spec template with fixed sections (Problem, Goals, Out of Scope, User Stories, UX Flow, Acceptance Criteria, Open Questions) | Industry standard; cross-team readability | LOW | Provide template in silver-bullet; generate via `write-spec` sub-skill |
| Spec metadata header (version, date, author, JIRA ticket ID, status) | Traceability requires structured metadata | LOW | YAML frontmatter block |
| Spec status lifecycle (Draft → Review → Approved → Implemented) | Stakeholders need to know spec state | LOW | Status field in frontmatter; updated by SB at workflow transitions |

### Differentiators

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Auto-generate spec from elicitation transcript (no human-authored .md) | PM never touches markdown | MEDIUM | SB synthesizes structured spec from elicitation dialogue; PM approves |
| Spec changelog (what changed between v1 and v2, highlighted) | Stakeholder review needs diff visibility | MEDIUM | Git diff + summarization; low implementation cost if git history is clean |

### Anti-Features

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| PDF export | "Non-technical stakeholders can't read .md" | Scope creep; requires toolchain; adds fragile step | Use GitHub/GitLab rendered markdown preview; link is shareable |
| Confluence auto-publish | "Single source of truth in Confluence" | Creates dual-write problem; spec in repo drifts from Confluence | Repo is source of truth; Confluence gets a link to the rendered spec |

### Existing Skills to Reuse
- `write-spec` (Engineering/Design plugin — primary sub-skill for .md generation)
- gsd-commit via `gsd-ship` (commits finalized spec to repo)

---

## Capability Area E: Multi-Repo Spec Referencing

### Table Stakes

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Mobile/sub-repos can reference main repo spec by relative or absolute URL | Avoids spec duplication; one source of truth | MEDIUM | Standard: spec URL in `.planning/specs/` of main repo; mobile repo reads via HTTP or git submodule |
| SB loads referenced spec at session start in mobile repo | Implementation sessions need full context without copy-paste | MEDIUM | silver-feature in mobile repo: detect spec reference, fetch, load into context |
| Surface spec-to-implementation gaps when starting work in mobile repo | Mobile team may receive spec after design changes | MEDIUM | Compare spec acceptance criteria against existing mobile codebase intel |

### Differentiators

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Spec lock version (mobile repo pins to spec v2; main repo is on v3) | Prevents mid-sprint spec drift from breaking mobile build | MEDIUM | Semver in spec frontmatter; mobile repo references pinned version |
| Cross-repo spec change notification (main spec updated — mobile repo has stale reference) | Prevents silent drift | HIGH | Requires either git webhook or SB pre-flight check at session start |

### Anti-Features

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Git submodule for specs | "Automatic sync" | Submodule conflicts are operationally painful; adds git complexity | Simple URL reference in silver-bullet.md §10 config; SB fetches on demand |

### Existing Skills to Reuse
- `silver-feature`, `silver-ui` (already run in mobile repos; add spec-load pre-flight step)
- `gsd-intel` (feeds mobile repo codebase understanding into spec gap analysis)

### New Skills Needed
- Spec reference resolution added to silver-feature pre-flight, not a standalone skill

---

## Capability Area F: Pre-Build Spec Validation

### Table Stakes

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Gap analysis (spec sections that are empty or too vague to implement) | Prevents mid-implementation "what does this mean?" blockers | MEDIUM | Heuristic: flag acceptance criteria with no measurable outcome; flag user stories with no actor |
| Assumption surfacing (implicit dependencies not stated in spec) | Uncaught assumptions are the #1 cause of spec-implementation mismatch | MEDIUM | Pattern: "assumes X exists", "assumes user is authenticated", etc. |
| Conflict detection (spec sections that contradict each other) | Silent contradictions surface as bugs, not spec errors | MEDIUM | Semantic comparison of acceptance criteria pairs; flag "Criteria A says X; Criteria B says not-X" |
| Hard stop if spec is below minimum viability threshold | Prevents implementation from starting on broken foundation | LOW | Configurable threshold (e.g., ≥3 user stories + ≥1 AC per story required) |

### Differentiators

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Spec score (0-100, weighted by completeness + clarity + testability) | Actionable quality signal for PM and engineering lead | MEDIUM | Scoring rubric embeds in silver-spec validation step |
| Auto-generate clarifying questions from gap analysis | PM gets a list of "before implementation starts, answer these" | LOW | High-value, low-complexity; just format the gap list as questions |
| Validation report as .md artifact | Audit trail before implementation kicks off | LOW | `.planning/specs/{slug}-validation.md`; committed with spec |

### Anti-Features

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Block gsd-plan unless spec passes validation | "Strict gate" | Over-constrains fast-path and urgent bugfixes | Warn prominently; allow override with explicit acknowledgment (logged to audit trail) |

### Existing Skills to Reuse
- `quality-gates` (8-dimension pattern — reuse rubric structure for spec scoring)
- `silver-research` (can investigate ambiguous spec assumptions via research workflow)

### New Skills Needed
- Validation logic lives in `silver-spec` as a phase ("validate" mode vs "create" mode)

---

## Capability Area G: PR → Spec Traceability

### Table Stakes

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| PR description includes spec reference (spec file path + version) | Reviewers need to know what spec drove implementation | LOW | silver-feature ship step: auto-append spec reference block to PR description |
| Commit messages reference spec slug (e.g., `spec: payment-flow-v2`) | Git history is traceable to requirements | LOW | Convention enforced in silver-feature gsd-commit step |
| Spec status updated to "Implemented" when PR merges | Closes the loop without manual tracking | MEDIUM | Post-merge hook or silver-release step updates spec frontmatter status |

### Differentiators

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| RTM (Requirements Traceability Matrix) auto-generated at release | Compliance teams need per-release traceability report | HIGH | silver-release generates .md RTM from spec + PR + commit cross-reference |
| CI gate blocks merge if PR has no spec reference | Enforces traceability without relying on discipline | MEDIUM | Pre-receive hook (pattern already in SB hook infrastructure); check PR body for spec block |

### Anti-Features

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| JIRA auto-transition to "Done" on PR merge | "Full automation" | Write-back to JIRA requires sensitive token scope; failure modes are loud | SB outputs "update JIRA ticket X to Done" as a user action item post-merge |

### Existing Skills to Reuse
- `silver-release` (already generates release notes; extend to include RTM section)
- `create-release` (already runs at milestone; add spec cross-reference to changelog)
- SB hook infrastructure (§7 hooks; add spec-reference pre-merge check)

---

## Capability Area H: GSD Minimum Spec Floor

### Table Stakes

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| silver-fast requires at minimum: one-line problem statement + one acceptance criterion | Fast-path should not mean spec-free | LOW | Add spec floor check to silver-fast Step 0; if missing, 30-second guided elicitation |
| silver-feature requires: full spec (all sections non-empty) before gsd-plan | Implementation without spec is undocumented guesswork | LOW | Already has quality-gates pre-flight; add spec-completeness check |
| Spec floor violation is a warning, not a hard block, with explicit acknowledgment | Urgent production fixes can't wait for full spec | LOW | Override requires typing "OVERRIDE: [reason]"; reason logged to audit trail |

### Differentiators

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Configurable spec floor per workflow type in silver-bullet.md §10 | Teams have different standards for bugfixes vs features | LOW | §10 already supports per-workflow preferences; extend with spec floor config |

### Existing Skills to Reuse
- All SB orchestration skills (spec floor check is a shared pre-flight block, added to each)
- `quality-gates` rubric structure for floor definition

---

## Capability Area I: UAT as Formal Pipeline Gate

### Table Stakes

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| UAT checklist auto-generated from spec acceptance criteria | Manual UAT checklist writing is error-prone and skipped | MEDIUM | Map each AC → one UAT test case; produce as .md checklist |
| UAT gate in silver-release: implementation must be verified against spec before ship | Release without UAT is de facto no UAT | MEDIUM | silver-release pre-flight: load spec + load UAT results + compare |
| UAT result captured as .md artifact (pass/fail per criterion) | Audit trail for stakeholders and compliance | LOW | `.planning/specs/{slug}-uat.md`; committed before release |

### Differentiators

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| AI-assisted UAT execution (SB walks tester through each criterion interactively) | Non-technical testers can run structured UAT without knowing the spec format | MEDIUM | Guided mode in silver-release: show criterion, tester confirms pass/fail, SB records |
| Regression UAT (re-run prior spec ACs when related code changes) | Catches regressions that automated tests miss | HIGH | Requires spec-to-code mapping; defer to v2 |

### Anti-Features

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Automated UAT (AI self-signs off) | "Remove human from loop" | UAT exists precisely because AI-written code can be technically correct but wrong for the user | Human confirmation required per criterion; AI facilitates, human decides |

### Existing Skills to Reuse
- `silver-release` (extend to include UAT gate pre-flight)
- `testing-strategy` (Engineering plugin — invoke for UAT test case design)
- `gsd-verify-work` (already a non-skippable gate; extend verification checklist with spec AC coverage)

---

## Feature Dependencies

```
[A: JIRA Ingestion]
    └──feeds──> [B: AI-Driven Spec Creation]
                    └──produces──> [D: Standardized Spec Output]
                                       └──enables──> [E: Multi-Repo Referencing]
                                       └──enables──> [F: Pre-Build Validation]
                                                          └──gates──> implementation start
                                       └──enables──> [G: PR Traceability]
                                       └──enables──> [I: UAT Gate]

[C: External Artifact Ingestion]
    └──feeds──> [B: AI-Driven Spec Creation] (at any point)

[H: Minimum Spec Floor]
    └──requires──> [D: Standardized Spec Output] (knows what "minimum" means)
    └──applies-to──> all SB orchestration workflows (silver-feature, silver-bugfix, silver-fast)

[F: Pre-Build Validation]
    └──requires──> [D: Standardized Spec Output]
    └──gates──> [G: PR Traceability] (nothing to trace without a valid spec)

[I: UAT Gate]
    └──requires──> [D: Standardized Spec Output]
    └──requires──> [F: Pre-Build Validation] (implementation must have started from valid spec)
    └──gates──> silver-release
```

### Dependency Notes

- **A is optional** — B can run without JIRA if PM provides context manually; A is an accelerator, not a prerequisite for B.
- **D is the linchpin** — E, F, G, H, I all assume a canonical .md spec exists. D must be in Phase 1.
- **C is additive at any phase** — Figma/Google Doc ingestion enriches B but does not block it.
- **H is a horizontal concern** — applies to all orchestration skills; implement as a shared pre-flight block, not a standalone phase.
- **F before implementation** — validation must fire before gsd-plan, not after.

---

## MVP Definition (v0.14.0)

### Launch With (Phase 1 — Foundation)

- [x] D: Standardized spec output — template + .md generation via write-spec sub-skill
- [x] B: AI-driven spec creation — silver-spec skill with elicitation dialogue
- [x] H: Minimum spec floor — spec floor check added to silver-feature, silver-fast
- [x] F: Pre-build validation (basic) — gap analysis + assumption surfacing; no conflict detection yet

### Add After Foundation (Phase 2 — Ingestion)

- [x] A: JIRA ingestion — MCP connector + ticket-to-spec pipeline
- [x] C: External artifact ingestion — Figma MCP + Google Docs MCP + artifact registry in silver-spec

### Complete the Pipeline (Phase 3 — Traceability + Gates)

- [x] G: PR traceability — spec reference in PR description + commit convention
- [x] E: Multi-repo spec referencing — spec load pre-flight in mobile repo workflows
- [x] I: UAT gate — UAT checklist from AC + UAT artifact + silver-release pre-flight gate

---

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| D: Standardized spec output | HIGH | LOW | P1 |
| B: AI-driven spec creation (silver-spec skill) | HIGH | MEDIUM | P1 |
| H: Minimum spec floor | HIGH | LOW | P1 |
| F: Pre-build validation (gap + assumptions) | HIGH | MEDIUM | P1 |
| A: JIRA ingestion | MEDIUM | MEDIUM | P2 |
| C: External artifact ingestion (Figma + Docs) | MEDIUM | MEDIUM | P2 |
| G: PR traceability (spec reference in PR) | HIGH | LOW | P2 |
| E: Multi-repo spec referencing | MEDIUM | MEDIUM | P2 |
| I: UAT gate | HIGH | MEDIUM | P2 |
| F: Conflict detection in validation | MEDIUM | HIGH | P3 |
| G: RTM auto-generation at release | MEDIUM | HIGH | P3 |
| Figma → AC extraction (design tokens → criteria) | HIGH | HIGH | P3 |
| Regression UAT (spec-to-code mapping) | HIGH | HIGH | P3 |

---

## Reuse vs New Skills Summary

| Capability | Reuse | New Required |
|------------|-------|-------------|
| JIRA ingestion | silver router (classification), silver-feature (downstream target) | silver-spec (ingestion + routing sub-routines) |
| AI-driven spec creation | write-spec, product-brainstorm, user-research, design-handoff, stakeholder-update, architecture | silver-spec (orchestration skill owning elicitation dialogue) |
| Figma/Docs ingestion | silver-ui (post-spec), design-critique, accessibility-review | Artifact ingestion sub-routine inside silver-spec |
| Standardized spec output | write-spec, gsd-ship (commit) | Spec template file; metadata frontmatter convention |
| Multi-repo referencing | silver-feature, silver-ui, gsd-intel | Pre-flight spec-load block added to existing skills |
| Pre-build validation | quality-gates (rubric structure), silver-research (for ambiguous assumptions) | Validation phase inside silver-spec; spec score rubric |
| PR traceability | silver-release, create-release, SB hook infrastructure | PR description spec-block template; post-merge status hook |
| Minimum spec floor | quality-gates (rubric), all orchestration skills (add pre-flight) | Shared spec-floor-check block; §10 config extension |
| UAT gate | silver-release, testing-strategy, gsd-verify-work | UAT checklist generator; UAT artifact template; release pre-flight extension |

**Single new skill: `silver-spec`** — owns A+B+C+D orchestration. All other capabilities are extensions to existing skills or new pre-flight blocks.

---

## Sources

- [Atlassian Rovo Dev — Agentic Workflow (JIRA MCP patterns)](https://community.atlassian.com/forums/Atlassian-AI-Rovo-articles/A-Deep-Dive-into-Rovo-Dev-and-Atlassian-AI-s-Agentic-Workflow/ba-p/3140356)
- [Jira MCP Integration Guide — Composio](https://composio.dev/content/jira-mcp-server)
- [Claude Code + Figma MCP — Medium 2026](https://medium.com/design-bootcamp/how-to-connect-claude-code-with-figma-mcp-d7f543b49f76)
- [How a Traceability Matrix Fits into Modern CI/CD — Medium 2026](https://medium.com/@sancharini.panda/how-a-traceability-matrix-fits-into-modern-ci-cd-workflows-714c5a6862af)
- [Spec-Driven AI SDLC — Infogain](https://www.infogain.com/blog/cracking-spec-driven-development-our-adobe-commerce-cloud-journey/)
- [AI-Driven SDLC Best Practices 2026 — MetaCTO](https://www.metacto.com/blogs/mapping-ai-tools-to-every-phase-of-your-sdlc)
- [Requirements Traceability Matrix — Perforce](https://www.perforce.com/resources/alm/requirements-traceability-matrix)
- [Claude Code MCP Connectors — claude.ai docs](https://code.claude.com/docs/en/mcp)

---
*Feature research for: Silver Bullet v0.14.0 — AI-Driven Spec & Multi-Repo Orchestration*
*Researched: 2026-04-09*
