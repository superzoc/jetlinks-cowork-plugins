---
name: spec-verify
description: Cowork-side action skill that owns Phase 4 of the JetLinks spec-first workflow. After a CLI agent has implemented a feature and back-filled docs/plans/[feature-name]/plan.md, this skill compares the back-fill against the acceptance criteria in requirements.md, classifies each criterion as pass / partial / fail / missing-evidence, and appends a gap-notes section to the bottom of plan.md. Trigger when the user returns to Cowork after implementation and says "验收一下"、"对一下需求"、"verify the implementation"、"check the back-filled plan"、"is this implementation complete"、"compare plan vs requirements", or when they paste a back-filled plan.md and ask for review. Doc-only by contract — never edits business code, never opens PRs.
argument-hint: "[<feature-name>]"
---

# Spec Verify — Cowork Phase 4 Reconciliation

> Knowledge dependency: load `spec-workflow` first if it has not been
> consulted yet. The contract defined there is what this skill enforces.

## Where to run this

Cowork-only. Phase 4 is the closing of the loop opened by `spec-scaffold`:
read what `requirements.md` promised, read what `plan.md`'s back-fill area
delivered, write the difference down. The output is appended to `plan.md`
so future readers see the full lifecycle in one place.

## Boundaries

- Reads `docs/plans/<feature-name>/requirements.md` and `plan.md`.
- Writes a single appended section to `plan.md`. Does not touch
  `requirements.md`, `prototype.html`, `references.md`, or any business code.
- Does not re-open the implementation. Gaps are reported back to the user;
  the user decides whether to file a follow-up CLI task.

## Inputs

- **`<feature-name>`** (optional): if provided, locate
  `docs/plans/<feature-name>/`. If omitted, ask the user which feature
  they want to verify, or infer from the most recently modified
  `docs/plans/*/plan.md`.

## Pipeline (execute in order)

### Step 1 — Locate the artifacts

- Resolve `<repo-root>/docs/plans/<feature-name>/`. Verify both
  `requirements.md` and `plan.md` exist.
- If `plan.md` has no back-fill content (the "Implementation back-fill"
  section is still all template placeholders), stop and tell the user:
  the CLI phase doesn't appear to be complete. Do not produce a gap
  report against an empty implementation — that just looks like a wall
  of red.

### Step 2 — Extract criteria and evidence

From `requirements.md` section 4 (Acceptance criteria), extract every
testable criterion as an ordered list.

From `plan.md` back-fill, extract:

- Commits (hashes + short messages)
- PR / MR link
- Verification results (each command + pass/fail + notes)
- Manual check outcomes
- Deviations from plan (with reasons)
- Acceptance criteria status checklist (if the CLI agent filled it in)

### Step 3 — Reconcile criterion by criterion

For each acceptance criterion, classify the evidence into one of four
buckets and write one short sentence saying why:

- **✓ PASS** — evidence directly demonstrates the criterion (a passing
  test, a manual check outcome, a verified deviation that strengthens
  the criterion). Cite the evidence (commit hash, command, test name).
- **◐ PARTIAL** — evidence covers part of the criterion. Specify which
  part is covered and which is not.
- **✗ FAIL** — evidence contradicts the criterion (a failing test, a
  manual check that didn't behave as required).
- **? MISSING EVIDENCE** — implementation steps in `plan.md` claim to
  cover the criterion, but the back-fill has no verification record
  for it. Common cause: the criterion involves an output (report,
  export, log) that was implemented but never sampled. This is
  **distinct from FAIL** — the implementation may well work, but
  Phase 3 didn't leave proof. Ask for a quick check, not a re-do.

### Step 4 — Detect scope drift independently

After the criterion-by-criterion pass, scan:

- `plan.md` Deviations section — for each deviation, classify it as:
  - **Strengthening** (the implementation went beyond plan but stayed
    inside `requirements.md` scope)
  - **Anticipated** (the deviation was pre-flagged in plan.md Risks
    section — credit the planner)
  - **Drift** (the implementation went outside `requirements.md`
    in-scope / out-of-scope boundaries)
- `plan.md` Out-of-scope section — verify that nothing in the
  back-fill quietly implemented an out-of-scope item.

Drift is the most expensive failure mode to miss. Surface it explicitly.

### Step 5 — Write the gap-notes section

Append a new section to the bottom of `plan.md`, titled exactly:

```
## Phase 4 — Verification (Cowork)

> Filled in by spec-verify on YYYY-MM-DD.
```

Structure:

1. **Summary**: one paragraph — overall verdict, e.g. "Implementation
   covers 5/6 acceptance criteria; one (report export) is missing
   evidence and needs a screenshot or sample row to confirm."
2. **Criterion-by-criterion table**: one row per criterion, columns are
   Criterion / Status / Evidence / Action needed.
3. **Deviation analysis**: list each deviation from Step 4 with its
   classification.
4. **Scope drift**: explicit yes/no with details if yes.
5. **Recommended follow-ups**: a short numbered list of specific
   actions, each small enough to be a single CLI task or a quick
   manual check by the user. If none, write "None — implementation
   matches the spec."

Use Markdown that renders cleanly when the file is viewed on GitHub.

### Step 6 — Report to the user

Show the user the **Summary** paragraph and the **Recommended follow-ups**
list inline in chat. Tell them where the full section was written.

If there are zero gaps and zero drift, say so plainly — do not pad. A
clean verification is a valid outcome and saying "all green" is
useful information.

## Example output (inline summary)

```
spec-verify — tenant-device-quota

Summary: 4 of 5 acceptance criteria PASS; 1 has MISSING EVIDENCE
(report export — code path implemented, but no verification record).
One deviation classified as Anticipated (MQTT path was pre-flagged in
plan.md Risks). No scope drift.

Recommended follow-ups:
  1. Export the tenant report and attach the output (or a sample row)
     to plan.md back-fill. Single CLI task.

Full gap-notes appended to docs/plans/tenant-device-quota/plan.md
(section "Phase 4 — Verification").
```

## Things this skill explicitly does not do

- Does not edit `requirements.md`. If a criterion now reads as wrong in
  hindsight, surface it to the user — they decide whether to amend.
- Does not edit business code or open a PR. Gaps go to the user, not
  the CLI agent directly.
- Does not run tests. It reads what the CLI back-fill recorded; if the
  user wants tests re-run, that's a CLI task.
- Does not consult `references.md` (the Phase-1 research file). Phase 4
  is strictly contract-vs-receipt; research is upstream of that.

## When to use a lighter touch

If the feature was scaffolded with `When to skip this workflow` in mind
(S-level fix, doc-only change), there will be no `requirements.md` /
`plan.md` to compare against. In that case decline politely and ask the
user what they actually want verified — a quick code review, a manual
check, a regression test.

## Common failure modes to avoid

- **Conflating MISSING EVIDENCE with FAIL.** The first is "we need 30
  more seconds of confirmation"; the second is "we need to write code
  again." Mixing them inflates the perceived gap and burns trust.
- **Penalising Anticipated deviations.** If `plan.md` Risks section
  pre-flagged a risk and the CLI agent handled it, that is the workflow
  working as designed — credit the planner.
- **Skipping scope drift.** Drift is easier to miss than gaps because
  the agent has to compare against a section (Out-of-scope) it can be
  tempted to skim.
- **Editing `plan.md` outside the appended section.** Do not retouch
  the original 6 sections or the CLI back-fill. Append only.
