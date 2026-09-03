#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$ROOT_DIR/mermaid.config.json"

sha256_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    echo "Error: shasum or sha256sum is required" >&2
    return 1
  fi
}

if [ ! -x "$ROOT_DIR/node_modules/.bin/mmdc" ]; then
  echo "Error: local Mermaid CLI is not installed; run 'make setup'" >&2
  exit 1
fi

EXPECTED_VERSION="$(node -p "require('$ROOT_DIR/package.json').devDependencies['@mermaid-js/mermaid-cli']")"
ACTUAL_VERSION="$(cd "$ROOT_DIR" && npx --no-install mmdc --version)"

if [ "$ACTUAL_VERSION" != "$EXPECTED_VERSION" ]; then
  echo "Error: Mermaid CLI version $ACTUAL_VERSION does not match pinned version $EXPECTED_VERSION" >&2
  exit 1
fi

CONFIG_HASH="$(sha256_file "$CONFIG_FILE")"
TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/system-design-check.XXXXXX")"

cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

count=0
while IFS= read -r source_file; do
  count=$((count + 1))
  svg_file="${source_file%.mmd}.svg"

  if [ ! -f "$svg_file" ]; then
    echo "Error: generated SVG is missing for $source_file" >&2
    exit 1
  fi

  source_name="$(basename "$source_file")"
  source_hash="$(sha256_file "$source_file")"
  expected_metadata="<!-- generated-by=scripts/render.sh source=$source_name source-sha256=$source_hash config-sha256=$CONFIG_HASH mermaid-cli=$ACTUAL_VERSION -->"
  actual_metadata="$(head -n 1 "$svg_file")"

  if [ "$actual_metadata" != "$expected_metadata" ]; then
    echo "Error: generated SVG is stale or has invalid metadata: $svg_file" >&2
    exit 1
  fi

  npx --no-install mmdc \
    --quiet \
    --configFile "$CONFIG_FILE" \
    --input "$source_file" \
    --output "$TEMP_DIR/diagram-$count.svg"
done < <(
  find \
    "$ROOT_DIR/case-studies" \
    "$ROOT_DIR/patterns" \
    "$ROOT_DIR/foundations" \
    -type f -name '*.mmd' -print | sort
)

if [ "$count" -eq 0 ]; then
  echo "Error: no Mermaid sources found" >&2
  exit 1
fi

echo "Validated $count Mermaid sources and generated SVGs"
