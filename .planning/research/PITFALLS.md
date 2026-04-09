# Pitfalls Research

**Domain:** AI-driven spec creation, external artifact ingestion, multi-repo orchestration, pre-build validation — added to existing agentic SDLC orchestrator (Silver Bullet v0.14.0)
**Researched:** 2026-04-09
**Confidence:** MEDIUM (WebSearch verified with official sources; SB-specific integration risks derived from architecture analysis)

---

## Critical Pitfalls

### Pitfall 1: Spec Creation Becomes Process Theater

**What goes wrong:**
SB guides PM/BA through a multi-step elicitation workflow that produces a well-formatted `.md` spec file, but the output is a paper artifact with no semantic connection to what actually gets built. The AI fills in gaps with plausible-sounding assumptions, the PM approves without scrutiny because the format looks professional, and implementation proceeds from a document that says what the AI guessed rather than what the stakeholder meant. This is what Thoughtworks flags as "a bias toward heavy up-front specification" — the workflow looks rigorous but produces false confidence.

**Why it happens:**
Spec creation is optimized for format compliance (does the file exist? does it have all sections?) rather than semantic fidelity (does this match what the stakeholder actually needs?). LLMs are excellent at producing well-structured documents from partial information; that strength becomes a liability when the output cannot be distinguished from a genuinely complete spec.

**How to avoid:**
- Elicitation must surface explicit unknowns, not fill them. Every gap the AI cannot resolve from provided context must become a named `[ASSUMPTION: ...]` block inline in the spec, not a plausible placeholder.
- Gate the spec-creation skill on stakeholder sign-off of assumption blocks specifically — not just the full document.
- The GSD minimum spec floor (feature H) must validate assumption density, not just section presence. A spec with zero assumption blocks on a complex feature is a red flag, not a success signal.
- Use the pre-build validation gate (feature F) to re-surface assumption blocks at implementation start, not just at spec-creation time.

**Warning signs:**
- Spec files have no `[ASSUMPTION:]` blocks despite complex or ambiguous input
- PM sign-off happens in under 5 minutes on a multi-section spec
- Spec uses future-tense vague language ("the system will handle...") without concrete acceptance criteria
- Elicitation conversation ends without any stakeholder questions being asked back

**Phase to address:**
Spec creation phase (Feature B). Elicitation skill must be designed assumption-first from the start. Cannot be retrofitted after the output format is established.

---

### Pitfall 2: MCP Connector Instability Breaks the Ingestion Pipeline

**What goes wrong:**
JIRA, Figma, and Google Docs MCP connectors are treated as stable APIs. When a connector times out, returns partial data, or the external tool changes its schema, the ingestion skill fails silently or mid-session. The user is left with a partially-ingested artifact and no clear recovery path. Because SB's enforcement model is hook-based, a failed ingestion that doesn't throw a hard error passes enforcement checks while producing a degraded spec.

**Why it happens:**
MCP servers for third-party tools (Figma, Atlassian) are rapidly evolving — Figma launched its MCP server in early 2026, Atlassian MCP integration is still maturing. Early MCP implementations have inconsistent error surfaces. The "use MCP connectors, not custom API integrations" architectural principle (correct long-term) means SB inherits whatever instability exists in the connector layer.

**How to avoid:**
- Treat every MCP ingestion call as failable. Skills must distinguish between: (a) connector not configured, (b) connector returned empty, (c) connector returned partial data, (d) connector returned error.
- Each ingestion skill must produce a manifest of what was ingested and what was skipped/failed, written to the spec directory alongside the artifact.
- Never let ingestion failure silently produce an empty section in a spec. Missing artifact = explicit `[ARTIFACT MISSING: reason]` block.
- Do not chain ingestion steps without checkpointing. If Figma ingestion fails after JIRA succeeds, the session must be resumable from the JIRA checkpoint.

**Warning signs:**
- Ingestion skill has no explicit error-state outputs
- Spec sections reference external artifacts without a manifest file showing what was actually retrieved
- No retry or fallback path when MCP server returns empty
- Skills assume MCP tool calls succeed without checking return value

**Phase to address:**
JIRA ingestion phase (Feature A) and external artifact ingestion phase (Feature C). Error surface design must be first-class, not an afterthought.

---

### Pitfall 3: Multi-Repo Spec Referencing Creates Stale Truth

