#!/bin/bash

# =============================================================================
# Alesqui Intelligence - Atlas Deployment Startup Script
# =============================================================================
# This script starts the Atlas deployment (cloud MongoDB)
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
ATLAS_DIR="$ROOT_DIR/atlas"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Alesqui Intelligence - Atlas Deployment${NC}"
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

# Navigate to atlas directory
cd "$ATLAS_DIR"

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ .env file not found in atlas/ directory${NC}"
    echo ""
    echo "Please create the .env file:"
    echo "  1. cd atlas/"
    echo "  2. cp .env.example .env"
    echo "  3. Edit .env with your MongoDB Atlas connection string and configuration"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ Configuration file found${NC}"
echo ""

# Check critical environment variables
echo -e "${BLUE}🔍 Checking configuration...${NC}"

# Load .env file with Windows-compatible method
# Use grep and export to handle Windows line endings and parsing issues
# Export all variables from .env, handling Windows CRLF line endings
set -a
while IFS='=' read -r key value; do
    # Skip comments and empty lines
    [[ "$key" =~ ^#.*$ ]] && continue
    [[ -z "$key" ]] && continue
    
    # Remove leading/trailing whitespace and quotes
    key=$(echo "$key" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
    
    # Export the variable
    export "$key=$value"
done < <(cat .env | sed 's/\r$//')  # Remove Windows CRLF
set +a

# Validate required variables for Atlas deployment
MISSING_VARS=()

# Check MongoDB Atlas URI
if [ -z "${MONGODB_ATLAS_URI:-}" ]; then
    MISSING_VARS+=("MONGODB_ATLAS_URI (not set)")
elif [[ "$MONGODB_ATLAS_URI" == *"username:password"* ]] || [[ "$MONGODB_ATLAS_URI" == *"cluster0.xxxxx"* ]]; then
    MISSING_VARS+=("MONGODB_ATLAS_URI (not configured with real values)")
fi

# Check JWT Secret
if [ -z "${JWT_SECRET:-}" ] || [ "$JWT_SECRET" == "CHANGE_THIS_TO_A_RANDOM_SECURE_KEY_AT_LEAST_32_CHARS" ]; then
    MISSING_VARS+=("JWT_SECRET")
fi

# Check OpenAI API Key
if [ -z "${OPENAI_API_KEY:-}" ] || [ "$OPENAI_API_KEY" == "sk-proj-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" ]; then
    MISSING_VARS+=("OPENAI_API_KEY")
fi

# Check SMTP configuration
if [ -z "${SMTP_HOST:-}" ]; then
    MISSING_VARS+=("SMTP_HOST")
fi

if [ -z "${SMTP_USER:-}" ]; then
    MISSING_VARS+=("SMTP_USER")
fi

if [ -z "${SMTP_PASSWORD:-}" ]; then
    MISSING_VARS+=("SMTP_PASSWORD")
fi

# Check Admin Email
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
    
    if [[ " ${MISSING_VARS[@]} " =~ " MONGODB_ATLAS_URI " ]]; then
        echo "For MongoDB Atlas:"
        echo "  1. Create a cluster at https://cloud.mongodb.com"
        echo "  2. Create a database user"
        echo "  3. Whitelist your server IP in Network Access"
        echo "  4. Get your connection string and update MONGODB_ATLAS_URI"
        echo ""
    fi
    
    exit 1
fi

echo -e "${GREEN}✅ All required configuration variables are set${NC}"
echo ""

# Validate MongoDB Atlas URI format
if [[ ! "$MONGODB_ATLAS_URI" =~ ^mongodb\+srv:// ]]; then
    echo -e "${YELLOW}⚠️  Warning: MONGODB_ATLAS_URI should start with 'mongodb+srv://' for Atlas${NC}"
    echo "   Current value: ${MONGODB_ATLAS_URI:0:50}..."
    echo ""
    # Check if stdin is a terminal (interactive mode)
    if [ -t 0 ]; then
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        echo "Running in non-interactive mode, continuing..."
    fi
fi

echo -e "${GREEN}✅ Configuration validated${NC}"
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
    echo "Check logs with: cd atlas && $DOCKER_COMPOSE logs"
    echo ""
    echo "Common issues:"
    echo "  - MongoDB Atlas IP whitelist: Ensure your server IP is whitelisted"
    echo "  - Connection string: Verify username, password, and database name"
    echo "  - Network: Check if outbound connection to MongoDB Atlas is allowed"
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
    # Check Backend health
    BACKEND_HEALTHY=$(docker inspect alesqui-backend --format='{{.State.Health.Status}}' 2>/dev/null || echo "starting")
    
    # Check Frontend status
    FRONTEND_RUNNING=$(docker inspect alesqui-frontend --format='{{.State.Status}}' 2>/dev/null || echo "created")
    
    echo -e "  Backend: ${BACKEND_HEALTHY} | Frontend: ${FRONTEND_RUNNING}"
    
    # Check if all are healthy/running
    if [ "$BACKEND_HEALTHY" == "healthy" ] && [ "$FRONTEND_RUNNING" == "running" ]; then
        echo ""
        echo -e "${GREEN}✅ All services are healthy!${NC}"
        break
    fi
    
    # If backend is unhealthy, show hint
    if [ "$BACKEND_HEALTHY" == "unhealthy" ]; then
        echo ""
        echo -e "${RED}❌ Backend is unhealthy. Checking logs...${NC}"
        echo ""
        $DOCKER_COMPOSE logs --tail=20 backend
        echo ""
        echo -e "${YELLOW}Possible issues:${NC}"
        echo "  - MongoDB Atlas connection failed (check IP whitelist)"
        echo "  - Invalid connection string (check credentials)"
        echo "  - Network connectivity issue"
        echo ""
        exit 1
    fi
    
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Warning: Services did not become healthy within $MAX_WAIT seconds${NC}"
    echo "This is normal on first startup as images need to be downloaded."
    echo ""
    echo "Check status with: cd atlas && $DOCKER_COMPOSE ps"
    echo "Check logs with: cd atlas && $DOCKER_COMPOSE logs -f"
    echo ""
    echo "If backend keeps failing:"
    echo "  1. Verify MongoDB Atlas connection string"
    echo "  2. Check if your IP is whitelisted in Atlas Network Access"
    echo "  3. Test connection: $DOCKER_COMPOSE logs backend"
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
echo -e "  ${GREEN}MongoDB:${NC}      Managed by Atlas"
echo ""
echo "Manage services:"
echo "  View logs:       cd atlas && $DOCKER_COMPOSE logs -f"
echo "  Stop services:   cd atlas && $DOCKER_COMPOSE down"
echo "  Restart service: cd atlas && $DOCKER_COMPOSE restart <service>"
echo ""
echo "MongoDB Atlas Dashboard:"
echo "  https://cloud.mongodb.com"
echo ""
echo "Or use utility scripts from the root directory:"
echo "  ./scripts/stop.sh    - Stop all services"
echo "  ./scripts/update.sh  - Update to latest version"
echo ""
