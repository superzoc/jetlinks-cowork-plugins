---
name: jetlinks-spec
description: Run a "spec first, code second" workflow that spans Cowork and a CLI coding agent. Trigger when the user wants to start a new feature, do requirements analysis, design a prototype, write a PRD, draft an implementation plan, or bridge a Cowork session with a CLI implementation session through a shared plan document. Phrases include "new feature workflow", "spec workflow", "feature handoff", "plan-first", and equivalents in Chinese such as the words for requirements analysis, prototype design, PRD writing, implementation plan, and Cowork-to-CLI collaboration.
---

# Cowork to CLI Spec Workflow

## Mental model

Two tools, two phases, one shared file.

- **Cowork** is good at requirements gathering (multi-turn questioning, AskUserQuestion), prototype design (HTML / SVG artefacts), connector access (Figma, Linear, Notion, Slack), and producing review-ready documents.
- **CLI agents** (Claude Code etc.) are good at large-repo navigation, multi-file edits, running build / test / lint, git operations, and following project-level routing skills.

The bridge between the two is a single directory committed to the repo:

```
docs/plans/<feature-name>/
├── requirements.md      # what we are building and why
├── prototype.html       # visual prototype (or just a Figma link)
└── plan.md              # 6-section implementation plan + back-fill area
```

If a project has its own AGENTS.md / CLAUDE.md plan-first conventions, this directory respects them. The three-file layout is the minimum viable handoff package — nothing more, nothing less.

## Three-file convention

### `requirements.md`

Captures the "what" and "why". Sections in the template:

1. Background and user value
2. In-scope / out-of-scope
3. User stories or jobs-to-be-done
4. Acceptance criteria (must be testable)
5. Owning module candidates (where in the repo this lands)
6. Prototype and reference links (Figma URL, screenshots)

Owning module is critical — the CLI side relies on it to route to the right focused skill.

### `prototype.html`

A standalone HTML page in the same directory. The Cowork agent fills it with a quick mockup that the user can open locally for review. If the team uses Figma exclusively, leave the HTML as a stub and put the real link at the top of `requirements.md`.

### `plan.md`

The implementation plan. Six required sections (matching common plan-first formats):

1. Goal
2. Affected scope and owning module
3. What this plan explicitly does **not** do
4. Implementation steps (ordered, granular)
5. Risks and open questions
6. Verification (commands, manual checks, acceptance evidence)

Plus a **back-fill area** at the bottom: commit hash(es), PR link, verification results. The CLI side updates this section after implementation; do not create a second "verification.md" or "results.md".

## Phase 1 — Cowork (spec)

1. **Scaffold**: invoke `/spec-start <feature-name>` (kebab-case) to create the directory with templates pre-filled.
2. **Interview**: walk the user through `requirements.md`. Ask about scope, users, acceptance criteria, owning module candidates. Use AskUserQuestion when there are 2-4 mutually exclusive choices.
3. **Prototype**: build `prototype.html` as a static mockup, or paste a Figma link at the top of `requirements.md` and leave the HTML as a placeholder. If the project has a design plugin (e.g. `design:design-critique`), chain to it for feedback.
4. **Plan**: draft `plan.md` filling all 6 sections. Be explicit about what is **out of scope** — this prevents scope creep in the CLI phase.
5. **Review checkpoint**: summarise scope + acceptance criteria + key implementation steps to the user before committing.

## Phase 2 — Handoff

The Cowork side does **not** modify business code. Hand off by:

1. Confirming the three files are saved into the user's repo
2. Suggesting a commit message like `docs(plans): scaffold <feature-name> spec`
3. Telling the user to open their CLI agent and use this prompt:

   ```
   读取 docs/plans/<feature-name>/plan.md，按计划实施。
   完成后把 commit hash、PR 链接和验证结果回填到同一份 plan.md，
   不要新增独立的变更说明文件。
   ```

   Replace the language to match the user's preference if needed.

## Phase 3 — CLI (implement)

The CLI agent should:

1. Read `plan.md` as the source of truth. If the repo has a routing skill (e.g. `jetlinks-router`), invoke it with the owning module from the plan.
2. Implement step by step. If the plan is wrong or incomplete, **stop and update `plan.md` first**, then resume — never silently diverge.
3. Run verifications listed in the plan. Capture command output.
4. Append to the back-fill area:
   - Commit hash(es)
   - PR / MR link
   - Verification results (lint / typecheck / test / build, with pass/fail and brief notes)
   - Any deviations from the original plan, with reason

## Phase 4 — Verify (back in Cowork)

When the user returns to Cowork:

1. Read the back-filled `plan.md`
2. Read `requirements.md` acceptance criteria
3. Compare line-by-line; flag anything missing or out of spec
4. If gaps found, write a short follow-up note **at the bottom of the same `plan.md`**, do not create a new file

## Naming conventions

- **Feature directory**: `docs/plans/<feature-shortname>/`. Use kebab-case. Optionally prefix with year-month: `docs/plans/202605-tenant-quota/`.
- **Index**: if the repo has `docs/plans/README.md`, add a one-line entry pointing to the new feature directory after Phase 1 completes.
- **Slug stability**: do not rename the directory after handoff — it would break the CLI agent's references and any commit messages.

## When to skip this workflow

Skip the full three-file scaffold for:

- Pure ad-hoc fixes, doc-only tweaks, formatting passes
- S-level tasks (single-file, low risk, no interface or data change)
- Pure operational chores (rebase, merge, dependency bump)

For these, drive the CLI agent directly without going through `/spec-start`. If midway the task escalates (scope creeps, multiple modules involved), pause and run `/spec-start` to retroactively create the directory before continuing.

## Combining with other skills

- **In Cowork**, after `/spec-start`, chain to a design feedback skill (e.g. `design:design-critique`) for prototype review if available.
- **In CLI**, after reading `plan.md`, chain to a project-specific routing skill (e.g. `jetlinks-router`) and then to focused skills based on the owning module.
- **At commit time**, chain to a delivery skill (e.g. `jetlinks-delivery`) so verification evidence and commit format match project conventions.

## Common failure modes to avoid

- Editing business code from the Cowork side (only `docs/plans/` should be touched here).
- Creating a separate `verification.md` or `delivery.md` in the feature directory — back-fill into `plan.md` instead.
- Letting `requirements.md` and `plan.md` drift apart. If requirements change, edit `requirements.md` first, then update `plan.md` to match, in the same commit.
- Skipping the "out of scope" section in `plan.md`. It is the single most useful field for keeping the CLI phase contained.
