# jetlinks-cowork-plugins (local marketplace)

A local Claude Code marketplace for the JetLinks team. Currently ships one plugin:

- **`jetlinks-spec`** — Cowork-to-CLI feature spec handoff. Use Cowork to draft requirements, prototype, and implementation plan, then hand off to a CLI agent to implement. Bridges via a `docs/plans/<feature>/` directory.

## Install in Claude Code

From the repo root:

```bash
claude plugin marketplace add ./jetlinks-marketplace
claude plugin install jetlinks-spec@jetlinks-cowork-plugins
```

After install, `/spec-start <feature-name>` is available in any Claude Code session — it scaffolds `docs/plans/<feature-name>/` with three pre-filled templates (`requirements.md`, `prototype.html`, `plan.md`).

## Install in Cowork

In Cowork, plugins are installed from a `.plugin` file rather than a marketplace. To produce one:

```bash
cd jetlinks-marketplace/jetlinks-spec
zip -rq /tmp/jetlinks-spec.plugin . -x "*.DS_Store"
```

Then drop `/tmp/jetlinks-spec.plugin` into a Cowork session — it renders as an installable card. The repo's `.gitignore` already excludes `*.plugin`, so the build artifact won't get committed.

## Layout

```
jetlinks-marketplace/
├── .claude-plugin/
│   └── marketplace.json    catalog: lists jetlinks-spec
└── jetlinks-spec/          plugin source
    ├── .claude-plugin/plugin.json
    ├── README.md
    └── skills/
        ├── jetlinks-spec/  workflow knowledge skill
        └── spec-start/     /spec-start <name> action skill
```

## Updating

Edit files under `jetlinks-marketplace/jetlinks-spec/`, bump `version` in its `plugin.json`, then commit. Team members pick up the change with:

```bash
claude plugin marketplace update jetlinks-cowork-plugins
```
