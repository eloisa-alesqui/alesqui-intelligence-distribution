#!/bin/bash

# Uninstall script for Alesqui Intelligence

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Determine script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${YELLOW}⚠️  Alesqui Intelligence Uninstaller${NC}"
echo ""
echo "Installation directory: $INSTALL_DIR"
echo ""
echo "This will:"
echo "  - Stop all Docker containers"
echo "  - Remove Docker containers and networks"
echo "  - Optionally remove volumes (database data)"
echo "  - Optionally remove installation directory"
echo ""

read -p "Continue with uninstallation? [y/N]: " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

# Stop services
echo ""
echo "Stopping services..."
if [ -d "$INSTALL_DIR/atlas" ]; then
    cd "$INSTALL_DIR/atlas" && docker compose down 2>/dev/null || true
fi
if [ -d "$INSTALL_DIR/local" ]; then
    cd "$INSTALL_DIR/local" && docker compose down 2>/dev/null || true
fi

read -p "Remove database data (volumes)? [y/N]: " remove_volumes
if [[ $remove_volumes =~ ^[Yy]$ ]]; then
    if [ -d "$INSTALL_DIR/atlas" ]; then
        cd "$INSTALL_DIR/atlas" && docker compose down -v 2>/dev/null || true
    fi
    if [ -d "$INSTALL_DIR/local" ]; then
        cd "$INSTALL_DIR/local" && docker compose down -v 2>/dev/null || true
    fi
    echo -e "${GREEN}✅ Volumes removed${NC}"
fi

read -p "Remove installation directory? [y/N]: " remove_dir
if [[ $remove_dir =~ ^[Yy]$ ]]; then
    echo "Removing: $INSTALL_DIR"
    cd ~
    rm -rf "$INSTALL_DIR"
    echo -e "${GREEN}✅ Installation directory removed${NC}"
fi

echo ""
echo -e "${GREEN}✅ Uninstallation complete${NC}"
