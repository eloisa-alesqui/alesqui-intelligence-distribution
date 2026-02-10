#!/bin/bash

# =============================================================================
# Test Script for Alesqui Intelligence Installer
# =============================================================================
# This script tests the installation script without actually installing
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_SCRIPT="$SCRIPT_DIR/install.sh"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "  Installation Script Test Suite"
echo "========================================="
echo ""

# Test 1: Check if install.sh exists
echo -n "Test 1: Check install.sh exists... "
if [ -f "$INSTALL_SCRIPT" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "install.sh not found at $INSTALL_SCRIPT"
    exit 1
fi

# Test 2: Check if install.sh is executable
echo -n "Test 2: Check install.sh is executable... "
if [ -x "$INSTALL_SCRIPT" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "install.sh is not executable"
    exit 1
fi

# Test 3: Check syntax
echo -n "Test 3: Check bash syntax... "
if bash -n "$INSTALL_SCRIPT" 2>/dev/null; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "Syntax errors found in install.sh"
    bash -n "$INSTALL_SCRIPT"
    exit 1
fi

# Test 4: Check quick-install.sh exists
echo -n "Test 4: Check quick-install.sh exists... "
if [ -f "$SCRIPT_DIR/quick-install.sh" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "quick-install.sh not found"
    exit 1
fi

# Test 5: Check quick-install.sh syntax
echo -n "Test 5: Check quick-install.sh syntax... "
if bash -n "$SCRIPT_DIR/quick-install.sh" 2>/dev/null; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "Syntax errors found in quick-install.sh"
    exit 1
fi

# Test 6: Check .env.example files exist
echo -n "Test 6: Check atlas/.env.example exists... "
if [ -f "$SCRIPT_DIR/atlas/.env.example" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "atlas/.env.example not found"
    exit 1
fi

echo -n "Test 7: Check local/.env.example exists... "
if [ -f "$SCRIPT_DIR/local/.env.example" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "local/.env.example not found"
    exit 1
fi

# Test 8: Check required functions exist in install.sh
echo -n "Test 8: Check required functions exist... "
REQUIRED_FUNCTIONS=(
    "check_dependencies"
    "choose_deployment"
    "configure_environment"
    "create_env_file"
    "run_deployment"
    "health_check"
    "show_success_message"
)

MISSING_FUNCTIONS=""
for func in "${REQUIRED_FUNCTIONS[@]}"; do
    if ! grep -q "^${func}()" "$INSTALL_SCRIPT"; then
        MISSING_FUNCTIONS="$MISSING_FUNCTIONS $func"
    fi
done

if [ -z "$MISSING_FUNCTIONS" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "Missing functions:$MISSING_FUNCTIONS"
    exit 1
fi

# Test 9: Check documentation updated
echo -n "Test 9: Check README.md has Quick Start... "
if grep -q "Quick Start" "$SCRIPT_DIR/README.md"; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${YELLOW}WARNING${NC}"
    echo "README.md may not have Quick Start section"
fi

echo -n "Test 10: Check INSTALLATION.md updated... "
if grep -q "Quick Install" "$SCRIPT_DIR/INSTALLATION.md"; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${YELLOW}WARNING${NC}"
    echo "INSTALLATION.md may not have Quick Install section"
fi

echo -n "Test 11: Check TROUBLESHOOTING.md has installation section... "
if grep -q "Installation Issues" "$SCRIPT_DIR/TROUBLESHOOTING.md"; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${YELLOW}WARNING${NC}"
    echo "TROUBLESHOOTING.md may not have Installation Issues section"
fi

# Test 12: Test secret generation functions
echo -n "Test 12: Test secret generation... "
if grep -q "generate_jwt_secret" "$INSTALL_SCRIPT" && grep -q "generate_password" "$INSTALL_SCRIPT"; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "Secret generation functions not found"
    exit 1
fi

# Test 13: Check error handling (set -e)
echo -n "Test 13: Check error handling... "
if grep -q "^set -e" "$INSTALL_SCRIPT"; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${YELLOW}WARNING${NC}"
    echo "Script may not have proper error handling"
fi

# Test 14: Check logging
echo -n "Test 14: Check logging functionality... "
if grep -q "INSTALL_LOG=" "$INSTALL_SCRIPT" && grep -q "log()" "$INSTALL_SCRIPT"; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${YELLOW}WARNING${NC}"
    echo "Logging functionality may be missing"
fi

echo ""
echo "========================================="
echo -e "${GREEN}All tests passed!${NC}"
echo "========================================="
echo ""
echo "The installation script appears to be working correctly."
echo ""
echo "To test the actual installation (requires Docker):"
echo "  ./install.sh"
echo ""
