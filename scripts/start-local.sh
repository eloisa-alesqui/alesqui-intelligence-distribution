#!/bin/bash

# =============================================================================
# Alesqui Intelligence - Local Deployment Startup Script
# =============================================================================
# This script starts the local deployment with MongoDB container
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

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Alesqui Intelligence - Local Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Detect Docker Compose command (v1 or v2)
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    echo "Please install Docker Compose first: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}✅ Docker and Docker Compose are installed${NC}"
echo ""

# Navigate to local directory
cd "$LOCAL_DIR"

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ .env file not found in local/ directory${NC}"
    echo ""
    echo "Please create the .env file:"
    echo "  1. cd local/"
    echo "  2. cp .env.example .env"
    echo "  3. Edit .env with your configuration"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ Configuration file found${NC}"
echo ""

# Check critical environment variables
echo -e "${BLUE}🔍 Checking configuration...${NC}"

# Load .env file with Windows-compatible method
# Export all variables from .env, handling Windows CRLF line endings
set -a
while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$line" ]] && continue
    
    # Split on first '=' only to preserve '=' in values (e.g., connection strings)
    key="${line%%=*}"
    value="${line#*=}"
    
    # Trim whitespace from key
    key=$(echo "$key" | xargs)
    
    # Skip if no key
    [[ -z "$key" ]] && continue
    
    # Validate key format (alphanumeric and underscores only) to prevent command injection
    if [[ ! "$key" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "Warning: Skipping invalid variable name: $key" >&2
        continue
    fi
    
    # Trim whitespace and remove surrounding quotes from value
    value=$(echo "$value" | xargs)
    # Remove quotes (both single and double)
    if [[ "$value" =~ ^\"(.*)\"$ ]] || [[ "$value" =~ ^\'(.*)\'$ ]]; then
        value="${BASH_REMATCH[1]}"
    fi
    
    # Export the variable
    export "$key=$value"
done < <(sed 's/\r$//' .env)  # Remove Windows CRLF
set +a

# Validate required variables for Local deployment
MISSING_VARS=()

if [ -z "${MONGODB_PASSWORD:-}" ] || [ "$MONGODB_PASSWORD" == "CHANGE_THIS_TO_A_SECURE_PASSWORD" ]; then
    MISSING_VARS+=("MONGODB_PASSWORD")
fi

if [ -z "${JWT_SECRET:-}" ] || [ "$JWT_SECRET" == "CHANGE_THIS_TO_A_RANDOM_SECURE_KEY_AT_LEAST_32_CHARS" ]; then
    MISSING_VARS+=("JWT_SECRET")
fi

if [ -z "${OPENAI_API_KEY:-}" ] || [ "$OPENAI_API_KEY" == "sk-proj-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" ]; then
    MISSING_VARS+=("OPENAI_API_KEY")
fi

if [ -z "${SMTP_HOST:-}" ]; then
    MISSING_VARS+=("SMTP_HOST")
fi

if [ -z "${SMTP_USER:-}" ]; then
    MISSING_VARS+=("SMTP_USER")
fi

if [ -z "${SMTP_PASSWORD:-}" ]; then
    MISSING_VARS+=("SMTP_PASSWORD")
fi

if [ -z "${ADMIN_EMAIL:-}" ]; then
    MISSING_VARS+=("ADMIN_EMAIL")
fi

# Check if any variables are missing
if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo -e "${RED}❌ Missing or invalid configuration:${NC}"
    echo ""
    for var in "${MISSING_VARS[@]}"; do
        echo "  - $var"
    done
    echo ""
    echo "Please update your .env file with valid values."
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ All required configuration variables are set${NC}"
echo ""

# Pull latest Docker images
echo -e "${BLUE}📥 Pulling latest Docker images...${NC}"
if $DOCKER_COMPOSE pull; then
    echo -e "${GREEN}✅ Docker images updated${NC}"
else
    echo -e "${YELLOW}⚠️  Warning: Could not pull some images. Continuing with local images.${NC}"
fi
echo ""

# Start services
echo -e "${BLUE}🚀 Starting services...${NC}"
echo ""

if $DOCKER_COMPOSE up -d; then
    echo ""
    echo -e "${GREEN}✅ Services started successfully${NC}"
else
    echo ""
    echo -e "${RED}❌ Failed to start services${NC}"
    echo ""
    echo "Check logs with: cd local && $DOCKER_COMPOSE logs"
    exit 1
fi

echo ""
echo -e "${BLUE}⏳ Waiting for services to become healthy...${NC}"
echo ""

# Wait for services to be healthy (max 3 minutes)
MAX_WAIT=180
ELAPSED=0
INTERVAL=5

while [ $ELAPSED -lt $MAX_WAIT ]; do
    # Check MongoDB health
    MONGODB_HEALTHY=$(docker inspect alesqui-mongodb --format='{{.State.Health.Status}}' 2>/dev/null || echo "starting")
    
    # Check Backend health
    BACKEND_HEALTHY=$(docker inspect alesqui-backend --format='{{.State.Health.Status}}' 2>/dev/null || echo "starting")
    
    # Check Frontend status (no health check in compose, just check if running)
    FRONTEND_RUNNING=$(docker inspect alesqui-frontend --format='{{.State.Status}}' 2>/dev/null || echo "created")
    
    echo -e "  MongoDB: ${MONGODB_HEALTHY} | Backend: ${BACKEND_HEALTHY} | Frontend: ${FRONTEND_RUNNING}"
    
    # Check if all are healthy/running
    if [ "$MONGODB_HEALTHY" == "healthy" ] && [ "$BACKEND_HEALTHY" == "healthy" ] && [ "$FRONTEND_RUNNING" == "running" ]; then
        echo ""
        echo -e "${GREEN}✅ All services are healthy!${NC}"
        break
    fi
    
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Warning: Services did not become healthy within $MAX_WAIT seconds${NC}"
    echo "This is normal on first startup as images need to be downloaded."
    echo "Check status with: cd local && docker-compose ps"
    echo "Check logs with: cd local && docker-compose logs -f"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}🎉 Alesqui Intelligence is running!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Access the application:"
echo -e "  ${GREEN}Frontend:${NC}     http://localhost"
echo -e "  ${GREEN}Backend API:${NC}  http://localhost:8080"
echo -e "  ${GREEN}Health Check:${NC} http://localhost:8080/actuator/health"
echo -e "  ${GREEN}MongoDB:${NC}      localhost:27017"
echo ""
echo "Manage services:"
echo "  View logs:       cd local && $DOCKER_COMPOSE logs -f"
echo "  Stop services:   cd local && $DOCKER_COMPOSE down"
echo "  Restart service: cd local && $DOCKER_COMPOSE restart <service>"
echo ""
echo "Or use utility scripts from the root directory:"
echo "  ./scripts/stop.sh    - Stop all services"
echo "  ./scripts/update.sh  - Update to latest version"
echo ""
