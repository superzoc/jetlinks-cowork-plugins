# jetlinks-spec

A small plugin that defines a **Cowork ↔ CLI handoff workflow** for feature work:

- Use **Cowork** to do requirements analysis, prototype design, and write the implementation plan.
- Use the **CLI agent** (e.g. Claude Code) to implement the plan, run verifications, and back-fill commit / PR results.
- The two sides exchange a single artefact: a `docs/plans/<feature>/` directory with three files (`requirements.md`, `prototype.html`, `plan.md`) committed to the repo.

Despite the name, the plugin is **project-agnostic**. It does not assume anything specific about JetLinks; you can install it in any repo where you want a lightweight spec-then-implement flow.

## Components

| Component                  | Type   | Purpose                                                                                  |
| -------------------------- | ------ | ---------------------------------------------------------------------------------------- |
| `skills/jetlinks-spec`     | Skill  | Workflow knowledge: explains the 3-phase Cowork↔CLI flow, naming conventions, hand-off rules. |
| `skills/spec-start`        | Skill  | Action: invoked as `/spec-start <feature-name>` to scaffold `docs/plans/<feature>/` from templates. |

## Setup

No environment variables, no MCP servers. The plugin only writes files inside the user's currently selected workspace folder.

## Usage

### Cowork side — write the spec

1. Run `/spec-start <feature-name>` (kebab-case). The plugin creates `docs/plans/<feature-name>/` with three pre-filled templates.
2. The agent walks you through filling in `requirements.md` and `prototype.html` (or pasting a Figma link).
3. The agent drafts `plan.md` and confirms with you before commit.

### CLI side — implement

In your CLI agent (Claude Code etc.):

```
读取 docs/plans/<feature-name>/plan.md，按计划实施，
完成后把 commit hash、PR 链接和验证结果回填到同一份 plan.md。
```

The CLI agent reads `plan.md` as the single source of truth, implements, runs verifications, and back-fills results into the same file.

### Cowork side — verify

Reopen the feature directory in Cowork and let the agent diff the back-filled `plan.md` against the original acceptance criteria in `requirements.md`.

## Customization

The plugin uses no `~~` placeholders and depends on no external connectors. If you want a different prototype format (e.g. Figma-only), edit `skills/spec-start/templates/` after install.

## File layout

```
jetlinks-spec/
├── .claude-plugin/plugin.json
├── README.md
└── skills/
    ├── jetlinks-spec/SKILL.md
    └── spec-start/
        ├── SKILL.md
        ├── templates/
        │   ├── requirements.md
        │   ├── prototype.html
        │   └── plan.md
        └── scripts/
            └── scaffold-feature.sh
```
