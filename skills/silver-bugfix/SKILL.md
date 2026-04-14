---
name: silver-bugfix
description: "SB-orchestrated bug investigation and fix: triage → path A/B/C → TDD regression test → plan → execute → review → verify → ship"
argument-hint: "<description of the bug or failure>"
---

# /silver:bugfix — Bug, Regression, Test Failure Workflow

SB orchestrator for bugs, regressions, crashes, errors, and failing tests. Enforces triage-first discipline: classify the failure type before any investigation begins.

Never implements fixes directly — orchestrates only.

## Pre-flight: Load Preferences

Read `silver-bullet.md §10` to load user workflow preferences before any other step.

```bash
grep -A 50 "^## 10\. User Workflow Preferences" silver-bullet.md | head -60
```

Display banner:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 SILVER BULLET ► BUGFIX WORKFLOW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Symptom: {$ARGUMENTS or "(not specified)"}
```

## Step-Skip Protocol

When the user requests skipping any step:
1. Explain why the step exists (one sentence)
2. Offer: A. Accept skip  B. Lightweight alternative  C. Show me what you have
3. If user chooses A permanently: record in silver-bullet.md §10b and templates/silver-bullet.md.base §10b, commit both.

**Non-skippable gates:** `silver:security`, `silver:quality-gates` pre-ship, `gsd-verify-work`.

## Step 0: Triage — Classify Failure Type

Use AskUserQuestion:

> What best describes this failure?
>
> A. Known symptom, unknown fix — I can observe the bug but don't know the root cause
> B. Unknown cause — session history is unclear, need to reconstruct what happened
> C. Failed GSD workflow specifically — a plan, execution phase, or GSD command failed

Wait for selection, then route to the corresponding path below.

---

## Debug Investigation Paths

<!-- Debug investigation paths — will align with PATH 14 (DEBUG) in Phase 24 -->

### Path 1A: Known Symptom, Unknown Fix

Invoked when: triage selects A, OR after Path 1B/1C forensics completes and hands off here.

**1A.1 — Systematic debugging hypothesis**
Invoke `superpowers:systematic-debugging` via the Skill tool. Purpose: structure the debugging hypothesis before executing investigation — ensures systematic approach before diving into code.

**1A.2 — Persistent debugging investigation**
Invoke `gsd-debug` via the Skill tool. Purpose: execute investigation with persistent state across context resets.

After gsd-debug completes, proceed to Step 2 (TDD).

### Path 1B: Unknown Cause, Needs Reconstruction

Invoked when: triage selects B.

**1B.1 — Forensic cause reconstruction**
Invoke `silver:forensics` via the Skill tool. Purpose: SB-owned forensics skill (skills/forensics/SKILL.md) — reconstructs cause from git history, artifacts, and state. Outputs a cause classification report.

After silver:forensics completes and outputs the cause classification:
→ Hand off to Path 1A (start at Step 1A.1 with the reconstructed context).

### Path 1C: Failed GSD Workflow

Invoked when: triage selects C.

**1C.1 — GSD-specific post-mortem**
Invoke `gsd-forensics` via the Skill tool. Purpose: GSD-owned post-mortem for failed GSD workflows (failed plans, broken state, incomplete phases). Outputs diagnosis.

After gsd-forensics completes and outputs diagnosis:
→ Hand off to Path 1A (start at Step 1A.1 with the GSD diagnosis context).

---

## Step 2: TDD — Write Regression Test First

All paths converge here. Before writing any fix code:

Invoke `silver:tdd` (superpowers:test-driven-development) via the Skill tool. Purpose: write a failing regression test first — RED must appear before writing any fix. This ensures the fix is verifiable and the bug cannot silently regress.

**Enforcement:** Do not proceed to PATH 5 until the test is red (failing for the right reason).

---

## PATH 5: PLAN — Fix Planning (Lightweight)

### Prerequisite Check

TDD regression test exists and is red (from Step 2). If not, STOP — go back to Step 2.

### Steps

1. `gsd-plan-phase` (Always — lightweight, 1-2 tasks only)

### Exit Condition

PLAN.md exists for the fix.

> **Note:** Bugfix uses a lightweight version of PATH 5 — no discuss-phase, writing-plans, or testing-strategy since the bug investigation already established context and the TDD step already defined the test.

---

## PATH 7: EXECUTE — Fix Implementation

### Prerequisite Check

PLAN.md exists for the fix AND regression test from Step 2 is red. If PLAN.md missing, STOP — return to PATH 5.

### Steps

1. `gsd-execute-phase` (Always — sole execution engine, per D-09)
2. Verify regression test from Step 2 is now GREEN after execution.

### Failure Path

If execution fails, route to Path 1A (systematic debugging) with execution failure context.

### Exit Condition

All PLAN.md tasks have SUMMARY.md, regression test is green.

---

## Review & Security

<!-- Non-core path steps — will become PATH 9, 10, 12 in future phases -->

### Step 5: Code Review

Run the full review sequence in order:

1. Invoke `silver:request-review` (superpowers:requesting-code-review) via the Skill tool.
2. Invoke `gsd-code-review` via the Skill tool.
3. Invoke `silver:receive-review` (superpowers:receiving-code-review) via the Skill tool.

### Step 7: Security Review

Invoke `silver:security` via the Skill tool. Non-skippable.

### Step 7b: Quality Gates

Invoke `silver:quality-gates` via the Skill tool (affected quality dimensions for the changed code). Non-skippable.

---

## PATH 11: VERIFY — Non-Skippable Verification

### Prerequisite Check

PATH 7 completed: SUMMARY.md exists for current fix. Regression test is green. If not, STOP — return to PATH 7.

### NON-SKIPPABLE

This path cannot be skipped regardless of §10 preferences. Refuse skip requests.

### Steps

1. `gsd-verify-work` (Always — NON-SKIPPABLE, per D-12). Confirm fix, zero regression.
2. `gsd-add-tests` (As-needed — if coverage gaps beyond the regression test)
3. `superpowers:verification-before-completion` (Always)

### Exit Condition

VERIFICATION.md with status: passed (2 consecutive clean passes, per D-13).

---

## PATH 13: SHIP — Deliver Fix

### Prerequisite Check

PATH 11 completed (VERIFICATION.md exists with status: passed), clean working tree, on feature branch. Quality gates (Step 7b) passed. If any fail, STOP.

### Steps

1. `gsd-ship` (Always — push branch, create PR, per D-14/D-15)

### Exit Condition

PR created, CI green (per D-15).
