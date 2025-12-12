#!/bin/bash

# Script to render all Mermaid diagram files (.mmd) in the diagrams folder to SVG format
# Uses @mermaid-js/mermaid-cli (mmdc command)

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

npm install -g @mermaid-js/mermaid-cli

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DIAGRAMS_DIR="$PROJECT_ROOT/diagrams"

echo -e "${YELLOW}Starting Mermaid diagram rendering...${NC}"
echo "Diagrams directory: $DIAGRAMS_DIR"
echo ""

# Check if diagrams directory exists
if [ ! -d "$DIAGRAMS_DIR" ]; then
    echo -e "${RED}Error: Diagrams directory not found: $DIAGRAMS_DIR${NC}"
    exit 1
fi

# Find all .mmd files in the diagrams directory
MMD_FILES=$(find "$DIAGRAMS_DIR" -type f -name "*.mmd")

# Check if any .mmd files were found
if [ -z "$MMD_FILES" ]; then
    echo -e "${YELLOW}No .mmd files found in $DIAGRAMS_DIR${NC}"
    exit 0
fi

# Count total files
TOTAL_FILES=$(echo "$MMD_FILES" | wc -l | tr -d ' ')
CURRENT=0

echo -e "Found ${GREEN}$TOTAL_FILES${NC} Mermaid diagram(s) to render"
echo ""

# Render each .mmd file to .svg
while IFS= read -r mmd_file; do
    CURRENT=$((CURRENT + 1))
    
    # Get the output SVG filename (replace .mmd extension with .svg)
    svg_file="${mmd_file%.mmd}.svg"
    
    # Get relative path for display
    rel_path="${mmd_file#$DIAGRAMS_DIR/}"
    
    echo -e "[$CURRENT/$TOTAL_FILES] Rendering: ${GREEN}$rel_path${NC}"
    
    # Run mmdc command to render the diagram
    # -i: input file
    # -o: output file
    # -b: background color (transparent)
    if mmdc -i "$mmd_file" -o "$svg_file" 2>&1; then
        echo -e "  ✓ Generated: ${svg_file#$DIAGRAMS_DIR/}"
    else
        echo -e "  ${RED}✗ Failed to render: $rel_path${NC}"
    fi
    
    echo ""
done <<< "$MMD_FILES"

echo -e "${GREEN}✓ Diagram rendering complete!${NC}"
