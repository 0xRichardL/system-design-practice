# System Design Practice

A deep pattern lab for learning system design through explicit requirements, invariants, failure analysis, and trade-offs. Mermaid sources and their generated SVGs live beside the notes they support.

## Catalog

| Type | Topic | Learning focus | Status |
| ---- | ----- | -------------- | ------ |
| Case study | [Copy trading](case-studies/copy-trading/README.md) | Event fan-out, sharding, ordering, and duplicate handling | Draft |
| Case study | [Money transfer](case-studies/money-transfer/README.md) | Ledgers, idempotency, outbox, CQRS, and distributed transactions | Draft |
| Case study | [Order booking](case-studies/order-booking/README.md) | Broadcast delivery and competitive claims | Draft |
| Pattern | [Service communication](patterns/service-communication/README.md) | Central load balancing and client-side discovery | Draft |
| Foundation | [Scale and reliability](foundations/scale-and-reliability/README.md) | Capacity, latency, availability, RPO, RTO, and consistency | Draft |

Start with the [system design process](docs/design-process.md). Use the [case-study template](templates/case-study.md) or [pattern template](templates/pattern.md) when adding material.

## Structure

```text
case-studies/   End-to-end systems used to apply multiple patterns
patterns/       Reusable solutions and their forces and trade-offs
foundations/    Core concepts, formulas, and terminology
docs/           Shared learning process
templates/      Starting points for new studies
scripts/        Local rendering and validation tools
```

Each topic is intentionally flat: its README, Mermaid sources, and generated SVGs stay in the same folder.

## Setup

The renderer uses Node 22, [Mermaid CLI 11.16.0](https://github.com/mermaid-js/mermaid-cli/releases/tag/11.16.0), and Puppeteer 25.9.0. The versions are installed locally and pinned in `package-lock.json`.

```bash
nvm use
make setup
```

`make setup` installs npm dependencies, installs the compatible Chrome Headless Shell, and verifies the Mermaid CLI version. A global `mmdc` installation is neither used nor required.

## Render and Validate

Render one diagram:

```bash
make render FILE=case-studies/money-transfer/architecture.mmd
```

Render every diagram:

```bash
make render-all
```

Validate Mermaid syntax and ensure every source has a current sibling SVG:

```bash
make check
```

Generated SVGs begin with metadata for the source filename, source hash, Mermaid configuration hash, and renderer version. Edit `.mmd` files rather than generated SVGs.

## Add a Study

1. Choose `case-studies`, `patterns`, or `foundations` based on the material's purpose.
2. Copy the closest template into a kebab-case topic folder as `README.md`.
3. Record unknown information as `Not yet defined`; do not silently invent requirements.
4. Add Mermaid sources directly to the topic folder.
5. Run `make render-all` and `make check`.
6. Add the topic to the catalog.

Technical claims must cite authoritative sources. Prefer original papers, standards and RFCs, official vendor documentation, and established engineering publications.

## Upgrade the Renderer

1. Check the [official Mermaid CLI releases](https://github.com/mermaid-js/mermaid-cli/releases/latest).
2. Confirm the stable Mermaid CLI release's supported Puppeteer range.
3. Install exact versions, for example:

   ```bash
   npm install --save-dev --save-exact @mermaid-js/mermaid-cli@<version> puppeteer@<version>
   ```

4. Run `make setup` and `make render-all`.
5. Visually review every changed SVG.
6. Run `make check`.
7. Commit `package.json`, `package-lock.json`, and regenerated SVGs together.

Do not install from the unreleased `master` branch. Explicit upgrades keep renderer changes reproducible and reviewable.

## Editor Support

The repository recommends the VS Code Mermaid Preview and Code Spell Checker extensions through `.vscode/extensions.json`.
