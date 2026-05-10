#!/usr/bin/env bash
# Scaffold docs/plans/<feature-name>/ from the spec-start templates.
#
# Usage:
#   scaffold-feature.sh <feature-name> [<repo-root>]
#
# Arguments:
#   <feature-name>  kebab-case slug (lowercase letters, digits, hyphens)
#   <repo-root>     optional; defaults to the current working directory
#
# Behaviour:
#   - Validates the feature name.
#   - Refuses to overwrite an existing directory.
#   - Creates docs/plans/<feature-name>/ under <repo-root> with the three
#     templates, substituting {{FEATURE_NAME}} with the slug.
#
# Exit codes:
#   0  success
#   1  usage / validation error
#   2  target already exists
#   3  template files missing

set -euo pipefail

# --- args ---------------------------------------------------------------
NAME="${1:-}"
REPO_ROOT="${2:-$(pwd)}"

if [ -z "$NAME" ]; then
  echo "usage: scaffold-feature.sh <feature-name> [<repo-root>]" >&2
  exit 1
fi

# kebab-case: starts/ends alphanumeric, lowercase letters/digits/hyphens, no double hyphens
if ! printf '%s' "$NAME" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
  echo "error: feature name must be kebab-case (got: \"$NAME\")" >&2
  echo "       allowed: lowercase letters, digits, single hyphens" >&2
  exit 1
fi

if [ ! -d "$REPO_ROOT" ]; then
  echo "error: repo-root is not a directory: $REPO_ROOT" >&2
  exit 1
fi

# --- locate templates ---------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"

for f in requirements.md prototype.html plan.md; do
  if [ ! -f "$TEMPLATES_DIR/$f" ]; then
    echo "error: missing template: $TEMPLATES_DIR/$f" >&2
    exit 3
  fi
done

# --- target -------------------------------------------------------------
TARGET="$REPO_ROOT/docs/plans/$NAME"

if [ -e "$TARGET" ]; then
  echo "error: target already exists: $TARGET" >&2
  echo "       pick a different name, or edit the existing directory directly" >&2
  exit 2
fi

mkdir -p "$TARGET"

# --- copy + substitute --------------------------------------------------
# sed -i.bak is portable across BSD (macOS) and GNU sed.
substitute() {
  local file="$1"
  sed -i.bak "s/{{FEATURE_NAME}}/$NAME/g" "$file"
  rm -f "${file}.bak"
}

cp "$TEMPLATES_DIR/requirements.md" "$TARGET/requirements.md"
cp "$TEMPLATES_DIR/prototype.html"  "$TARGET/prototype.html"
cp "$TEMPLATES_DIR/plan.md"         "$TARGET/plan.md"

substitute "$TARGET/requirements.md"
substitute "$TARGET/prototype.html"
substitute "$TARGET/plan.md"

# --- report -------------------------------------------------------------
# Print a path relative to repo root if possible, else absolute.
REL_TARGET="docs/plans/$NAME"
echo "scaffolded: $REL_TARGET/"
echo "  - $REL_TARGET/requirements.md"
echo "  - $REL_TARGET/prototype.html"
echo "  - $REL_TARGET/plan.md"
