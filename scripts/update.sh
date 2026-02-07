#!/bin/bash

# =============================================================================
# Alesqui Intelligence - Update Services Script
# =============================================================================
# This script updates Docker images and restarts services
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
echo -e "${BLUE}Alesqui Intelligence - Update Services${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Detect Docker Compose command (v1 or v2)
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    exit 1
fi

# Detect which deployment is running
LOCAL_RUNNING=false
ATLAS_RUNNING=false
DEPLOYMENT_DIR=""

# Check for running containers
if docker ps --format '{{.Names}}' | grep -q "alesqui-"; then
    echo -e "${BLUE}🔍 Detecting running deployment...${NC}"
    
    # Check if MongoDB container exists (local deployment)
    if docker ps --format '{{.Names}}' | grep -q "alesqui-mongodb"; then
        LOCAL_RUNNING=true
        DEPLOYMENT_DIR="$LOCAL_DIR"
        echo -e "${GREEN}✓${NC} Local deployment detected"
    else
        ATLAS_RUNNING=true
        DEPLOYMENT_DIR="$ATLAS_DIR"
        echo -e "${GREEN}✓${NC} Atlas deployment detected"
    fi
    echo ""
else
    echo -e "${YELLOW}⚠️  No Alesqui Intelligence services are currently running${NC}"
    echo ""
    echo "Please start services first:"
    echo "  ./scripts/start-local.sh   (for local deployment)"
    echo "  ./scripts/start-atlas.sh   (for Atlas deployment)"
    echo ""
    exit 1
fi

# Navigate to deployment directory
cd "$DEPLOYMENT_DIR"

# Show current versions
echo -e "${BLUE}📊 Current service status:${NC}"
$DOCKER_COMPOSE ps
echo ""

# Confirm update
echo -e "${YELLOW}This will:${NC}"
echo "  1. Pull the latest Docker images"
echo "  2. Stop and recreate containers with new images"
echo "  3. Verify services are healthy after update"
echo ""
read -p "Continue with update? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Update cancelled."
    exit 0
fi

echo ""
echo -e "${BLUE}📥 Pulling latest Docker images...${NC}"
echo ""

if $DOCKER_COMPOSE pull; then
    echo ""
    echo -e "${GREEN}✅ Images updated successfully${NC}"
else
    echo ""
    echo -e "${RED}❌ Failed to pull some images${NC}"
    echo "Check your internet connection and image registry access."
    exit 1
fi

echo ""
echo -e "${BLUE}🔄 Restarting services with new images...${NC}"
echo ""

if $DOCKER_COMPOSE up -d; then
    echo ""
    echo -e "${GREEN}✅ Services restarted${NC}"
else
    echo ""
    echo -e "${RED}❌ Failed to restart services${NC}"
    echo ""
    echo "Try to recover with:"
    echo "  cd $(basename $DEPLOYMENT_DIR) && $DOCKER_COMPOSE down"
    echo "  cd $(basename $DEPLOYMENT_DIR) && $DOCKER_COMPOSE up -d"
    exit 1
fi

echo ""
echo -e "${BLUE}⏳ Waiting for services to become healthy...${NC}"
echo ""

# Wait for services to be healthy (max 2 minutes)
MAX_WAIT=120
ELAPSED=0
INTERVAL=5

while [ $ELAPSED -lt $MAX_WAIT ]; do
    ALL_HEALTHY=true
    STATUS_LINE=""
    
    # Check MongoDB health (local only)
    if [ "$LOCAL_RUNNING" = true ]; then
        MONGODB_HEALTHY=$(docker inspect alesqui-mongodb --format='{{.State.Health.Status}}' 2>/dev/null || echo "starting")
        STATUS_LINE="${STATUS_LINE}MongoDB: ${MONGODB_HEALTHY} | "
        
        if [ "$MONGODB_HEALTHY" != "healthy" ]; then
            ALL_HEALTHY=false
        fi
    fi
    
    # Check Backend health
    BACKEND_HEALTHY=$(docker inspect alesqui-backend --format='{{.State.Health.Status}}' 2>/dev/null || echo "starting")
    STATUS_LINE="${STATUS_LINE}Backend: ${BACKEND_HEALTHY} | "
    
    if [ "$BACKEND_HEALTHY" != "healthy" ]; then
        ALL_HEALTHY=false
    fi
    
    # Check Frontend status
    FRONTEND_RUNNING=$(docker inspect alesqui-frontend --format='{{.State.Status}}' 2>/dev/null || echo "created")
    STATUS_LINE="${STATUS_LINE}Frontend: ${FRONTEND_RUNNING}"
    
    if [ "$FRONTEND_RUNNING" != "running" ]; then
        ALL_HEALTHY=false
    fi
    
    echo -e "  ${STATUS_LINE}"
    
    # Check if all are healthy
    if [ "$ALL_HEALTHY" = true ]; then
        echo ""
        echo -e "${GREEN}✅ All services are healthy!${NC}"
        break
    fi
    
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Warning: Some services are not healthy yet${NC}"
    echo ""
    echo "Check status: $DOCKER_COMPOSE ps"
    echo "Check logs: $DOCKER_COMPOSE logs -f"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Update completed!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Show updated service status
echo -e "${BLUE}📊 Updated service status:${NC}"
$DOCKER_COMPOSE ps
echo ""

echo "Services are running:"
echo -e "  ${GREEN}Frontend:${NC}     http://localhost"
echo -e "  ${GREEN}Backend API:${NC}  http://localhost:8080"
echo -e "  ${GREEN}Health Check:${NC} http://localhost:8080/actuator/health"
echo ""
echo "View logs: $DOCKER_COMPOSE logs -f"
echo ""
