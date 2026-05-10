---
name: spec-start
description: Scaffold a docs/plans/[feature-name]/ directory with three pre-filled templates (requirements.md, prototype.html, plan.md) before starting spec work. Trigger when the user types "/spec-start", asks to "scaffold a new feature spec", "create a docs/plans entry", "start a new feature workflow", or equivalents in Chinese meaning "new spec", "create a new feature directory", or "pull a PRD template". After scaffolding, hand off to the jetlinks-spec workflow skill for guided filling.
argument-hint: "<feature-name>"
---

# Spec Start — Scaffold a Feature Spec Directory

## Goal

Create a fresh `docs/plans/<feature-name>/` directory containing three pre-filled templates: `requirements.md`, `prototype.html`, `plan.md`. After scaffolding, hand off to the `jetlinks-spec` workflow skill to walk the user through filling them in.

## Inputs

- **`<feature-name>`** (required, kebab-case): lowercase letters, digits, and hyphens; must start and end with an alphanumeric character. Examples: `tenant-quota`, `device-asset-export`, `202605-saas-billing`.
- **Repository root** (implicit): the project the user is currently working in. In Cowork this is the selected workspace folder; in a CLI agent it is typically the working directory.

## Behaviour

Run these steps in order. Do not skip validation.

### 1. Parse and validate the feature name

- Extract the name from the user's message. If they invoked `/spec-start foo-bar`, use `foo-bar`. If they wrote a free-form sentence, infer a kebab-case slug and confirm it with the user before continuing.
- Reject names that contain uppercase letters, underscores, spaces, or special characters. Suggest a corrected slug.
- If the user gave no name at all, ask one short question: "What's the feature short-name? (kebab-case, e.g. `tenant-quota`)".

### 2. Locate the repo root

- In Cowork: use the user's currently selected workspace folder.
- In a CLI agent: use the current working directory if it looks like a repo root (has `.git/`, `pom.xml`, `package.json`, etc.). Otherwise ask the user to confirm.

### 3. Check for collisions

- If `<repo-root>/docs/plans/<feature-name>/` already exists, stop and tell the user. Do not overwrite. Offer two choices: pick a new name, or cd into the existing directory and continue editing it.
- If `<repo-root>/docs/` does not exist, create it as part of the scaffold.

### 4. Run the scaffold

Prefer the bundled bash script:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/spec-start/scripts/scaffold-feature.sh <feature-name> <repo-root>
```

The script copies templates from `${CLAUDE_PLUGIN_ROOT}/skills/spec-start/templates/` and replaces the `{{FEATURE_NAME}}` placeholder.

If bash is unavailable in the current environment, fall back to file tools:

1. Read each template under `${CLAUDE_PLUGIN_ROOT}/skills/spec-start/templates/`
2. Replace `{{FEATURE_NAME}}` with the user's feature name
3. Write to `<repo-root>/docs/plans/<feature-name>/<filename>`

### 5. Confirm and hand off

After scaffolding succeeds, report back to the user with:

- The created directory (relative to repo root)
- The three created files
- A one-line next step: "Want me to walk you through `requirements.md` first?"

Do not start filling in templates unilaterally; wait for the user's go-ahead, then defer to the `jetlinks-spec` skill for the multi-turn spec interview.

## Output format

Keep the confirmation short. Example:

```
Created docs/plans/tenant-quota/:
  - requirements.md
  - prototype.html
  - plan.md

Next: I can walk you through requirements.md, draft a quick prototype, or jump straight to plan.md. Which?
```

## Things this skill explicitly does not do

- It does not write business code.
- It does not modify files outside `docs/plans/<feature-name>/`.
- It does not commit. The user decides when to git add / git commit.
- It does not start filling in the templates content beyond the `{{FEATURE_NAME}}` substitution; that is the workflow skill's job.

## When the scaffold is the wrong answer

If the user's request is actually an S-level fix (single file, low risk, no interface change), do not scaffold. Tell them: "This looks small enough to skip the spec — want me to just do it directly?" If they confirm, hand off without creating a `docs/plans/` entry.
