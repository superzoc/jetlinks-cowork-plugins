# jetlinks-cowork-plugins

A Claude Code plugin marketplace for the JetLinks team. Currently ships one plugin:

- **`jetlinks-spec`** — Two commands for spec-driven and frontend-prototype workflows:
  - `/spec-start <feature-name>` — Cowork-to-CLI feature spec handoff (`requirements.md` + `prototype.html` + `plan.md` under `docs/plans/<feature>/`).
  - `/spec-mock <feature-name>` — frontend-only prototype: scaffold a page/route directly in the project's frontend (`ui/` / `runtime-ui/` etc.) wired with mock data, plus a lightweight `prototype-notes.md`.

## Install in Claude Code

```bash
claude plugin marketplace add superzoc/jetlinks-cowork-plugins
claude plugin install jetlinks-spec@jetlinks-cowork-plugins
```

After install, both `/spec-start <feature-name>` and `/spec-mock <feature-name>` are available in any Claude Code session.

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
│   └── marketplace.json    catalog: lists jetlinks-spec
└── jetlinks-spec/          plugin source
    ├── .claude-plugin/plugin.json
    ├── README.md
    └── skills/
        ├── jetlinks-spec/  workflow knowledge skill
        ├── spec-start/     /spec-start <name> action skill
        └── spec-mock/      /spec-mock <name> action skill
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
