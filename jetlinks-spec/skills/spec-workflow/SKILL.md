---
name: spec-workflow
description: Knowledge skill explaining the JetLinks spec-first workflow — a 4-phase contract spanning Cowork (spec) and a CLI coding agent (implement), bridged by a single docs/plans/[feature]/ directory. Use to teach the agent what the workflow is, what files it produces, when to skip it, and how the companion skills (spec-scaffold, spec-prototype, spec-verify) divide responsibility. Trigger when the user mentions "spec workflow", "spec-first", "PRD 流程", "plan-first", "feature handoff", "需求-原型-计划", "Cowork 到 CLI 协作". This skill does NOT execute the workflow — it is consulted by other skills and the agent as a contract reference.
---

# JetLinks Spec-First Workflow — Contract Reference

## Why this exists

Cowork and CLI coding agents have different strengths. Cowork excels at multi-turn requirements interviews, prototype design, connector access (Figma / Linear / Notion / Slack), and producing review-ready documents. CLI agents (Claude Code etc.) excel at large-repo navigation, multi-file edits, running build / test / lint, and git operations.

This workflow defines the contract between them — what each side owns, where they hand off, and what artifacts persist across the handoff. The real value is not "thinking everything through up front" but "leaving an explicit reconciliation surface" — risks called out before implementation get confirmed or corrected after, instead of being lost.

## The 4 phases

```
Phase 1: Cowork — spec        write requirements / prototype / plan
   ↓
Phase 2: Handoff              commit docs/plans/, give CLI the prompt
   ↓
Phase 3: CLI — implement      read plan.md, code, back-fill verification
   ↓
Phase 4: Cowork — verify      compare back-filled plan vs acceptance criteria
```

Runtime instructions live in dedicated companion skills, not here:

| Phase | Owner skill | Side |
|---|---|---|
| 1 + 2 | `spec-scaffold` | Cowork |
| 3 | (none — `plan.md` is the contract; CLI uses its own routing skills) | CLI |
| 4 | `spec-verify` | Cowork |
| Frontend-only fast path | `spec-prototype` | CLI |

## The shared artifact: `docs/plans/<feature-name>/`

The single source of truth handed between Cowork and CLI:

```
docs/plans/<feature-name>/
├── requirements.md      what we are building and why          (contract)
├── prototype.html       visual prototype, or a Figma link     (contract)
├── plan.md              implementation plan + back-fill area  (contract)
└── references.md        prior-art / UI-UX research            (optional working file)
```

The first three files are the handoff contract — CLI reads them, back-fills `plan.md`, and Cowork verifies against `requirements.md`. `references.md` is a Phase-1 working file produced by the design-research step in `spec-scaffold`; CLI does not need it during implementation, and it can be deleted or kept as historical context after Phase 4.

If a project has its own AGENTS.md / CLAUDE.md conventions, this directory respects them.

### `requirements.md` — the "what" and "why"

Sections: background and user value · in-scope / out-of-scope · user stories or jobs-to-be-done · acceptance criteria (must be testable) · owning module candidates · prototype and reference links.

Owning module is critical — the CLI side relies on it to route to the right focused skill.

### `prototype.html` — the visual

Standalone HTML in the same directory, openable locally. If the team uses Figma exclusively, leave the HTML as a stub and put the real link at the top of `requirements.md`.

### `plan.md` — the "how" + the receipt

Six required sections: Goal · Affected scope and owning module · What this plan explicitly does NOT do · Implementation steps (ordered, granular) · Risks and open questions · Verification (commands, manual checks, acceptance evidence).

Plus a **back-fill area** at the bottom. After implementation, the CLI agent appends: commit hash(es), PR/MR link, verification results (lint / typecheck / test / build, pass/fail with notes), and any deviations from the original plan with reason. Do not create a separate `verification.md` or `delivery.md`.

### `references.md` — prior-art and UI/UX research (optional)

Produced by `spec-scaffold` between scaffolding and the requirements interview. Captures: which leading products were studied, what UX patterns and antipatterns were found, and the 3–5 takeaways used to seed interview questions and prototype options. Not part of the CLI handoff contract — its job is to make Phase 1 better-informed.

## Naming conventions

Feature directory uses kebab-case: `docs/plans/<feature-shortname>/`, optionally prefixed by year-month (`docs/plans/202605-tenant-quota/`). If `docs/plans/README.md` exists, add a one-line entry after Phase 1 completes. Do not rename the directory after handoff — it would break CLI references and commit messages.

## When to skip this workflow

Skip the full scaffold for: pure ad-hoc fixes, doc-only tweaks, formatting passes; S-level tasks (single-file, low risk, no interface or data change); pure operational chores (rebase, merge, dependency bump).

For these, drive the CLI agent directly without `/spec-scaffold`. If midway the task escalates (scope creeps, multiple modules involved), pause and run `/spec-scaffold` to retroactively create the directory before continuing.

## Frontend-only fast path

For pure-frontend features (UI iteration, design validation, no real backend yet):

- Cowork still runs Phase 1 via `/spec-scaffold`, fills `requirements.md` + `prototype.html`, leaves `plan.md` as a stub pointing at `/spec-prototype`.
- CLI runs `/spec-prototype <name>` to scaffold the runnable page in the existing frontend with mock data, and writes `prototype-notes.md` into the same `docs/plans/<name>/`.

The boundary is identical: Cowork never writes production frontend code; CLI never edits requirements / prototype without surfacing back to Cowork.

## Common failure modes

- Editing business code from the Cowork side. Cowork is doc-only by contract — only `docs/plans/` may be touched.
- Running `/spec-prototype` from Cowork. It writes runnable pages into the production frontend; CLI-only. The skill enforces a redirect.
- Creating a separate `verification.md` or `delivery.md`. Back-fill into `plan.md` instead.
- Letting `requirements.md` and `plan.md` drift apart. If requirements change, edit `requirements.md` first, then update `plan.md` in the same commit.
- Skipping the "out of scope" section in `plan.md`. It is the single most useful field for keeping the CLI phase contained.
- Skipping the design-research step in `spec-scaffold`. Going straight into the interview tends to anchor on the user's first phrasing — a quick scan of mature designs almost always reframes the question.

## Companion skills (quick map)

- **`spec-scaffold`** (Cowork action) — validates feature-name, creates `docs/plans/<name>/`, runs the design-research step (writes `references.md`), runs multi-turn fill of the three contract files, produces commit message and CLI handoff prompt.
- **`spec-prototype`** (CLI action) — alternative branch for frontend-only features. Scaffolds page + route + mock data + `prototype-notes.md`. Refuses to run in Cowork.
- **`spec-verify`** (Cowork action) — compares back-filled `plan.md` against `requirements.md` acceptance criteria; appends gap notes to `plan.md`.
