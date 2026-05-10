# jetlinks-spec

A small plugin with two complementary commands:

- **`/spec-start <feature-name>`** — scaffold a full **Cowork ↔ CLI handoff** spec (`requirements.md` + `prototype.html` + `plan.md`) under `docs/plans/<feature-name>/`. Use Cowork to fill it in; hand off to a CLI agent (Claude Code etc.) to implement.
- **`/spec-mock <feature-name>`** — scaffold a **frontend-only prototype** directly inside the project's existing frontend (`ui/`, `runtime-ui/`, etc.), wired with mock data, plus a lightweight `prototype-notes.md`. Use this when you want to iterate UI/UX without writing any backend code.

Both commands write into `docs/plans/<feature-name>/` and play nicely together — you can mock first to validate the design, then run `/spec-start` to upgrade to a full spec when ready to ship for real.

Despite the name, the plugin is **project-agnostic**. It works in any repo with a `docs/plans/` convention; the frontend boundary detection in `/spec-mock` adapts to whatever frontend dirs the project has.

## Components

| Component                | Type  | Purpose                                                                                  |
| ------------------------ | ----- | ---------------------------------------------------------------------------------------- |
| `skills/jetlinks-spec`   | Skill | Workflow knowledge: the 3-phase Cowork↔CLI flow, naming conventions, hand-off rules.    |
| `skills/spec-start`      | Skill | Action: `/spec-start <feature-name>` scaffolds `docs/plans/<feature>/` with three templates. |
| `skills/spec-mock`       | Skill | Action: `/spec-mock <feature-name>` scaffolds a frontend-only mock prototype + notes.    |

## Setup

No environment variables, no MCP servers. The plugin only writes files inside the user's currently selected workspace folder.

## Usage

### Track A — full spec, real implementation (`/spec-start`)

1. Run `/spec-start <feature-name>` (kebab-case). Three templates appear under `docs/plans/<feature-name>/`.
2. Agent walks you through filling in `requirements.md` and `prototype.html` (or pasting a Figma link).
3. Agent drafts `plan.md` and confirms with you before commit.
4. Hand off to a CLI agent: "读取 docs/plans/<feature-name>/plan.md，按计划实施…"
5. CLI agent implements, runs verifications, back-fills commit hash / PR link / verification results into the same `plan.md`.
6. Verify in Cowork by diffing back-filled `plan.md` against `requirements.md` acceptance criteria.

### Track B — frontend-only prototype (`/spec-mock`)

1. Run `/spec-mock <feature-name>`. Agent picks the frontend boundary (`ui/` vs `runtime-ui/` etc.) and asks if ambiguous.
2. Agent studies existing routing / page / mock conventions in that frontend dir, then scaffolds:
   - A new page component matching project style
   - A new route entry
   - Mock data adjacent to the page (inline or fixture file, whichever the project uses)
3. Agent writes `docs/plans/<feature-name>/prototype-notes.md` capturing scope, mock data shape, and what real backend integration would need.
4. Run the project's dev server and iterate on the design.
5. When ready to ship for real, promote to Track A: run `/spec-start` in the same directory and use `prototype-notes.md` as input.

## File layout

```
jetlinks-spec/
├── .claude-plugin/plugin.json
├── README.md
└── skills/
    ├── jetlinks-spec/
    │   └── SKILL.md
    ├── spec-start/
    │   ├── SKILL.md
    │   ├── templates/
    │   │   ├── requirements.md
    │   │   ├── prototype.html
    │   │   └── plan.md
    │   └── scripts/
    │       └── scaffold-feature.sh
    └── spec-mock/
        ├── SKILL.md
        └── templates/
            └── prototype-notes.md
```

## Customization

The plugin uses no `~~` placeholders and depends on no external connectors. If you want different templates (e.g. Figma-only prototype, different prototype-notes structure), edit the relevant files under `skills/<skill>/templates/` after install.

## Versioning

- `0.1.0` — initial release: `/spec-start`, `jetlinks-spec` workflow skill
- `0.2.0` — adds `/spec-mock` for frontend-only mock prototypes with `prototype-notes.md`
