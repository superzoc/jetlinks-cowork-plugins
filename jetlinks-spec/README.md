# jetlinks-spec

A plugin that runs the JetLinks spec-first feature workflow. It carves the lifecycle into **four boundary-clean skills**, each owning one phase, so the agent and the user always know which mode they're in.

| Skill                | Type      | Side   | Owns                                                                                          |
| -------------------- | --------- | ------ | --------------------------------------------------------------------------------------------- |
| `spec-workflow`      | Knowledge | both   | The 4-phase Cowork↔CLI contract, file layout, naming, failure modes. No runtime actions.      |
| `/spec-scaffold`     | Action    | Cowork | Phase 1 + 2: validate name, scaffold dir, design research, multi-turn spec fill, handoff prompt. |
| `/spec-prototype`    | Action    | CLI    | Frontend-only branch: scaffold a mock page + route + `prototype-notes.md` in the real frontend.  |
| `/spec-verify`       | Action    | Cowork | Phase 4: reconcile CLI back-fill against `requirements.md` acceptance criteria; append gap notes. |

Despite the name, the plugin is **project-agnostic**. It works in any repo with a `docs/plans/` convention; the frontend boundary detection in `/spec-prototype` adapts to whatever frontend dirs the project has.

## The 4-phase workflow

```
Phase 1: Cowork — spec        /spec-scaffold      → requirements.md + prototype.html + plan.md + references.md
   ↓
Phase 2: Handoff              /spec-scaffold      → commit msg + CLI handoff prompt
   ↓
Phase 3: CLI — implement      (CLI's own skills)  → code + back-fill into plan.md
   ↓
Phase 4: Cowork — verify      /spec-verify        → gap notes appended to plan.md
```

`spec-workflow` is the knowledge skill consulted across all four phases. `/spec-prototype` is an alternative branch for frontend-only features that skips Phase 3's real implementation in favor of a mock.

## Setup

No environment variables, no MCP servers. The plugin only writes files inside the user's currently selected workspace folder (under `docs/plans/<feature-name>/`) — Cowork-side skills never touch business code by contract.

## Usage

### Track A — full spec, real implementation

1. **Cowork**: run `/spec-scaffold <feature-name>` (kebab-case). The agent:
   - validates the name and scaffolds `docs/plans/<feature-name>/`
   - runs a **design-research pass** (WebSearch + connectors → `references.md`) so the interview is informed by prior art
   - walks you through filling `requirements.md` and `prototype.html` (or pasting a Figma link)
   - drafts `plan.md`, with explicit Out-of-scope + Risks sections, and confirms with you
2. **Handoff**: agent produces a suggested commit message and the CLI prompt:

   ```
   读取 docs/plans/<feature-name>/plan.md，按计划实施。
   完成后把 commit hash、PR 链接和验证结果回填到同一份 plan.md，
   不要新增独立的变更说明文件。
   ```

3. **CLI**: paste into Claude Code (or another CLI agent). It reads `plan.md` as the contract, implements, runs verifications, and back-fills commit hash / PR link / verification results into the same `plan.md`.
4. **Cowork**: run `/spec-verify [<feature-name>]`. The agent compares the back-fill against acceptance criteria, classifies each as PASS / PARTIAL / FAIL / MISSING EVIDENCE, surfaces any scope drift, and appends the gap notes to the bottom of `plan.md`.

### Track B — frontend-only prototype

1. **Cowork**: run `/spec-scaffold <feature-name>` to fill `requirements.md` + `prototype.html`, stub `plan.md` pointing at `/spec-prototype`.
2. **CLI**: run `/spec-prototype <feature-name>`. The agent picks the frontend boundary (`ui/` vs `runtime-ui/` etc.), studies existing routing / page / mock conventions, then scaffolds:
   - a new page component matching project style
   - a new route entry
   - mock data adjacent to the page (inline or fixture file, whichever the project uses)
3. Agent writes `docs/plans/<feature-name>/prototype-notes.md` capturing scope, mock data shape, and what real backend integration would need.
4. Run the project's dev server and iterate on the design.
5. When ready to ship for real, promote to Track A: keep using the same `docs/plans/<feature-name>/` directory, fill out `plan.md` properly, and use `prototype-notes.md` as input.

## File layout

```
jetlinks-spec/
├── .claude-plugin/plugin.json
├── README.md
└── skills/
    ├── spec-workflow/
    │   └── SKILL.md
    ├── spec-scaffold/
    │   ├── SKILL.md
    │   ├── templates/
    │   │   ├── requirements.md
    │   │   ├── prototype.html
    │   │   ├── plan.md
    │   │   └── references.md     ← design-research output template
    │   └── scripts/
    │       └── scaffold-feature.sh
    ├── spec-prototype/
    │   ├── SKILL.md
    │   └── templates/
    │       └── prototype-notes.md
    └── spec-verify/
        └── SKILL.md
```

## Customization

The plugin uses no `~~` placeholders and depends on no external connectors. If you want different templates (e.g. Figma-only prototype, different `prototype-notes.md` structure, a custom `references.md` skeleton), edit the relevant files under `skills/<skill>/templates/` after install.

## Versioning

- `0.1.0` — initial release: spec workflow scaffold + knowledge skill.
- `0.2.0` — added frontend-only prototype branch with `prototype-notes.md`.
- `0.3.0` — re-organized into four phase-aligned skills (`spec-workflow`, `spec-scaffold`, `spec-prototype`, `spec-verify`); added a design-research step + `references.md` to `spec-scaffold`; added `spec-verify` for Phase 4 reconciliation.
