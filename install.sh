#!/bin/bash

# =============================================================================
# Alesqui Intelligence - Professional Installation Script
# =============================================================================
# This script provides an automated, interactive installation experience for
# Alesqui Intelligence with support for both Atlas and Local deployments.
# =============================================================================

set -e  # Exit on error
set -u  # Exit on undefined variable

# =============================================================================
# CONFIGURATION
# =============================================================================

INSTALL_LOG="/tmp/alesqui-install.log"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# =============================================================================
# LOGGING
# =============================================================================

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" >> "$INSTALL_LOG"
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: $*" >> "$INSTALL_LOG"
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${CYAN}${BOLD}   Alesqui Intelligence Installer${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}▶ $1${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# =============================================================================
# SIGNAL HANDLING
# =============================================================================

cleanup() {
    echo ""
    print_warning "Installation interrupted. Cleaning up..."
    log "Installation interrupted by user"
    exit 130
}

trap cleanup SIGINT SIGTERM

# =============================================================================
# DEPENDENCY CHECKS
# =============================================================================

check_os() {
    print_section "Detecting Operating System"
    
    OS="$(uname -s)"
    case "$OS" in
        Linux*)     OS="Linux";;
        Darwin*)    OS="macOS";;
        *)          
            print_error "Unsupported operating system: $OS"
            log_error "Unsupported OS: $OS"
            echo ""
            echo "This installer supports:"
            echo "  - Linux (Ubuntu, Debian, CentOS, RHEL, etc.)"
            echo "  - macOS"
            echo ""
            exit 1
            ;;
    esac
    
    print_success "Detected: $OS"
    log "OS detected: $OS"
}

check_docker() {
    print_section "Checking Docker Installation"
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        log_error "Docker not found"
        echo ""
        echo "Docker is required to run Alesqui Intelligence."
        echo ""
        echo "Installation instructions:"
        echo ""
        if [ "$OS" = "Linux" ]; then
            echo "  # Quick install (official script)"
            echo "  curl -fsSL https://get.docker.com -o get-docker.sh"
            echo "  sudo sh get-docker.sh"
            echo "  sudo usermod -aG docker \$USER"
            echo "  newgrp docker"
        elif [ "$OS" = "macOS" ]; then
            echo "  # Install Docker Desktop for Mac"
            echo "  https://docs.docker.com/desktop/install/mac-install/"
        fi
        echo ""
        exit 1
    fi
    
    # Check Docker version
    DOCKER_VERSION=$(docker --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
    DOCKER_MAJOR=$(echo "$DOCKER_VERSION" | cut -d. -f1)
    DOCKER_MINOR=$(echo "$DOCKER_VERSION" | cut -d. -f2)
    
    if [ "$DOCKER_MAJOR" -lt 20 ] || ([ "$DOCKER_MAJOR" -eq 20 ] && [ "$DOCKER_MINOR" -lt 10 ]); then
        print_warning "Docker version $DOCKER_VERSION is older than recommended (20.10+)"
        log "Docker version $DOCKER_VERSION (warning: old version)"
    else
        print_success "Docker $DOCKER_VERSION is installed"
        log "Docker version: $DOCKER_VERSION"
    fi
}

check_docker_compose() {
    print_section "Checking Docker Compose Installation"
    
    # Try docker compose (v2)
    if docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
        COMPOSE_VERSION=$(docker compose version --short 2>/dev/null || docker compose version | grep -oE 'v?[0-9]+\.[0-9]+\.[0-9]+' | head -1 | sed 's/v//')
    # Try docker-compose (v1)
    elif command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
        COMPOSE_VERSION=$(docker-compose --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    else
        print_error "Docker Compose is not installed"
        log_error "Docker Compose not found"
        echo ""
        echo "Docker Compose is required to run Alesqui Intelligence."
        echo ""
        echo "Installation instructions:"
        echo ""
        if [ "$OS" = "Linux" ]; then
            echo "  # Install Docker Compose v2"
            echo "  sudo curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)\" -o /usr/local/bin/docker-compose"
            echo "  sudo chmod +x /usr/local/bin/docker-compose"
        elif [ "$OS" = "macOS" ]; then
            echo "  # Docker Desktop for Mac includes Docker Compose"
            echo "  # Make sure Docker Desktop is running"
        fi
        echo ""
        exit 1
    fi
    
    print_success "Docker Compose $COMPOSE_VERSION is installed"
    log "Docker Compose version: $COMPOSE_VERSION (command: $COMPOSE_CMD)"
}

check_utilities() {
    print_section "Checking Required Utilities"
    
    # Check for curl or wget
    if command -v curl &> /dev/null; then
        print_success "curl is available"
        log "curl is available"
    elif command -v wget &> /dev/null; then
        print_success "wget is available"
        log "wget is available"
    else
        print_warning "Neither curl nor wget found (not critical)"
        log "Neither curl nor wget found"
    fi
    
    # Check for openssl
    if command -v openssl &> /dev/null; then
        print_success "openssl is available (for generating secrets)"
        log "openssl is available"
    else
        print_warning "openssl not found - will use fallback for secret generation"
        log "openssl not found"
    fi
}

check_dependencies() {
    print_header
    echo "Welcome! This installer will help you deploy Alesqui Intelligence."
    echo ""
    
    log "=== Installation started ==="
    log "Installation log: $INSTALL_LOG"
    
    check_os
    check_docker
    check_docker_compose
    check_utilities
}

# =============================================================================
# DEPLOYMENT TYPE SELECTION
# =============================================================================

choose_deployment() {
    print_section "Choose Deployment Type"
    
    echo "Select your preferred deployment option:"
    echo ""
    echo -e "${GREEN}  [1] Atlas Deployment${NC}"
    echo "      • Recommended for Production"
    echo "      • Cloud-managed MongoDB Atlas"
    echo "      • Automatic backups and scaling"
    echo "      • Minimal server resources required"
    echo ""
    echo -e "${CYAN}  [2] Local Deployment${NC}"
    echo "      • Recommended for Development & Testing"
    echo "      • Self-hosted MongoDB in Docker"
    echo "      • Complete control over data"
    echo "      • No external dependencies"
    echo ""
    
    while true; do
        read -p "Enter your choice [1-2]: " choice
        case $choice in
            1)
                DEPLOYMENT_TYPE="atlas"
                DEPLOYMENT_NAME="Atlas"
                DEPLOYMENT_DIR="$REPO_DIR/atlas"
                print_success "Selected: Atlas Deployment"
                log "Deployment type: Atlas"
                break
                ;;
            2)
                DEPLOYMENT_TYPE="local"
                DEPLOYMENT_NAME="Local"
                DEPLOYMENT_DIR="$REPO_DIR/local"
                print_success "Selected: Local Deployment"
                log "Deployment type: Local"
                break
                ;;
            *)
                print_error "Invalid choice. Please enter 1 or 2."
                ;;
        esac
    done
}

