#!/bin/bash

# =============================================================================
# Alesqui Intelligence - Management Script
# =============================================================================
# Convenient commands to manage your Alesqui Intelligence installation
# =============================================================================

set -e

# Load installation info
if [ ! -f ".install-info" ]; then
    echo "❌ Error: .install-info not found. Are you in the installation directory?"
    exit 1
fi

source .install-info

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Determine deployment directory
if [ "$DEPLOYMENT_TYPE" = "atlas" ]; then
    DEPLOY_DIR="atlas"
elif [ "$DEPLOYMENT_TYPE" = "local" ]; then
    DEPLOY_DIR="local"
else
    echo "❌ Unknown deployment type: $DEPLOYMENT_TYPE"
    exit 1
fi

# Commands
cmd_start() {
    echo -e "${BLUE}Starting Alesqui Intelligence ($DEPLOYMENT_TYPE deployment)...${NC}"
    cd "$DEPLOY_DIR"
    docker compose up -d
    echo -e "${GREEN}✅ Services started${NC}"
    echo ""
    echo "Access your application at:"
    echo "  Frontend: http://localhost"
    echo "  Backend:  http://localhost:8080"
    echo "  Health:   http://localhost:8080/actuator/health"
}

cmd_stop() {
    echo -e "${BLUE}Stopping Alesqui Intelligence...${NC}"
    cd "$DEPLOY_DIR"
    docker compose down
    echo -e "${GREEN}✅ Services stopped${NC}"
}

cmd_restart() {
    echo -e "${BLUE}Restarting Alesqui Intelligence...${NC}"
    cmd_stop
    sleep 2
    cmd_start
}

cmd_logs() {
    cd "$DEPLOY_DIR"
    if [ -n "$1" ]; then
        docker compose logs -f "$1"
    else
        docker compose logs -f
    fi
}

cmd_status() {
    echo -e "${BLUE}Alesqui Intelligence Status${NC}"
    echo "========================================"
    echo "Installation directory: $INSTALL_DIR"
    echo "Deployment type: $DEPLOYMENT_TYPE"
    echo "Installed: $INSTALL_DATE"
    echo ""
    echo "Docker containers:"
    cd "$DEPLOY_DIR"
    docker compose ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    cd - > /dev/null
    echo ""
    echo "Health check:"
    if curl -sf http://localhost:8080/actuator/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Backend is healthy${NC}"
    else
        echo -e "${RED}❌ Backend is not responding${NC}"
    fi
    
    if curl -sf http://localhost > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Frontend is accessible${NC}"
    else
        echo -e "${RED}❌ Frontend is not accessible${NC}"
    fi
}

cmd_backup() {
    BACKUP_DIR="$HOME/alesqui-backups"
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="$BACKUP_DIR/alesqui-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    
    echo -e "${BLUE}Creating backup...${NC}"
    tar -czf "$BACKUP_FILE" \
        "$DEPLOY_DIR/.env" \
        ".install-info" \
        2>/dev/null || true
    
    echo -e "${GREEN}✅ Backup created: $BACKUP_FILE${NC}"
    echo ""
    echo "Backup contains:"
    echo "  - Environment configuration (.env)"
    echo "  - Installation info"
}

cmd_update() {
    echo -e "${YELLOW}⚠️  Updating Alesqui Intelligence...${NC}"
    echo ""
    
    # Backup current config
    cmd_backup
    
    # Pull latest changes from current branch
    echo "Pulling latest version..."
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    git pull origin "$CURRENT_BRANCH"
    
    # Restart services
    cmd_restart
    
    echo -e "${GREEN}✅ Update complete${NC}"
}

cmd_help() {
    echo "Alesqui Intelligence Management Script"
    echo ""
    echo "Usage: ./manage.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start      Start all services"
    echo "  stop       Stop all services"
    echo "  restart    Restart all services"
    echo "  logs       View logs (add service name for specific service)"
    echo "  status     Show installation and service status"
    echo "  backup     Create backup of configuration"
    echo "  update     Update to latest version"
    echo "  help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./manage.sh start"
    echo "  ./manage.sh logs backend"
    echo "  ./manage.sh status"
}

# Main
case "${1:-}" in
    start)
        cmd_start
        ;;
    stop)
        cmd_stop
        ;;
    restart)
        cmd_restart
        ;;
    logs)
        cmd_logs "${2:-}"
        ;;
    status)
        cmd_status
        ;;
    backup)
        cmd_backup
        ;;
    update)
        cmd_update
        ;;
    help|--help|-h)
        cmd_help
        ;;
    *)
        echo -e "${RED}Unknown command: ${1:-}${NC}"
        echo ""
        cmd_help
        exit 1
        ;;
esac
