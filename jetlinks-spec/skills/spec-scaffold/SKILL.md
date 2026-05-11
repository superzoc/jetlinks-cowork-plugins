---
name: spec-scaffold
description: Cowork-side action skill that owns Phase 1 + 2 of the JetLinks spec-first workflow. Validates the feature-name, creates docs/plans/[feature-name]/ with three contract templates, runs a design-research pass (WebSearch + connectors then writes references.md), drives the multi-turn fill of requirements.md / prototype.html / plan.md, and produces the commit message + handoff prompt for the CLI implementation phase. Trigger when the user types "/spec-scaffold", asks to "start a new feature spec", "scaffold a new feature", "draft requirements / prototype / plan", or equivalents in Chinese meaning "新功能 spec"、"立一个新需求"、"拉个 PRD 模板"、"做需求-原型-计划". Doc-only by contract — never writes business code. After Phase 2 handoff, ownership transfers to the CLI agent; on the user's return, control passes to spec-verify.
argument-hint: "<feature-name>"
---

# Spec Scaffold — Cowork Phase 1 + 2 Pipeline

> Knowledge dependency: load `spec-workflow` first if it has not already been
> consulted in this session. It defines the 4-phase contract and the three-file
> handoff this skill executes Phase 1 + 2 of.

## Where to run this

Cowork-only. This skill is interactive: the design-research pass uses
WebSearch and (optionally) connector tools; the spec fill is multi-turn
and benefits from `AskUserQuestion`; the prototype iteration uses
`show_widget`. A CLI agent may invoke this skill for reproducibility
(re-scaffolding a damaged directory, regenerating the handoff prompt),
but the interactive phases will degrade.

The companion `spec-prototype` skill — which writes runnable frontend
code — must run in CLI, not Cowork.

## Boundaries

- Writes only inside `docs/plans/<feature-name>/`.
- Never touches business code (backend modules, frontend pages, build configs).
- Never commits — output is a suggested commit message; the user runs `git`.
- Stops at the handoff prompt. Phase 3 (implementation) is owned by the CLI
  agent and `plan.md`.

## Inputs

- **`<feature-name>`** (required, kebab-case): lowercase letters, digits,
  single hyphens; starts and ends with an alphanumeric character. Examples:
  `tenant-quota`, `device-asset-export`, `202605-saas-billing`.
- **Repository root** (implicit): in Cowork, the user's selected workspace
  folder.
- **The user's intent** in free-form text: this is the seed for the
  design-research step and the requirements interview.

## Pipeline (execute in order; do not skip)

### Step 1 — Validate the feature-name

- Extract the name from the user's message. If they invoked
  `/spec-scaffold foo-bar`, use `foo-bar`. If they wrote a free-form
  sentence, infer a kebab-case slug and confirm with `AskUserQuestion`
  (offer 2–3 candidates).
- Reject names with uppercase letters, underscores, spaces, or special
  characters. Suggest a corrected slug.
- If the user gave no name at all, ask one short question:
  "What's the feature short-name? (kebab-case, e.g. `tenant-quota`)".

### Step 2 — Locate the repo root and check for collisions

- In Cowork: use the user's currently selected workspace folder.
- If `<repo-root>/docs/plans/<feature-name>/` already exists, stop and
  tell the user. Do not overwrite. Offer two choices: pick a new name,
  or cd into the existing directory and continue editing it.
- If `<repo-root>/docs/` does not exist, create it as part of the scaffold.

### Step 3 — Scaffold the three contract files

