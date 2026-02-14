#!/bin/bash

# =============================================================================
# Alesqui Intelligence - Packaging Script
# =============================================================================
# Creates a distribution package for manual installation
# =============================================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get version (from git tag or default)
VERSION="${1:-dev}"
if [ "$VERSION" = "dev" ]; then
    VERSION="dev-$(date +%Y%m%d-%H%M%S)"
fi

PACKAGE_NAME="alesqui-intelligence-${VERSION}.tar.gz"
DIST_DIR="dist"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Alesqui Intelligence Packager${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Version: $VERSION"
echo "Package: $PACKAGE_NAME"
echo ""

# Create dist directory
mkdir -p "$DIST_DIR"

echo -e "${YELLOW}Packaging distribution...${NC}"

# Create tarball
tar -czf "$DIST_DIR/$PACKAGE_NAME" \
    --exclude='.git' \
    --exclude='.github' \
    --exclude='dist' \
    --exclude='*.log' \
    --exclude='.DS_Store' \
    --exclude='node_modules' \
    --exclude='.env' \
    --transform 's,^,alesqui-intelligence/,' \
    atlas/ \
    local/ \
    scripts/ \
    manage.sh \
    install.sh \
    README.md \
    INSTALLATION.md \
    CONFIGURATION.md

# Create latest symlink
if [ "$VERSION" != "${VERSION#dev-}" ]; then
    echo "Development build - not creating 'latest' package"
else
    cp "$DIST_DIR/$PACKAGE_NAME" "$DIST_DIR/alesqui-intelligence.tar.gz"
fi

# Generate checksums
cd "$DIST_DIR"
sha256sum *.tar.gz > checksums.txt
cd ..

echo ""
echo -e "${GREEN}✅ Package created successfully!${NC}"
echo ""
echo "Location: $DIST_DIR/$PACKAGE_NAME"
echo "Size: $(du -h "$DIST_DIR/$PACKAGE_NAME" | cut -f1)"
echo ""
echo "Contents:"
tar -tzf "$DIST_DIR/$PACKAGE_NAME" | head -20
echo "..."
echo ""
echo "Checksum:"
cat "$DIST_DIR/checksums.txt"
echo ""
echo -e "${BLUE}To test the package:${NC}"
echo "  mkdir -p /tmp/test-install"
echo "  tar -xzf $DIST_DIR/$PACKAGE_NAME -C /tmp/test-install"
echo "  cd /tmp/test-install/alesqui-intelligence"
echo "  ./install.sh"
