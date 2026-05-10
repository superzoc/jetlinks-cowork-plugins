# jetlinks-cowork-plugins

A Claude Code plugin marketplace for the JetLinks team. Currently ships one plugin:

- **`jetlinks-spec`** — Cowork-to-CLI feature spec handoff. Use Cowork to draft requirements, prototype, and implementation plan, then hand off to a CLI agent to implement. Bridges via a `docs/plans/<feature>/` directory.

## Install in Claude Code

```bash
claude plugin marketplace add superzoc/jetlinks-cowork-plugins
claude plugin install jetlinks-spec@jetlinks-cowork-plugins
```

After install, `/spec-start <feature-name>` is available in any Claude Code session — it scaffolds `docs/plans/<feature-name>/` with three pre-filled templates (`requirements.md`, `prototype.html`, `plan.md`).

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
        └── spec-start/     /spec-start <name> action skill
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