Prefer the bundled bash script:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/spec-scaffold/scripts/scaffold-feature.sh <feature-name> <repo-root>
```

The script copies templates from `${CLAUDE_PLUGIN_ROOT}/skills/spec-scaffold/templates/`
and replaces the `{{FEATURE_NAME}}` placeholder.

If bash is unavailable, fall back to file tools:

1. Read each template under `${CLAUDE_PLUGIN_ROOT}/skills/spec-scaffold/templates/`
   (`requirements.md`, `prototype.html`, `plan.md`).
2. Replace `{{FEATURE_NAME}}` with the user's feature name.
3. Write to `<repo-root>/docs/plans/<feature-name>/<filename>`.

`references.md` is **not** scaffolded here — Step 4 produces it on demand.

### Step 4 — Design research pass (NEW)

This step exists to prevent the most common Phase-1 failure: anchoring on
the user's first phrasing of the problem and missing established
solutions. Before the requirements interview, scan prior art.

#### 4a. Frame the search

From the user's free-form description plus the feature-name, write one
sentence framing the feature in domain-neutral terms. Examples:

- `tenant-device-quota` → "Per-tenant resource quota with hard enforcement
  in B2B SaaS."
- `device-asset-export` → "Bulk export of tabular resource records with
  filter, format choice, and async-vs-sync delivery in B2B SaaS admin UIs."
- `mqtt-event-replay` → "Time-windowed replay of streaming protocol
  events for debugging in IoT platforms."

If the framing is unclear, ask the user **one** question to disambiguate
(e.g. "Is this primarily an enforcement feature or a billing/reporting
feature?") — do **not** run a multi-question interview here; that comes
in Step 5.

#### 4b. Run the research

Use the tools available in the current session, in this priority order:

1. **WebSearch** for the framed problem and for "best practice" /
   "UX pattern" formulations of it. Aim for 3–5 high-signal sources:
   leading SaaS products' docs, design-system case studies, well-known
   engineering blogs. Skip listicles and SEO bait.
2. **WebFetch** the most promising 2–3 sources for actual content.
3. **Connector lookups (optional)** if connectors are present and
   relevant:
   - Figma: search for similar component / flow names.
   - Notion / Linear: look for past internal specs that may have
     touched related territory.
   - Slack: search for past threads on the topic.
   Skip any connector that is not connected — do not block on auth.

If WebSearch is unavailable (offline session, disabled tools), say so
explicitly and proceed with whatever the agent already knows from
training, marked clearly as "no web search performed" in `references.md`.

#### 4c. Distil into `references.md`

Copy `${CLAUDE_PLUGIN_ROOT}/skills/spec-scaffold/templates/references.md`
to `<repo-root>/docs/plans/<feature-name>/references.md`, replace
`{{FEATURE_NAME}}`, and fill in:

1. **Framing** — the one-sentence framing + the search queries used.
2. **Mature designs surveyed** — 2–4 products with URLs, what they do,
   what's worth borrowing and what's worth avoiding.
3. **UI / UX patterns spotted** — concrete patterns specific enough to
   be yes/no decisions for the prototype.
4. **Antipatterns / pitfalls** — known traps in this design space.
5. **Takeaways into the interview** — 3–5 bullets, each mapped to a
   concrete question or candidate acceptance criterion.

Keep this file **tight**. Maximum ~150 lines. If the research feels
thin, that's a signal to ask the user one more disambiguation question,
not to pad the file.

#### 4d. Surface highlights to the user

Before starting Step 5, show the user a short summary (5–10 lines):
which products were studied, the two or three most important takeaways,
and any concrete UX pattern decisions worth raising in the interview.
Ask "anything in this you want to push back on before we start the
interview?" — this gives the user a chance to redirect early if the
research framed the problem wrong.

### Step 5 — Multi-turn fill of `requirements.md`

Walk the six required sections in order. Use `AskUserQuestion` when
there are 2–4 mutually exclusive choices; otherwise ask in plain text
one question at a time.

- **Background and user value** — Q: what problem, for whom, why now?
- **Scope** — Q: what's explicitly in / out? Use Step 4's antipatterns to
  prompt candidate out-of-scope items.
- **User stories** — Q: who is the primary actor, what is the verb?
- **Acceptance criteria** — Seed candidates from Step 4's takeaways.
  Show 3–5, ask the user to confirm / amend / add. Every criterion
  must be testable.
- **Owning module candidates** — Q: which module in the repo? This is
  critical — the CLI side uses it to route.
- **Prototype and references** — link to `prototype.html` (Step 6) and
  paste any Figma / past-doc links.

After the section is full, write `requirements.md` and offer a short
summary back. Do **not** require the user to review the full file;
they can if they want.

### Step 6 — Build `prototype.html`

Choose one of two paths based on the user's preference:

- **HTML mockup**: use the `show_widget` tool to draft an inline preview,
  iterate based on user feedback, then save the final HTML into
  `prototype.html`. Reference the Step 4 UI/UX patterns to seed the
  initial layout.
- **Figma link**: leave `prototype.html` as the scaffolded stub and
  paste the Figma URL at the top of `requirements.md`.

If the project has a design plugin (e.g. `design:design-critique`),
optionally chain to it for prototype feedback.

### Step 7 — Draft `plan.md`

Fill all six required sections. Be **explicit** about Out-of-scope —
this is the single most useful field for keeping Phase 3 contained.
Seed Risks from the antipatterns / pitfalls in `references.md`.

Show the Out-of-scope and Risks sections to the user explicitly before
considering the plan complete. These are the two sections most often
under-filled and most often regretted.

### Step 8 — Phase 2 handoff package

When all three contract files are written:

1. List what was created (relative paths from repo root, including
   `references.md` if produced).
2. Suggest a commit message:

   ```
   docs(plans): scaffold <feature-name> spec
   ```

3. Output the CLI handoff prompt verbatim:

   ```
   读取 docs/plans/<feature-name>/plan.md，按计划实施。
   完成后把 commit hash、PR 链接和验证结果回填到同一份 plan.md，
   不要新增独立的变更说明文件。
   ```

   Adjust language to match the user's preference if needed.

4. Tell the user the next step: commit, switch to a CLI agent, paste
   the prompt. When they return, `spec-verify` will compare the
   back-filled `plan.md` against `requirements.md`.

## Output format (Step 8 example)

```
Scaffolded docs/plans/tenant-device-quota/:
  - requirements.md
  - prototype.html
  - plan.md
  - references.md (research notes, not part of CLI handoff)

Suggested commit:
  docs(plans): scaffold tenant-device-quota spec

CLI handoff prompt:
  读取 docs/plans/tenant-device-quota/plan.md，按计划实施。
  完成后把 commit hash、PR 链接和验证结果回填到同一份 plan.md，
  不要新增独立的变更说明文件。

When you come back, I will run spec-verify to compare the back-filled
plan against the acceptance criteria.
```

## Things this skill explicitly does not do

- Does not write business code (backend or frontend).
- Does not modify files outside `docs/plans/<feature-name>/`.
- Does not commit. The user decides when to `git add` / `git commit`.
- Does not execute the implementation. That is the CLI agent's job,
  driven by `plan.md`.

## When the scaffold is the wrong answer

If the user's request is an S-level fix (single file, low risk, no
interface change), do **not** scaffold. Tell them: "This looks small
enough to skip the spec — want me to just do it directly?" If they
confirm, hand off without creating a `docs/plans/` entry.

For pure-frontend prototypes with no backend, run Steps 1–6 here, then
in Step 7 stub `plan.md` with a one-liner pointing at `/spec-prototype`,
and tell the user to switch to a CLI agent to scaffold the runnable
page.
