---
name: silver-fast
description: "Trivial change fast-path: complexity triage confirms ≤3 files → gsd-fast → verify → commit. No planning overhead."
argument-hint: "<description of trivial change>"
---

# /silver:fast — Trivial Change Fast Path

SB fast-path for trivial changes only. Bypasses all workflow steps — no planning, no quality gates, no brainstorming, no review cycle.

**This skill is only appropriate for:**
- Typo or text fix
- Config value change (single key/value)
- Variable or symbol rename (≤3 files)
- One-liner code change
- Comment update

**Not appropriate for:**
- Any change touching >3 files
- Logic changes (even "small" ones)
- Dependency additions or removals
- Schema changes
- Changes with downstream impact

If in doubt, use the appropriate named workflow instead.

## Pre-flight: Banner

> **Note:** This workflow does NOT read §10 prefs. The fast path skips all preference overhead by design — preference loading adds latency that defeats the purpose of a trivial bypass.

Display banner:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 SILVER BULLET ► FAST PATH
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Change: {$ARGUMENTS or "(not specified)"}
```

## Step 0: Complexity Triage Gate

Before invoking gsd-fast, confirm the change is truly trivial.

Use AskUserQuestion:

> Confirming trivial scope for: **{$ARGUMENTS}**
>
> Does this change:
>
> A. Touch ≤3 files AND is a typo / config value / rename / one-liner? → proceed to fast path
> B. Touch >3 files OR involves logic, dependency, or schema changes? → escalate to full workflow

**If A (trivial confirmed):** proceed to Step 1.

**If B (non-trivial):** do NOT invoke gsd-fast. Instead:

1. Ask which workflow to route to using AskUserQuestion:

   > Which workflow should handle this?
   >
   > A. `silver:feature` — build or extend a feature
   > B. `silver:bugfix` — fix something that's broken
   > C. `silver:ui` — UI, frontend, or design work
   > D. `silver:devops` — infrastructure, CI/CD, or deployment
   > E. `silver:research` — technology decision or spike

2. Display: "This change exceeds the trivial threshold. Routing to [workflow name] instead."
3. Invoke the chosen named workflow via the Skill tool, passing `$ARGUMENTS`. Exit silver:fast.

**If scope is ambiguous** (cannot determine without investigation): treat as B — non-trivial. False trivial classifications cause under-reviewed changes. Escalate.

## Step 1: Execute Fast Path

**Only reached if Step 0 confirms A (trivial scope confirmed).**

Invoke `gsd-fast` via the Skill tool. Pass `$ARGUMENTS` as the change description.

## Step 2: STOP Condition — Scope Expansion Check

**During or after gsd-fast execution**, if scope expands beyond 3 files:

STOP immediately. Do not complete the change under the fast path. Display:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 SILVER BULLET ► FAST PATH STOP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Scope has expanded beyond 3 files. Fast path cannot continue.

Files now affected: {list}
```

Then use AskUserQuestion to escalate:

> The change has grown beyond the trivial threshold. Which workflow should take over?
>
> A. `silver:feature` — build or extend a feature
> B. `silver:bugfix` — fix something that's broken
> C. `silver:devops` — infrastructure or CI/CD change
> D. Stop — let me manually review scope before proceeding

Wait for user selection. If A, B, or C: invoke the chosen workflow via the Skill tool with the original `$ARGUMENTS`. If D: stop and return control to the user.

## Step 3: Verify

After gsd-fast completes (and scope remained ≤3 files throughout):

Run the verification command provided by gsd-fast output. If no automated verification is available, ask the user to confirm the change looks correct.

## Step 4: Confirm

Display completion summary:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 SILVER BULLET ► FAST PATH COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Change: {$ARGUMENTS}
Files modified: {count} (confirmed ≤3)
Status: committed
```
