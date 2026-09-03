#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

found=0
while IFS= read -r source_file; do
  found=1
  "$ROOT_DIR/scripts/render.sh" "$source_file"
done < <(
  find \
    "$ROOT_DIR/case-studies" \
    "$ROOT_DIR/patterns" \
    "$ROOT_DIR/foundations" \
    -type f -name '*.mmd' -print | sort
)

if [ "$found" -eq 0 ]; then
  echo "Error: no Mermaid sources found" >&2
  exit 1
fi
