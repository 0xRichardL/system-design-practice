#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$ROOT_DIR/mermaid.config.json"

usage() {
  echo "Usage: $0 <path-to-mmd-file>" >&2
}

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

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

SOURCE_FILE="$1"

if [ ! -f "$SOURCE_FILE" ]; then
  echo "Error: Mermaid source not found: $SOURCE_FILE" >&2
  exit 1
fi

if [[ "$SOURCE_FILE" != *.mmd ]]; then
  echo "Error: source must have a .mmd extension: $SOURCE_FILE" >&2
  exit 1
fi

SOURCE_DIR="$(cd "$(dirname "$SOURCE_FILE")" && pwd)"
SOURCE_FILE="$SOURCE_DIR/$(basename "$SOURCE_FILE")"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Mermaid configuration not found: $CONFIG_FILE" >&2
  exit 1
fi

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

OUTPUT_FILE="${SOURCE_FILE%.mmd}.svg"
SOURCE_NAME="$(basename "$SOURCE_FILE")"
SOURCE_HASH="$(sha256_file "$SOURCE_FILE")"
CONFIG_HASH="$(sha256_file "$CONFIG_FILE")"
TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/system-design-render.XXXXXX")"
TEMP_SVG="$TEMP_DIR/output.svg"

cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

cd "$ROOT_DIR"
npx --no-install mmdc \
  --quiet \
  --configFile "$CONFIG_FILE" \
  --input "$SOURCE_FILE" \
  --output "$TEMP_SVG"

{
  printf '<!-- generated-by=scripts/render.sh source=%s source-sha256=%s config-sha256=%s mermaid-cli=%s -->\n' \
    "$SOURCE_NAME" "$SOURCE_HASH" "$CONFIG_HASH" "$ACTUAL_VERSION"
  cat "$TEMP_SVG"
  printf '\n'
} > "$OUTPUT_FILE"

echo "Generated $OUTPUT_FILE"