**What goes wrong:**
Main repo holds the canonical spec. Mobile repos reference it via path, symlink, or copy. Over time: main repo spec is updated, mobile repos are not notified, implementations in mobile repos proceed against stale spec. There is no semantic conflict — code compiles, tests pass — but three implementations encode different assumptions. This is the "agentic drift" failure mode documented in multi-agent research: invisible divergence that only surfaces at integration time.

**Why it happens:**
Cross-repo coordination requires active synchronization. Passive reference (a path in a config file pointing to another repo's spec) provides no mechanism for change notification. Teams assume the reference is live; it is actually a snapshot at the time of last clone or copy.

**How to avoid:**
- Main repo specs must carry a version header (`spec-version:`) that changes on any material update.
- Mobile repo spec-referencing skill must validate the referenced spec version against a stored baseline at session start. Version mismatch = blocked session with diff summary.
- The pre-build validation gate (Feature F) must run cross-repo spec consistency as a first check, not an afterthought.
- Avoid symlinks and path references entirely. The canonical pattern is: main repo spec → versioned artifact with explicit version pin in mobile repo config. Mobile repo owner must explicitly bump the pin after reviewing the diff.
- UAT gate (Feature I) must compare implementation against the spec version that was pinned at build start, not the current spec version.

**Warning signs:**
- Mobile repo references main repo spec without a pinned version
- No notification mechanism when main repo spec changes
- Pre-build validation skips cross-repo checks for speed
- UAT compares against "current spec" rather than "spec at build time"

**Phase to address:**
Multi-repo spec referencing phase (Feature E) — version protocol must be established before any mobile repo integration work begins.

---

### Pitfall 4: Pre-Build Validation Gate Becomes a Rubber Stamp

**What goes wrong:**
The gap-analysis and conflict-detection gate runs, produces a report, and the session proceeds regardless of findings. Users learn that the gate always completes (never actually blocks) and treat it as noise. Within a few weeks it is universally skipped via the fast-path. This is the "too many manual approval steps slow delivery" antipattern — a gate that doesn't gate.

**Why it happens:**
Gate designers are reluctant to make hard blocks because they fear false positives blocking legitimate work. The compromise is a soft-gate: it reports but doesn't stop. Soft gates lose enforcement power immediately because users learn they can ignore them.

**How to avoid:**
- Define a two-tier model at design time: **hard blocks** (missing required spec section, unresolved assumption block that maps to a blocking dependency) vs. **soft warnings** (style issues, non-critical gaps). Hard blocks must halt the session. Soft warnings must be acknowledged by name, not dismissed globally.
- The gate must produce a machine-readable output (not just prose) that downstream skills can consume to verify which findings were resolved vs. deferred.
- Gate findings that were deferred must auto-surface at PR-creation time via the traceability link (Feature G). You cannot defer a hard-block finding without it appearing in the PR description.
- Calibrate the gate with real spec samples before shipping. If the gate hard-blocks more than 30% of clean specs in testing, the blocking criteria are miscalibrated — fix the criteria, not the gate model.

**Warning signs:**
- Gate output is prose-only with no structured finding objects
- No distinction between blocking and non-blocking findings
- Fast-path bypasses the gate entirely without recording that it was bypassed
- Gate completion metric is tracked but not gate-block metric

**Phase to address:**
Pre-build validation phase (Feature F). Gate architecture (hard vs. soft) must be decided before implementation, not after first user complaints.

---

### Pitfall 5: GSD Minimum Spec Floor Breaks the Fast-Path Value Proposition

**What goes wrong:**
The fast-path (`/silver fast`) exists because sometimes a developer needs to ship a small, well-understood change without full SDLC ceremony. Adding a minimum spec floor that requires a formatted spec document to be present before GSD execution turns fast-path into slow-path with a different label. Developers bypass it entirely, undermining both the spec floor and the fast-path's legitimate use case.

**Why it happens:**
Enforcement designers apply the same spec requirements uniformly across all workflows because consistency is easier than calibration. The result is a floor designed for feature work applied to a bug fix or a config change, where the overhead is disproportionate to the risk.

**How to avoid:**
- The minimum spec floor must be calibrated by change type, not applied uniformly. A bug fix in a single file needs a different floor than a new feature spanning three services.
- Fast-path must have its own explicit, minimal spec format — not a subset of the full spec. A three-field inline spec (problem statement, proposed change, acceptance test) is a valid spec floor for fast-path. Requiring a full spec document is not.
- The floor must be machine-checkable in under 10 seconds. If spec floor validation requires AI inference (reading prose for completeness), it is not a floor, it is a gate — apply the gate model instead.
- Record fast-path sessions that bypassed the spec floor with an explicit audit trail. Do not silently allow bypass; require an explicit override with a one-line reason. This preserves enforcement integrity without blocking work.

**Warning signs:**
- Fast-path spec floor uses the same schema as full spec
- Fast-path floor validation takes longer than 10 seconds
- No distinction between a floor (minimum present) and a gate (quality assessed)
- Users report that `/silver fast` takes as long as `/silver feature`

**Phase to address:**
GSD minimum spec floor phase (Feature H). Must be designed in parallel with the full spec workflow, not adapted from it afterward.

---

### Pitfall 6: New Spec Skills Break Existing 7-Layer Enforcement

**What goes wrong:**
New spec-creation and ingestion skills are added as orchestration commands that invoke GSD execution. Somewhere in the wiring, a hook that was previously always-on is not triggered (because the new skill invokes a GSD sub-command differently), or a quality gate is bypassed because the new skill produces outputs in a format the existing gate does not recognize. Enforcement appears intact because hooks still fire, but the new code paths have holes.

**Why it happens:**
Existing enforcement was designed around the full-dev-cycle and devops-cycle workflow paths. New skills that create specs rather than code follow a different execution path — they may not trigger the same hook sequence. The 7-layer model assumes all meaningful work flows through the enforcement-wired paths; new paths that bypass that flow inherit none of the enforcement.

**How to avoid:**
- Before implementing any new skill, map its execution path against the 7-layer enforcement model and identify which layers it touches vs. which it bypasses.
- Spec-creating skills must be treated as writing-phase equivalents: they produce artifacts (spec files) that are subject to enforcement just as code files are.
- Template parity constraint already exists for `docs/workflows/` vs `templates/workflows/` — extend this pattern to spec templates: a `templates/specs/` canonical form that spec skills must produce against, allowing gate validation of spec outputs.
- Run the full hook suite against a new skill's output in a dry-run mode before shipping. Document which enforcement layers were exercised.

**Warning signs:**
- A new skill is added without a corresponding enforcement coverage map
- Spec files are written to the repo without going through any quality gate
- Hook firing is verified for the happy path only, not the error/partial path
- SENTINEL security hardening (P-1 through P-7) has not been reviewed for new MCP ingestion paths that introduce external data into the repo

**Phase to address:**
Every phase. This is an integration risk that applies to each new feature (A through I). Each feature's implementation phase must include an enforcement coverage verification step before merge.

---

### Pitfall 7: PR-to-Spec Traceability Becomes a Post-Hoc Annotation

**What goes wrong:**
Traceability is implemented as a PR description template that asks developers to fill in which spec drove the implementation. Developers either leave it blank, fill it in incorrectly from memory, or link to the wrong spec version. The result is a traceability log that is factually unreliable — it has the appearance of audit trail without the substance.

**Why it happens:**
Traceability implemented as a human-filled form is always unreliable. Humans fill in forms at PR creation time under time pressure, from memory, with no validation that the link is correct.

**How to avoid:**
- Traceability must be machine-generated, not human-filled. The implementation session must record the spec artifact and version that was active at session start. The PR-creation skill reads this session record and auto-populates the traceability link.
- The session record must be written at session start, not at session end. If it is written at end, it can be omitted when a session ends abnormally.
- Traceability link validation must be a gate at PR creation: if no session record exists for the branch, the PR description must contain a manual override with explicit reason, not just an empty field.
- The PR-to-spec link must reference the pinned spec version (from the multi-repo versioning protocol), not the current head of the spec file.

**Warning signs:**
- Traceability is implemented as a PR template field
- No session record is written at the start of implementation sessions
- Traceability links point to file paths rather than versioned artifacts
- No validation that a linked spec file actually exists at link creation time

**Phase to address:**
PR-to-spec traceability phase (Feature G). Must be designed from the session-record pattern, not from the PR-description pattern.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Spec floor = subset of full spec schema | Faster to implement, single schema to maintain | Fast-path overhead grows with full spec; developers bypass | Never — design separate minimal spec schema for fast-path |
| Ingestion errors reported as warnings, not failures | No false-positive session blocks | Degraded specs pass enforcement; silent quality decay | Never for artifact-referenced spec sections |
| Multi-repo spec reference = file path with no version | Simple to implement, works immediately | Spec drift undetectable until integration failure | Never for specs that drive mobile implementation |
| Pre-build gate = soft-report-only | No blocked sessions in early rollout | Gate ignored within weeks; zero enforcement value | Never — if it doesn't block, it's a report, not a gate |
| Traceability = PR template field | Zero implementation cost | Unreliable data from day one | Never if traceability is claimed as a compliance feature |
| Assumption blocks = optional | Cleaner spec documents | Process theater; false confidence in spec completeness | Never for cross-functional or external-facing features |

---

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| JIRA MCP | Assume ticket fields map cleanly to spec sections | JIRA fields are org-specific; build a field mapping config, default to `[UNMAPPED]` not empty |
| Figma MCP | Treat Figma file as read-only design source | Figma MCP is write-capable (as of 2026); scope connector permissions to read-only explicitly |
| Google Docs MCP | Pull full document content into spec context | Documents can be large; extract only linked sections, record extraction boundaries in manifest |
| Multi-repo ref | Use relative file paths | Paths break when repo is cloned to different directory; use repo-root-relative paths with repo identifier |
| MCP connector auth | Store tokens in env vars with no rotation | MCP connector tokens must be scoped, documented in SB setup, and not embedded in skill files |
| JIRA ticket ingestion | Ingest linked artifacts automatically | Linked artifacts (PPT, Figma, Docs) need explicit user confirmation before ingestion — scope creep risk |

---

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Pre-build gap analysis runs full spec diff on every session start | Sessions feel slow; users skip spec floor | Run gap analysis incrementally on changed sections only | Immediately on any spec > 5 sections |
| Multi-repo spec validation fetches all referenced specs at session start | Long session startup in mobile repos | Cache spec versions locally with TTL; only re-fetch on version mismatch signal | On first multi-repo project with 3+ repos |
| MCP ingestion is synchronous in session startup | Session hangs if external tool is slow | Run ingestion as async background task with inline placeholder; user continues when ready | On any JIRA instance with slow API response |
| Elicitation conversation history grows unbounded | Spec creation sessions hit context limits in long elicitation | Summarize conversation history at each elicitation checkpoint | On features requiring more than 10 elicitation turns |

---

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| JIRA ticket content written verbatim into repo spec files | Sensitive JIRA content (customer PII, internal pricing) lands in repo history | Sanitization step: user reviews extracted content before it is committed to repo |
| Figma connector granted write permissions | Agent could modify design files during ingestion | Scope Figma MCP to read-only; document required permission scope in SB setup |
| Google Docs content from shared links with no auth check | Pulls content from a doc the user shouldn't have access to | Validate that the authenticated user has explicit access to each doc before ingestion |
| Spec files contain assumption blocks with internal business logic | Internal architecture/pricing details in public-facing repo specs | SENTINEL P-7 check must cover spec files, not just code files |
| Session records written with full MCP response payloads | Large sensitive payloads in repo commit history | Session records store metadata only (artifact ID, version, timestamp) — never raw MCP response body |

---

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Elicitation asks all questions upfront in a single prompt | PM/BA overwhelmed; gives short answers to escape the form | One-question-at-a-time elicitation with context-aware follow-up based on previous answer |
| Spec floor error message says "spec missing" without saying what's missing | Developer re-reads every spec section looking for the gap | Error must name the specific missing field and provide a fill-in template |
| Multi-repo version mismatch blocks session with no diff shown | Developer has no idea what changed in the main spec | Block must include a one-screen diff summary of what changed between pinned version and current |
| Pre-build validation report is prose-only | Developer reads it once, cannot act on it systematically | Report must include a numbered finding list with finding-ID for tracking deferred items |
| Fast-path override requires a reason but gives no examples | Developer writes "quick fix" which provides no audit value | Provide 3-5 suggested override reasons with a free-text option |

---

## "Looks Done But Isn't" Checklist

- [ ] **Spec creation:** Has assumption detection — verify that a complex input with 3+ ambiguities produces at least 3 `[ASSUMPTION:]` blocks, not a clean spec
- [ ] **JIRA ingestion:** Has ingestion manifest — verify that after ingestion, a `INGESTION_MANIFEST.md` exists in the spec directory listing what was retrieved and what was skipped
- [ ] **Multi-repo referencing:** Has version pinning — verify that mobile repo config contains a spec version pin, not a file path
- [ ] **Pre-build validation:** Has hard-block behavior — verify that a spec with a missing required section actually halts the session, not just logs a warning
- [ ] **Fast-path floor:** Has separate schema — verify that the fast-path spec format is a distinct file from the full spec format, not a subset of the same schema
- [ ] **PR traceability:** Is machine-generated — verify that the traceability link in the PR was written by the session record, not by a PR template field
- [ ] **Enforcement coverage:** New skills covered — verify that each new skill has a documented enforcement coverage map showing which of the 7 layers it exercises
- [ ] **UAT gate:** Uses pinned spec — verify that UAT compares implementation against the spec version pinned at build start, not the current spec head

---

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Spec theater already shipped (no assumption tracking) | HIGH | Retroactively audit existing specs for assumption density; add assumption extraction as a required re-validation step before next build |
| MCP instability caused corrupted spec | LOW | Ingestion manifest makes recovery mechanical: re-run failed ingestion steps from manifest, patch missing sections |
| Multi-repo spec drift already occurred | MEDIUM | Run cross-repo gap analysis as a one-time audit; require explicit version re-pin from mobile repo owner with diff acknowledgment |
| Pre-build gate became rubber stamp | MEDIUM | Introduce hard-block criteria in a new gate version; communicate criteria in advance; run one calibration sprint with real specs before enforcing |
| Fast-path bypass habit formed | LOW | Add bypass audit trail retroactively; surface bypass frequency in a session stats report; adjust floor criteria if bypass rate is high for legitimate reasons |
| Enforcement gap in new skill | MEDIUM | Map skill execution path against 7-layer model; add missing hook triggers; run regression on existing workflows to confirm no hook regressions introduced |

---

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Spec creation as process theater | Feature B (AI-driven spec creation) | Elicitation skill produces assumption blocks on ambiguous input in testing |
| MCP connector instability | Feature A (JIRA ingestion), Feature C (artifact ingestion) | Simulated connector failure produces explicit error output, not silent empty section |
| Multi-repo spec drift | Feature E (multi-repo referencing) | Mobile repo session blocked when spec version pin mismatches main repo current version |
| Pre-build gate rubber stamp | Feature F (pre-build validation) | Session halted when required spec section is absent; finding logged in machine-readable format |
| Spec floor breaking fast-path | Feature H (GSD minimum spec floor) | Fast-path session with 3-field inline spec passes floor check in under 10 seconds |
| New skills breaking enforcement | All phases (A through I) | Enforcement coverage map documented and reviewed before each feature merges |
| Traceability as post-hoc annotation | Feature G (PR-to-spec traceability) | PR traceability link is populated from session record, not PR template, on first implementation session |
| UAT against wrong spec version | Feature I (UAT gate) | UAT uses spec version pinned at build start; version mismatch with current spec produces a warning in UAT report |

---

## Sources

- Thoughtworks Technology Radar Vol. 33 (2025): Spec-driven development in "Assess" ring, heavy up-front specification antipattern
- DEV Community: [Agentic Drift — It's Hard to Be Multiple Developers at Once](https://dev.to/helgesverre/agentic-drift-its-hard-to-be-multiple-developers-at-once-4872) — semantic conflict in parallel agent work
- AgileVerify: [Quality Gates in CI/CD: What Should Really Block a Release in 2026](https://agileverify.com/quality-gates-in-ci-cd-what-should-really-block-a-release-in-2026/) — hard vs. soft gate model
- Figma Blog: [Introducing Figma MCP Server](https://www.figma.com/blog/introducing-figma-mcp-server/) — write capability risk, Feb 2026
- SiliconANGLE: [Atlassian embeds agents into Jira and embraces MCP](https://siliconangle.com/2026/02/25/atlassian-embeds-agents-jira-embraces-mcp-third-party-integrations/) — MCP maturity status
- Augment Code: [What Is Spec-Driven Development](https://www.augmentcode.com/guides/what-is-spec-driven-development) — static spec failure modes (4 documented types)
- arxiv 2512.08296: Towards a Science of Scaling Agent Systems — coordination tax in multi-agent information fragmentation
- CommBank Technology / Medium: [Enforcing Compliance While Retaining Agency](https://medium.com/commbank-technology/enforcing-compliance-while-retaining-agency-a-rule-based-policy-engine-approach-for-react-agents-a9a8a1b4a88c) — policy enforcement non-determinism in agentic systems
- SB PROJECT.md architecture analysis: plugin boundary constraint (§8), enforcement integrity constraint, GSD/SB separation of concerns

---
*Pitfalls research for: AI-driven spec creation, external artifact ingestion, multi-repo orchestration, pre-build validation — Silver Bullet v0.14.0*
*Researched: 2026-04-09*
