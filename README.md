# system-design-practice

A collection of system design diagrams and practice materials using Mermaid.

## Project Structure

```
system-design-practice/
├── diagrams/              # System design diagrams organized by topic
│   ├── copy-trading/
│   │   └── concept.mmd   # Copy trading system diagram
│   └── money-transfer/
│       └── concept.mmd   # Money transfer system diagram
├── scripts/
│   └── render.sh         # Script to render Mermaid diagrams to SVG
├── Makefile              # Build commands
└── README.md
```

## Setup

### Prerequisites

#### 1. **Node.js**: Install Node.js (v16 or later)
  ```bash
  # macOS (using Homebrew)
  brew install node
  
  # Verify installation
  node --version
  npm --version
  ```

#### 2. **Mermaid CLI**: Install the Mermaid command-line tool
  ```bash
  make init
  ```
  Or manually:
  ```bash
  npm install -g @mermaid-js/mermaid-cli
  ```

#### 3. **VS Code Mermaid Extension** (Recommended for editing)
  
  [Mermaid Preview extension](https://marketplace.visualstudio.com/items?itemName=vstirbu.vscode-mermaid-preview)

## Rendering Diagrams

### Render a Single Diagram

To convert a `.mmd` file to SVG:

```bash
make render diagrams/copy-trading/concept.mmd
```

Or use the script directly:

```bash
./scripts/render.sh diagrams/copy-trading/concept.mmd
```

This will generate an SVG file in the same directory as the source file:
- Input: `diagrams/copy-trading/concept.mmd`
- Output: `diagrams/copy-trading/concept.svg`

### Preview in VS Code

1. Open any `.mmd` file
2. Right-click and select "Open Preview" (if using Mermaid Preview extension)
3. Or use the command palette (⇧⌘P) and search for "Mermaid: Preview"

## Usage

### Creating New Diagrams

1. Create a new `.mmd` file in the appropriate `diagrams/` subdirectory
2. Write your Mermaid diagram syntax
3. Preview in VS Code to verify
4. Render to SVG using `make render <path-to-file>`

### Example

```bash
# Create a new diagram
mkdir -p diagrams/api-gateway
touch diagrams/api-gateway/concept.mmd

# Edit the file and add Mermaid syntax

# Render to SVG
make render diagrams/api-gateway/concept.mmd
```