# =============================================================================
# SECRET GENERATION
# =============================================================================

# Helper function for sed that works on both Linux and macOS
sed_inplace() {
    local pattern="$1"
    local file="$2"
    
    if [ "$OS" = "macOS" ]; then
        sed -i '' "$pattern" "$file"
    else
        sed -i "$pattern" "$file"
    fi
}

generate_jwt_secret() {
    if command -v openssl &> /dev/null; then
        openssl rand -base64 32 | tr -d '\n'
    else
        # Fallback: use /dev/urandom
        head -c 32 /dev/urandom | base64 | tr -d '\n'
    fi
}

generate_password() {
    local length=${1:-24}
    if command -v openssl &> /dev/null; then
        openssl rand -base64 $length | tr -d "=+/" | cut -c1-$length
    else
        # Fallback: use /dev/urandom
        head -c $length /dev/urandom | base64 | tr -d "=+/\n" | cut -c1-$length
    fi
}

# =============================================================================
# ENVIRONMENT CONFIGURATION
# =============================================================================

configure_env_atlas() {
    print_section "Configuring Atlas Deployment"
    
    ENV_FILE="$DEPLOYMENT_DIR/.env"
    
    # Check if .env already exists
    if [ -f "$ENV_FILE" ]; then
        print_warning ".env file already exists"
        read -p "Do you want to overwrite it? [y/N]: " overwrite
        if [[ ! $overwrite =~ ^[Yy]$ ]]; then
            print_info "Using existing .env file"
            log "Using existing .env file"
            return
        fi
    fi
    
    # Copy from example
    if [ ! -f "$DEPLOYMENT_DIR/.env.example" ]; then
        print_error ".env.example not found in $DEPLOYMENT_DIR"
        log_error ".env.example not found"
        exit 1
    fi
    
    cp "$DEPLOYMENT_DIR/.env.example" "$ENV_FILE"
    print_success ".env file created"
    
    echo ""
    echo "Let's configure your deployment. Press Enter to skip optional fields."
    echo ""
    
    # Company Name
    read -p "Company Name [My Company Inc.]: " company_name
    company_name=${company_name:-"My Company Inc."}
    sed_inplace "s/^COMPANY_NAME=.*/COMPANY_NAME=\"$company_name\"/" "$ENV_FILE"
    
    # MongoDB Atlas URI
    echo ""
    echo -e "${BOLD}MongoDB Atlas Configuration:${NC}"
    echo "If you haven't created an Atlas cluster yet:"
    echo "  1. Go to https://cloud.mongodb.com"
    echo "  2. Create a free cluster (M0)"
    echo "  3. Create a database user"
    echo "  4. Whitelist your IP (0.0.0.0/0 for testing)"
    echo "  5. Get your connection string"
    echo ""
    read -p "MongoDB Atlas URI: " mongodb_uri
    while [ -z "$mongodb_uri" ] || [[ "$mongodb_uri" == *"username:password"* ]] || [[ "$mongodb_uri" == *"cluster0.xxxxx"* ]]; do
        print_error "Invalid MongoDB URI. Please provide a real Atlas connection string."
        read -p "MongoDB Atlas URI: " mongodb_uri
    done
    sed_inplace "s|^MONGODB_ATLAS_URI=.*|MONGODB_ATLAS_URI=$mongodb_uri|" "$ENV_FILE"
    print_success "MongoDB Atlas URI configured"
    
    # JWT Secret
    echo ""
    echo -e "${BOLD}JWT Secret Generation:${NC}"
    read -p "Generate JWT_SECRET automatically? [Y/n]: " gen_jwt
    if [[ ! $gen_jwt =~ ^[Nn]$ ]]; then
        jwt_secret=$(generate_jwt_secret)
        sed_inplace "s|^JWT_SECRET=.*|JWT_SECRET=$jwt_secret|" "$ENV_FILE"
        print_success "JWT_SECRET generated automatically"
    else
        read -p "Enter JWT_SECRET (min 32 chars): " jwt_secret
        while [ ${#jwt_secret} -lt 32 ]; do
            print_error "JWT_SECRET must be at least 32 characters"
            read -p "Enter JWT_SECRET (min 32 chars): " jwt_secret
        done
        sed_inplace "s|^JWT_SECRET=.*|JWT_SECRET=$jwt_secret|" "$ENV_FILE"
        print_success "JWT_SECRET configured"
    fi
    
    # OpenAI API Key
    echo ""
    echo -e "${BOLD}OpenAI Configuration:${NC}"
    echo "Get your API key from: https://platform.openai.com/api-keys"
    read -p "OpenAI API Key: " openai_key
    while [ -z "$openai_key" ] || [[ "$openai_key" == "sk-proj-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" ]]; do
        print_error "Invalid OpenAI API Key"
        read -p "OpenAI API Key: " openai_key
    done
    sed_inplace "s|^OPENAI_API_KEY=.*|OPENAI_API_KEY=$openai_key|" "$ENV_FILE"
    print_success "OpenAI API Key configured"
    
    # Frontend URL
    echo ""
    read -p "Frontend URL [https://intelligence.yourcompany.com]: " frontend_url
    frontend_url=${frontend_url:-"https://intelligence.yourcompany.com"}
    sed_inplace "s|^FRONTEND_URL=.*|FRONTEND_URL=$frontend_url|" "$ENV_FILE"
    
    # API URL
    read -p "API URL [https://intelligence.yourcompany.com/api]: " api_url
    api_url=${api_url:-"https://intelligence.yourcompany.com/api"}
    sed_inplace "s|^VITE_API_URL=.*|VITE_API_URL=$api_url|" "$ENV_FILE"
    
    # Admin Email
    echo ""
    echo -e "${BOLD}Initial Admin User (Optional):${NC}"
    read -p "Admin Email [admin@company.com]: " admin_email
    if [ -n "$admin_email" ] && [ "$admin_email" != "admin@company.com" ]; then
        echo "INITIAL_ADMIN_EMAIL=$admin_email" >> "$ENV_FILE"
    fi
    
    # SMTP Configuration (optional)
    echo ""
    echo -e "${BOLD}SMTP Configuration (Optional - press Enter to skip):${NC}"
    read -p "SMTP Host [skip]: " smtp_host
    if [ -n "$smtp_host" ] && [ "$smtp_host" != "skip" ]; then
        sed_inplace "s|^SMTP_HOST=.*|SMTP_HOST=$smtp_host|" "$ENV_FILE"
        
        read -p "SMTP Port [587]: " smtp_port
        smtp_port=${smtp_port:-587}
        sed_inplace "s|^SMTP_PORT=.*|SMTP_PORT=$smtp_port|" "$ENV_FILE"
        
        read -p "SMTP User: " smtp_user
        sed_inplace "s|^SMTP_USER=.*|SMTP_USER=$smtp_user|" "$ENV_FILE"
        
        read -s -p "SMTP Password: " smtp_password
        echo ""
        sed_inplace "s|^SMTP_PASSWORD=.*|SMTP_PASSWORD=$smtp_password|" "$ENV_FILE"
        
        read -p "From Email: " from_email
        sed_inplace "s|^MAIL_FROM_EMAIL=.*|MAIL_FROM_EMAIL=$from_email|" "$ENV_FILE"
        
        print_success "SMTP configured"
    else
        print_info "SMTP configuration skipped"
    fi
    
    print_success "Environment configuration completed"
    log "Environment configured for Atlas deployment"
}

configure_env_local() {
    print_section "Configuring Local Deployment"
    
    ENV_FILE="$DEPLOYMENT_DIR/.env"
    
    # Check if .env already exists
    if [ -f "$ENV_FILE" ]; then
        print_warning ".env file already exists"
        read -p "Do you want to overwrite it? [y/N]: " overwrite
        if [[ ! $overwrite =~ ^[Yy]$ ]]; then
            print_info "Using existing .env file"
            log "Using existing .env file"
            return
        fi
    fi
    
    # Copy from example
    if [ ! -f "$DEPLOYMENT_DIR/.env.example" ]; then
        print_error ".env.example not found in $DEPLOYMENT_DIR"
        log_error ".env.example not found"
        exit 1
    fi
    
    cp "$DEPLOYMENT_DIR/.env.example" "$ENV_FILE"
    print_success ".env file created"
    
    echo ""
    echo "Let's configure your deployment. Press Enter to skip optional fields."
    echo ""
    
    # Company Name
    read -p "Company Name [My Company Inc.]: " company_name
    company_name=${company_name:-"My Company Inc."}
    sed_inplace "s/^COMPANY_NAME=.*/COMPANY_NAME=\"$company_name\"/" "$ENV_FILE"
    
    # MongoDB Password
    echo ""
    echo -e "${BOLD}MongoDB Configuration:${NC}"
    read -p "Generate MongoDB password automatically? [Y/n]: " gen_mongo
    if [[ ! $gen_mongo =~ ^[Nn]$ ]]; then
        mongo_password=$(generate_password 24)
        sed_inplace "s|^MONGODB_PASSWORD=.*|MONGODB_PASSWORD=$mongo_password|" "$ENV_FILE"
        print_success "MongoDB password generated automatically"
    else
        read -s -p "Enter MongoDB password: " mongo_password
        echo ""
        while [ ${#mongo_password} -lt 12 ]; do
            print_error "Password must be at least 12 characters"
            read -s -p "Enter MongoDB password: " mongo_password
            echo ""
        done
        sed_inplace "s|^MONGODB_PASSWORD=.*|MONGODB_PASSWORD=$mongo_password|" "$ENV_FILE"
        print_success "MongoDB password configured"
    fi
    
    # JWT Secret
    echo ""
    echo -e "${BOLD}JWT Secret Generation:${NC}"
    read -p "Generate JWT_SECRET automatically? [Y/n]: " gen_jwt
    if [[ ! $gen_jwt =~ ^[Nn]$ ]]; then
        jwt_secret=$(generate_jwt_secret)
        sed_inplace "s|^JWT_SECRET=.*|JWT_SECRET=$jwt_secret|" "$ENV_FILE"
        print_success "JWT_SECRET generated automatically"
    else
        read -p "Enter JWT_SECRET (min 32 chars): " jwt_secret
        while [ ${#jwt_secret} -lt 32 ]; do
            print_error "JWT_SECRET must be at least 32 characters"
            read -p "Enter JWT_SECRET (min 32 chars): " jwt_secret
        done
        sed_inplace "s|^JWT_SECRET=.*|JWT_SECRET=$jwt_secret|" "$ENV_FILE"
        print_success "JWT_SECRET configured"
    fi
    
    # OpenAI API Key
    echo ""
    echo -e "${BOLD}OpenAI Configuration:${NC}"
    echo "Get your API key from: https://platform.openai.com/api-keys"
    read -p "OpenAI API Key: " openai_key
    while [ -z "$openai_key" ] || [[ "$openai_key" == "sk-proj-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" ]]; do
        print_error "Invalid OpenAI API Key"
        read -p "OpenAI API Key: " openai_key
    done
    sed_inplace "s|^OPENAI_API_KEY=.*|OPENAI_API_KEY=$openai_key|" "$ENV_FILE"
    print_success "OpenAI API Key configured"
    
    # Frontend URL
    echo ""
    read -p "Frontend URL [http://localhost]: " frontend_url
    frontend_url=${frontend_url:-"http://localhost"}
    sed_inplace "s|^FRONTEND_URL=.*|FRONTEND_URL=$frontend_url|" "$ENV_FILE"
    
    # Admin Email
    echo ""
    echo -e "${BOLD}Initial Admin User (Optional):${NC}"
    read -p "Admin Email [admin@company.com]: " admin_email
    if [ -n "$admin_email" ] && [ "$admin_email" != "admin@company.com" ]; then
        echo "INITIAL_ADMIN_EMAIL=$admin_email" >> "$ENV_FILE"
    fi
    
    # SMTP Configuration (optional)
    echo ""
    echo -e "${BOLD}SMTP Configuration (Optional - press Enter to skip):${NC}"
    read -p "SMTP Host [skip]: " smtp_host
    if [ -n "$smtp_host" ] && [ "$smtp_host" != "skip" ]; then
        sed_inplace "s|^SMTP_HOST=.*|SMTP_HOST=$smtp_host|" "$ENV_FILE"
        
        read -p "SMTP Port [587]: " smtp_port
        smtp_port=${smtp_port:-587}
        sed_inplace "s|^SMTP_PORT=.*|SMTP_PORT=$smtp_port|" "$ENV_FILE"
        
        read -p "SMTP User: " smtp_user
        sed_inplace "s|^SMTP_USER=.*|SMTP_USER=$smtp_user|" "$ENV_FILE"
        
        read -s -p "SMTP Password: " smtp_password
        echo ""
        sed_inplace "s|^SMTP_PASSWORD=.*|SMTP_PASSWORD=$smtp_password|" "$ENV_FILE"
        
        read -p "From Email: " from_email
        sed_inplace "s|^MAIL_FROM_EMAIL=.*|MAIL_FROM_EMAIL=$from_email|" "$ENV_FILE"
        
        print_success "SMTP configured"
    else
        print_info "SMTP configuration skipped"
    fi
    
    print_success "Environment configuration completed"
    log "Environment configured for Local deployment"
}

# =============================================================================
# INSTALLATION
# =============================================================================

install_services() {
    print_section "Starting Installation"
    
    cd "$DEPLOYMENT_DIR"
    
    # Pull Docker images
    echo ""
    print_info "Pulling Docker images (this may take a few minutes)..."
    log "Pulling Docker images"
    
    if $COMPOSE_CMD pull 2>&1 | tee -a "$INSTALL_LOG"; then
        print_success "Docker images pulled successfully"
    else
        print_warning "Some images could not be pulled. Continuing with available images."
        log "Warning: Image pull had issues"
    fi
    
    # Start services
    echo ""
    print_info "Starting services..."
    log "Starting Docker services"
    
    if $COMPOSE_CMD up -d 2>&1 | tee -a "$INSTALL_LOG"; then
        print_success "Services started successfully"
        log "Services started"
    else
        print_error "Failed to start services"
        log_error "Failed to start services"
        echo ""
        echo "Check logs at: $INSTALL_LOG"
        echo "Or run: cd $DEPLOYMENT_DIR && $COMPOSE_CMD logs"
        exit 1
    fi
}

perform_health_checks() {
    print_section "Performing Health Checks"
    
    echo ""
    print_info "Waiting for services to become healthy..."
    print_info "This may take 2-3 minutes..."
    echo ""
    
    MAX_WAIT=180
    ELAPSED=0
    INTERVAL=5
    
    while [ $ELAPSED -lt $MAX_WAIT ]; do
        # Check backend health
        if curl -sf http://localhost:8080/actuator/health > /dev/null 2>&1; then
            print_success "Backend is healthy"
            log "Backend health check passed"
            break
        fi
        
        echo -n "."
        sleep $INTERVAL
        ELAPSED=$((ELAPSED + INTERVAL))
    done
    
    echo ""
    
    if [ $ELAPSED -ge $MAX_WAIT ]; then
        print_warning "Services did not become healthy within $MAX_WAIT seconds"
        print_info "This is normal on first startup. Check status with:"
        echo "  cd $DEPLOYMENT_DIR && $COMPOSE_CMD ps"
        echo "  cd $DEPLOYMENT_DIR && $COMPOSE_CMD logs -f"
        log "Health check timeout (not critical)"
    fi
    
    # Check frontend
    echo ""
    if curl -sf http://localhost > /dev/null 2>&1; then
        print_success "Frontend is accessible"
        log "Frontend health check passed"
    else
        print_warning "Frontend may still be starting"
        log "Frontend not yet accessible"
    fi
}

print_completion_message() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}${BOLD}✅ Installation Complete!${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    if [ "$DEPLOYMENT_TYPE" = "atlas" ]; then
        echo -e "${BOLD}Atlas Deployment${NC}"
        echo ""
        echo "Access your application:"
        echo -e "  ${GREEN}Frontend:${NC}     http://localhost"
        echo -e "  ${GREEN}Backend API:${NC}  http://localhost:8080"
        echo -e "  ${GREEN}Health Check:${NC} http://localhost:8080/actuator/health"
        echo -e "  ${GREEN}MongoDB:${NC}      Managed by Atlas"
        echo ""
        echo "MongoDB Atlas Dashboard:"
        echo "  https://cloud.mongodb.com"
    else
        echo -e "${BOLD}Local Deployment${NC}"
        echo ""
        echo "Access your application:"
        echo -e "  ${GREEN}Frontend:${NC}     http://localhost"
        echo -e "  ${GREEN}Backend API:${NC}  http://localhost:8080"
        echo -e "  ${GREEN}Health Check:${NC} http://localhost:8080/actuator/health"
        echo -e "  ${GREEN}MongoDB:${NC}      localhost:27017"
    fi
    
    echo ""
    echo -e "${BOLD}Initial Admin Credentials:${NC}"
    echo "Check the backend logs for the auto-generated password:"
    echo "  cd $DEPLOYMENT_DIR && $COMPOSE_CMD logs backend | grep InitialAdmin"
    echo ""
    echo -e "${YELLOW}⚠️  Important: Change the admin password after first login!${NC}"
    
    echo ""
    echo -e "${BOLD}Next Steps:${NC}"
    echo "  1. Access the frontend at http://localhost"
    echo "  2. Login with the admin credentials from the logs"
    echo "  3. Change your admin password"
    echo "  4. Configure additional users and settings"
    
    echo ""
    echo -e "${BOLD}Manage Services:${NC}"
    echo "  View logs:       cd $DEPLOYMENT_DIR && $COMPOSE_CMD logs -f"
    echo "  Stop services:   cd $DEPLOYMENT_DIR && $COMPOSE_CMD down"
    echo "  Restart service: cd $DEPLOYMENT_DIR && $COMPOSE_CMD restart <service>"
    
    echo ""
    echo -e "${BOLD}Documentation:${NC}"
    echo "  Installation log:    $INSTALL_LOG"
    echo "  Troubleshooting:     $REPO_DIR/TROUBLESHOOTING.md"
    if [ "$DEPLOYMENT_TYPE" = "atlas" ]; then
        echo "  Atlas Guide:         $REPO_DIR/atlas/README.md"
    else
        echo "  Local Guide:         $REPO_DIR/local/README.md"
    fi
    
    echo ""
    echo -e "${GREEN}Thank you for choosing Alesqui Intelligence!${NC}"
    echo ""
    
    log "Installation completed successfully"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    # Initialize log
    echo "=== Alesqui Intelligence Installation ===" > "$INSTALL_LOG"
    
    # Check dependencies
    check_dependencies
    
    # Choose deployment
    choose_deployment
    
    # Configure environment
    if [ "$DEPLOYMENT_TYPE" = "atlas" ]; then
        configure_env_atlas
    else
        configure_env_local
    fi
    
    # Install services
    install_services
    
    # Health checks
    perform_health_checks
    
    # Show completion message
    print_completion_message
}

# Run main function
main
