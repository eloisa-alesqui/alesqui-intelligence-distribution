#!/bin/bash

# =============================================================================
# Alesqui Intelligence - Quick Install Entry Point
# =============================================================================
# This script can be curled and piped to bash for one-command installation:
#   curl -fsSL https://get.alesqui.com/install.sh | bash
# =============================================================================

set -e

REPO="eloisa-alesqui/alesqui-intelligence-distribution"
BRANCH="main"
INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/$REPO/$BRANCH/install.sh"

echo "Downloading Alesqui Intelligence installer..."

# Download and execute the full installer
if command -v curl &> /dev/null; then
    curl -fsSL "$INSTALL_SCRIPT_URL" | bash
elif command -v wget &> /dev/null; then
    wget -qO- "$INSTALL_SCRIPT_URL" | bash
else
    echo "Error: Neither curl nor wget is available"
    echo "Please install curl or wget and try again"
    exit 1
fi
