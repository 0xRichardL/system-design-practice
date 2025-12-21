#!/bin/bash

# Script to render a single Mermaid diagram file (.mmd) to SVG format
# Uses @mermaid-js/mermaid-cli (mmdc command)
# Usage: ./render.sh <path-to-mmd-file>

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if file argument is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Please provide a .mmd file to render${NC}"
    echo "Usage: $0 <path-to-mmd-file>"
    exit 1
fi

MMD_FILE="$1"

# Check if file exists
if [ ! -f "$MMD_FILE" ]; then
    echo -e "${RED}Error: File not found: $MMD_FILE${NC}"
    exit 1
fi

# Check if file has .mmd extension
if [[ ! "$MMD_FILE" =~ \.mmd$ ]]; then
    echo -e "${RED}Error: File must have .mmd extension${NC}"
    exit 1
fi

# Get the output SVG filename
SVG_FILE="${MMD_FILE%.mmd}.svg"

echo -e "Rendering: ${GREEN}$MMD_FILE${NC}"

# Run mmdc command to render the diagram
if mmdc -i "$MMD_FILE" -o "$SVG_FILE" 2>&1; then
    echo -e "${GREEN}✓ Generated: $SVG_FILE${NC}"
else
    echo -e "${RED}✗ Failed to render diagram${NC}"
    exit 1
fi
