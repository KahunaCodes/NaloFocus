#!/bin/bash

# Alternative Swift linting script using compiler warnings
# This script uses Swift compiler warnings as a linting mechanism

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Running Swift compiler-based linting...${NC}"
echo ""

# Get the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Check for common issues using grep
echo -e "${YELLOW}Checking for code style issues...${NC}"

ISSUES_FOUND=0

# Check for print statements
echo -n "Checking for print statements... "
if grep -r "^\s*print(" Sources --include="*.swift" 2>/dev/null | grep -v "// print" > /dev/null; then
    echo -e "${RED}✗${NC}"
    echo "  Found print statements (use proper logging instead):"
    grep -rn "^\s*print(" Sources --include="*.swift" 2>/dev/null | grep -v "// print" | head -5
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo -e "${GREEN}✓${NC}"
fi

# Check for force unwrapping
echo -n "Checking for force unwrapping... "
if grep -r "!\." Sources --include="*.swift" 2>/dev/null | grep -v "//" > /dev/null; then
    echo -e "${YELLOW}⚠${NC}"
    echo "  Found force unwrapping (consider safer alternatives):"
    grep -rn "!\." Sources --include="*.swift" 2>/dev/null | grep -v "//" | head -5
fi

# Check for TODO/FIXME comments
echo -n "Checking for TODO/FIXME comments... "
TODO_COUNT=$(grep -r "// TODO\|// FIXME" Sources --include="*.swift" 2>/dev/null | wc -l | xargs)
if [ "$TODO_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠ Found $TODO_COUNT TODO/FIXME comments${NC}"
else
    echo -e "${GREEN}✓${NC}"
fi

# Check for long lines
echo -n "Checking for long lines (>120 chars)... "
LONG_LINES=$(find Sources -name "*.swift" -exec awk 'length > 120 {print FILENAME":"NR": Line too long ("length" chars)"}' {} \; | wc -l | xargs)
if [ "$LONG_LINES" -gt 0 ]; then
    echo -e "${YELLOW}⚠ Found $LONG_LINES long lines${NC}"
else
    echo -e "${GREEN}✓${NC}"
fi

echo ""
echo -e "${YELLOW}Running Swift compiler checks...${NC}"

# Build with warnings
# Note: Swift 6 doesn't support all warning flags, using standard build
if swift build 2>&1 | grep -E "warning:" > /tmp/swift-lint-output.txt; then
    echo -e "${RED}Compiler warnings/errors found:${NC}"
    cat /tmp/swift-lint-output.txt
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo -e "${GREEN}✓ No compiler warnings${NC}"
fi

# Summary
echo ""
echo "──────────────────────────────────────"
if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✓ Linting passed with no critical issues!${NC}"
    exit 0
else
    echo -e "${RED}✗ Found $ISSUES_FOUND critical issue(s) that should be addressed${NC}"
    exit 1
fi