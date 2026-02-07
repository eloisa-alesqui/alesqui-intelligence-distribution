#!/bin/bash

# =============================================================================
# Alesqui Intelligence - Stop Services Script
# =============================================================================
# This script stops all running Alesqui Intelligence services
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
LOCAL_DIR="$ROOT_DIR/local"
ATLAS_DIR="$ROOT_DIR/atlas"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Alesqui Intelligence - Stop Services${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    exit 1
fi

# Detect which deployment is running
LOCAL_RUNNING=false
ATLAS_RUNNING=false

# Check for running containers
if docker ps --format '{{.Names}}' | grep -q "alesqui-"; then
    echo -e "${BLUE}🔍 Detecting running deployment...${NC}"
    echo ""
    
    # Check if MongoDB container exists (local deployment)
    if docker ps --format '{{.Names}}' | grep -q "alesqui-mongodb"; then
        LOCAL_RUNNING=true
        echo -e "${GREEN}✓${NC} Local deployment detected (with MongoDB container)"
    else
        ATLAS_RUNNING=true
        echo -e "${GREEN}✓${NC} Atlas deployment detected (no MongoDB container)"
    fi
    echo ""
else
    echo -e "${YELLOW}⚠️  No Alesqui Intelligence services are currently running${NC}"
    echo ""
    exit 0
fi

# Stop local deployment
if [ "$LOCAL_RUNNING" = true ]; then
    echo -e "${BLUE}🛑 Stopping local deployment...${NC}"
    cd "$LOCAL_DIR"
    
    if docker-compose down; then
        echo -e "${GREEN}✅ Local deployment stopped successfully${NC}"
    else
        echo -e "${RED}❌ Failed to stop local deployment${NC}"
        exit 1
    fi
fi

# Stop atlas deployment
if [ "$ATLAS_RUNNING" = true ]; then
    echo -e "${BLUE}🛑 Stopping Atlas deployment...${NC}"
    cd "$ATLAS_DIR"
    
    if docker-compose down; then
        echo -e "${GREEN}✅ Atlas deployment stopped successfully${NC}"
    else
        echo -e "${RED}❌ Failed to stop Atlas deployment${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ All services stopped${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Your data is preserved in Docker volumes."
echo ""
echo "To start services again:"
if [ "$LOCAL_RUNNING" = true ]; then
    echo "  ./scripts/start-local.sh"
elif [ "$ATLAS_RUNNING" = true ]; then
    echo "  ./scripts/start-atlas.sh"
fi
echo ""
echo "To remove all data (⚠️  destructive):"
if [ "$LOCAL_RUNNING" = true ]; then
    echo "  cd local && docker-compose down -v"
elif [ "$ATLAS_RUNNING" = true ]; then
    echo "  Note: Atlas deployment doesn't use local volumes"
fi
echo ""
