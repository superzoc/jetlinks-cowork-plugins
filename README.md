# jetlinks-cowork-plugins

A Claude Code plugin marketplace for the JetLinks team. Currently ships one plugin:

- **`jetlinks-spec`** — Four boundary-clean skills covering the spec-first feature workflow from requirements to verification:
  - `spec-workflow` — knowledge skill: the 4-phase Cowork↔CLI contract, file layout, naming, failure modes.
  - `/spec-scaffold <feature-name>` — Cowork action: design research → multi-turn spec interview → handoff prompt.
  - `/spec-prototype <feature-name>` — CLI action: scaffold a frontend-only mock page + `prototype-notes.md`.
  - `/spec-verify [<feature-name>]` — Cowork action: reconcile CLI back-fill against `requirements.md` acceptance criteria.

## Install in Claude Code

```bash
claude plugin marketplace add superzoc/jetlinks-cowork-plugins
claude plugin install jetlinks-spec@jetlinks-cowork-plugins
```

After install, `/spec-scaffold`, `/spec-prototype`, and `/spec-verify` are available in any Claude Code session. `spec-workflow` is loaded as a knowledge skill — agents reach for it when explaining the workflow to themselves or the user.

Pull the latest version any time with:

```bash
claude plugin marketplace update jetlinks-cowork-plugins
```

## Install in Cowork

Cowork installs from a `.plugin` file rather than a marketplace. Build one locally:

```bash
git clone git@github.com:superzoc/jetlinks-cowork-plugins.git /tmp/jcp
cd /tmp/jcp/jetlinks-spec
zip -rq /tmp/jetlinks-spec.plugin . -x "*.DS_Store"
```

Then drop `/tmp/jetlinks-spec.plugin` into a Cowork session — it renders as an installable card.

## Layout

```
.
├── .claude-plugin/
│   └── marketplace.json     catalog: lists jetlinks-spec
└── jetlinks-spec/           plugin source
    ├── .claude-plugin/plugin.json
    ├── README.md
    └── skills/
        ├── spec-workflow/   contract knowledge (no runtime actions)
        ├── spec-scaffold/   Cowork action: Phase 1 + 2
        ├── spec-prototype/  CLI action: frontend-only branch
        └── spec-verify/     Cowork action: Phase 4 reconciliation
```

## Adding a new plugin to this marketplace

1. Create a new sibling directory under the repo root: `<plugin-name>/`
2. Inside it, follow the standard plugin layout (`.claude-plugin/plugin.json`, `skills/...`, etc.)
3. Add an entry to `.claude-plugin/marketplace.json`:

   ```json
   {
     "name": "<plugin-name>",
     "source": "./<plugin-name>",
     "description": "..."
   }
   ```

4. Bump the plugin's `version` in `<plugin-name>/.claude-plugin/plugin.json` on every release.
5. Commit and push. Existing users pull updates with `claude plugin marketplace update jetlinks-cowork-plugins`.

## Validate before pushing

```bash
claude plugin validate .
```
