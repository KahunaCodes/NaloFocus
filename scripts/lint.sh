#!/bin/bash

# NaloFocus Linting Script
# This script runs SwiftLint and optionally can fix auto-correctable issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo -e "${RED}Error: SwiftLint is not installed${NC}"
    echo "Install it using: brew install swiftlint"
    exit 1
fi

# Parse command line arguments
MODE="lint"
if [[ "$1" == "fix" ]] || [[ "$1" == "--fix" ]]; then
    MODE="fix"
fi

# Get the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${YELLOW}Running SwiftLint in $MODE mode...${NC}"

if [[ "$MODE" == "fix" ]]; then
    # Run SwiftLint autocorrect
    echo "Fixing auto-correctable issues..."
    swiftlint --fix --config .swiftlint.yml
    echo -e "${GREEN}✓ Auto-corrections applied${NC}"

    # Run lint to show remaining issues
    echo ""
    echo "Checking for remaining issues..."
fi

# Run SwiftLint
if swiftlint --config .swiftlint.yml --quiet; then
    echo -e "${GREEN}✓ No linting issues found!${NC}"
    exit 0
else
    # Run again without --quiet to show the issues
    echo -e "${RED}Linting issues found:${NC}"
    swiftlint --config .swiftlint.yml

    if [[ "$MODE" == "lint" ]]; then
        echo ""
        echo -e "${YELLOW}Tip: Run './scripts/lint.sh fix' to auto-fix some issues${NC}"
    fi

    exit 1
fi