#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXPECTED_NODE_MAJOR="$(tr -d '[:space:]' < "$ROOT_DIR/.nvmrc")"

if ! command -v node >/dev/null 2>&1; then
  echo "Error: Node.js is required; install Node $EXPECTED_NODE_MAJOR" >&2
  exit 1
fi

ACTUAL_NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
if [ "$ACTUAL_NODE_MAJOR" != "$EXPECTED_NODE_MAJOR" ]; then
  echo "Error: Node $EXPECTED_NODE_MAJOR is required; current version is $(node --version)" >&2
  exit 1
fi

cd "$ROOT_DIR"
npm ci
npx --no-install puppeteer browsers install chrome-headless-shell

EXPECTED_MERMAID_VERSION="$(node -p "require('./package.json').devDependencies['@mermaid-js/mermaid-cli']")"
ACTUAL_MERMAID_VERSION="$(npx --no-install mmdc --version)"

if [ "$ACTUAL_MERMAID_VERSION" != "$EXPECTED_MERMAID_VERSION" ]; then
  echo "Error: Mermaid CLI version $ACTUAL_MERMAID_VERSION does not match $EXPECTED_MERMAID_VERSION" >&2
  exit 1
fi

echo "Installed Mermaid CLI $ACTUAL_MERMAID_VERSION with Chrome Headless Shell"
