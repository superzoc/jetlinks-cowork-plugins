---
name: spec-mock
description: Frontend-only product-design workflow. Scaffold a new page or route inside the project's existing frontend (e.g. ui/ or runtime-ui/), wire it with mock data, and skip backend implementation entirely. Trigger when the user types "/spec-mock", asks to "build a frontend prototype", "design with mock data", "scaffold a mock page", "skip backend and just iterate UI", "frontend-first prototype", or equivalent intent in Chinese (frontend-only prototype, mock data to validate UI, frontend-first design). Also drops a lightweight docs/plans/[feature-name]/prototype-notes.md so scope, mock data shape, and the gap to a real backend are recorded for later promotion to /spec-start.
argument-hint: "<feature-name>"
---

# Spec Mock — Frontend-Only Prototype Workflow

## Purpose

Help the user iterate on UI/UX **without writing any backend code**. The deliverable is a runnable page in the project's real frontend (so visuals, routing, and state already work in context), wired to mock data, plus a short notes file describing what was built and what real backend integration would need.

## Inputs

- `<feature-name>` — kebab-case slug. Same rules as `/spec-start` (lowercase letters, digits, hyphens; start/end with alphanumeric).

## Behaviour

Run these steps in order. Do NOT skip step 3.

### 1. Validate the feature name

- Parse from `/spec-mock <name>` or from natural language. If invalid (uppercase, underscores, spaces), suggest a corrected slug.
- If no name given, ask one short question: "What's the feature short-name? (kebab-case, e.g. `tenant-quota-preview`)".

### 2. Pick the frontend boundary

Different repos have different frontend layouts. Detect, then confirm with the user:

- If the project has a single frontend dir (e.g. `frontend/`, `web/`, `app/`), use it.
- If multiple frontend dirs exist (e.g. `ui/` for operator vs `runtime-ui/` for runtime extensions), **ask** which one — the boundary is rarely obvious from the feature name and getting it wrong means working in the wrong workspace.
- If no frontend dir is detectable, ask the user where prototypes should go.

Do not silently pick a boundary.

### 3. Study existing patterns BEFORE writing code

Read 2–3 representative files in the chosen frontend dir to learn the project's conventions:

- The router config (`router/index.ts`, `routes.tsx`, etc.)
- One existing page component of similar shape (list page, detail page, dashboard, etc.)
- How the project handles fake or fixture data (`grep -r mock\\|fixture\\|msw` and look at any matches)

Then **match** those conventions: same component framework, same import style, same i18n approach, same mock approach. Do not introduce a new mock library if the project doesn't already use one.

If the existing frontend has no mock convention at all, default to inline data inside the page component or an adjacent `<feature-name>.mock.ts` (or `.json`) file — keep it boring.

### 4. Scaffold the prototype

Create at minimum:

- A new page component, path following project conventions (e.g. `<frontend>/src/views/<feature-name>/index.vue`)
- A new route entry pointing to it
- Mock data — inline in the component for tiny prototypes, or in a sibling fixture file for anything with more than ~20 rows of structure
- Anything else the project's pages always include (page title, breadcrumbs, layout wrapper, etc.) — copy what other pages do, don't invent a new pattern

Keep the prototype small. Three principles:

- Validate UX, not feature completeness. A list page does not need export/print/bulk-edit unless those are the point of the prototype.
- Avoid editing more than 2–3 existing files outside the new page. If the change spreads further, stop and surface to the user — that's a sign the scope is bigger than a quick mock.
- Do **not** add any code under backend dirs (e.g. `modules/`, `runtime/`, `control/`, `services/`, `api/`).

### 5. Generate prototype-notes.md

Copy `${CLAUDE_PLUGIN_ROOT}/skills/spec-mock/templates/prototype-notes.md` to `<repo-root>/docs/plans/<feature-name>/prototype-notes.md`, replacing `{{FEATURE_NAME}}` and filling in the sections you can answer:

- What this prototype covers (1–2 sentences)
- Frontend boundary (`ui/`, `runtime-ui/`, etc.)
- Page component path and route URL
- Mock data shape (a stripped-down schema is enough)
- What real backend integration would need: endpoints, fields, behaviours the mock is faking, authn / authz / tenant scoping
- How to run the dev server

Do not overwrite an existing `prototype-notes.md`; append a dated section instead.

### 6. Confirm to user

Output a short summary:

- Created files (relative paths from repo root)
- The dev server command (e.g. `cd ui && pnpm dev`) and the route URL to open
- Where the notes file lives

Example:

```
Prototype scaffolded in ui/ (operator frontend):
  - ui/src/views/tenant-quota-preview/index.vue
  - ui/src/views/tenant-quota-preview/mock.ts
  - ui/src/router/modules/tenant.ts (added route)

Run: cd ui && pnpm dev
Open: /tenant/quota-preview

Notes: docs/plans/tenant-quota-preview/prototype-notes.md
```

## Combining with /spec-start

If the user already ran `/spec-start <feature-name>` first, `docs/plans/<feature-name>/` already contains `requirements.md`, `prototype.html`, `plan.md`. In that case `/spec-mock` should:

- Reuse the same directory (don't error on existence)
- Add `prototype-notes.md` alongside the other three files
- **Not** overwrite `requirements.md`, `prototype.html`, or `plan.md`
- In `prototype-notes.md`, reference the existing `requirements.md` so future readers see both

If `/spec-start` hasn't been run, `/spec-mock` just creates `docs/plans/<feature-name>/` with only `prototype-notes.md`.

## Promotion path (prototype → real implementation)

When the prototype validates the design and the team wants to ship for real:

1. Run `/spec-start <feature-name>` in the same directory if it wasn't there yet
2. Use `prototype-notes.md` as direct input to `requirements.md` (acceptance criteria, mock data shape become real schemas)
3. Use the "what real backend integration would need" section as direct input to `plan.md` (implementation steps)
4. Replace the mock data with real API calls, keeping the same component shape
5. Once real implementation is committed, either delete `prototype-notes.md` or mark it `superseded by requirements.md`

## When NOT to use /spec-mock

- The real backend is already there and you just need to wire the UI: write real code directly, mocking is wasted effort
- The feature is for an external stakeholder demo, not internal iteration: a standalone HTML mock (or `prototype.html` from `/spec-start`) is more portable and won't pollute the production frontend
- The feature requires backend logic that materially changes the UI flow (auth, multi-step transactions, real-time): mocking will hide bugs; spec it properly first via `/spec-start`, then build minimal backend

## Cleanup expectations

The prototype lives in production frontend code. Make sure the user understands the cleanup options:

- **Promote**: replace mock data with real API calls (stays as a real page)
- **Park**: keep behind a feature flag or admin-only route until ready
- **Delete**: remove the page, route, and mock file when the prototype's purpose is served

`prototype-notes.md` should mention which option is intended.
