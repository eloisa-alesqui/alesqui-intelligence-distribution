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

# Early OS detection (needed for path handling)
OS="$(uname -s)"
case "$OS" in
    Linux*)     OS="Linux";;
    Darwin*)    OS="macOS";;
    MINGW*|MSYS*|CYGWIN*)  OS="Windows";;
    *)          OS="Unknown";;
esac

# Set platform-specific temp directory for install log
if [ "$OS" = "Windows" ]; then
    INSTALL_LOG="${TEMP}/alesqui-install.log"
else
    INSTALL_LOG="/tmp/alesqui-install.log"
fi

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
    echo -e "${CYAN}     _    _                 _      ${NC}"
    echo -e "${CYAN}    / \\  | | ___  ___  __ _(_)     ${NC}"
    echo -e "${CYAN}   / _ \\ | |/ _ \\/ __|/ _\` | |     ${NC}"
    echo -e "${CYAN}  / ___ \\| |  __/\\__ \\ (_| | |     ${NC}"
    echo -e "${CYAN} /_/   \\_\\_|\\___||___/\\__, |_|     ${NC}"
    echo -e "${CYAN}                         |_|       ${NC}"
    echo -e "${CYAN}${BOLD}   Intelligence Distribution${NC}"
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

# Detect if running from cloned repo or downloaded script
if [ -d "$(dirname "${BASH_SOURCE[0]:-$0}")/.git" ] || git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
    # Running from cloned repository
    REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
    FROM_CLONE=true
else
    # Running from downloaded/curled script - need to clone first
    REPO_DIR=""
    FROM_CLONE=false
fi

# If not running from cloned repo, we need to clone it
if [ "$FROM_CLONE" = false ]; then
    echo ""
    print_info "Installation Directory Selection"
    echo "Choose where to install Alesqui Intelligence."
    echo ""
    
    # Default based on OS
    if [ "$OS" = "Windows" ]; then
        DEFAULT_DIR="$HOME/alesqui-intelligence"
    else
        DEFAULT_DIR="$HOME/alesqui-intelligence"
    fi
    
    read -p "Installation directory [default: $DEFAULT_DIR]: " INSTALL_DIR </dev/tty
    INSTALL_DIR=${INSTALL_DIR:-"$DEFAULT_DIR"}
    
    # Expand ~ to home directory
    INSTALL_DIR="${INSTALL_DIR/#\~/$HOME}"
    
    # Check if directory exists
    if [ -d "$INSTALL_DIR" ]; then
        print_warning "Directory $INSTALL_DIR already exists"
        read -p "Overwrite? [y/N]: " overwrite </dev/tty
        if [[ ! $overwrite =~ ^[Yy]$ ]]; then
            echo "Installation cancelled."
            exit 0
        fi
        rm -rf "$INSTALL_DIR"
    fi
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$INSTALL_DIR")"
    
    if command -v git &> /dev/null; then
        git clone https://github.com/eloisa-alesqui/alesqui-intelligence-distribution.git "$INSTALL_DIR"
        cd "$INSTALL_DIR"
        REPO_DIR="$INSTALL_DIR"
        
        print_success "Repository cloned to: $INSTALL_DIR"
        log "Installation directory: $INSTALL_DIR"
    else
        echo "Error: git is not installed and is required to download the repository."
        echo ""
        echo "Please either:"
        echo "  1. Install git and run this script again"
        if [ "$OS" = "Windows" ]; then
            echo "     Download from: https://git-scm.com/download/win"
        fi
        echo "  2. Clone the repository manually:"
        echo "     git clone https://github.com/eloisa-alesqui/alesqui-intelligence-distribution.git"
        echo "     cd alesqui-intelligence-distribution"
        if [ "$OS" = "Windows" ]; then
            echo "     bash install.sh"
        else
            echo "     ./install.sh"
        fi
        exit 1
    fi
fi

# =============================================================================
# SIGNAL HANDLING
# =============================================================================

# Trap errors
trap 'echo -e "${RED}Error occurred. Installation aborted.${NC}"; exit 1' ERR

# Trap interrupt
trap 'echo -e "${YELLOW}Installation cancelled by user.${NC}"; exit 130' INT TERM

# =============================================================================
# DEPENDENCY CHECKS
# =============================================================================

check_os() {
    print_section "Detecting Operating System"
    
    OS="$(uname -s)"
    case "$OS" in
        Linux*)     
            OS="Linux"
            ;;
        Darwin*)    
            OS="macOS"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            OS="Windows"
            print_info "Windows detected - Docker Desktop required"
            ;;
        *)          
            print_error "Unsupported operating system: $OS"
            log_error "Unsupported OS: $OS"
            echo ""
            echo "This installer supports:"
            echo "  - Linux (Ubuntu, Debian, CentOS, RHEL, etc.)"
            echo "  - macOS"
            echo "  - Windows (with Docker Desktop and Git Bash)"
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
        elif [ "$OS" = "Windows" ]; then
            echo "  # Install Docker Desktop for Windows"
            echo "  https://docs.docker.com/desktop/install/windows-install/"
            echo ""
            echo "  Requirements:"
            echo "  - Windows 10/11 Pro, Enterprise, or Education"
            echo "  - WSL 2 backend (installed automatically by Docker Desktop)"
            echo "  - Virtualization enabled in BIOS"
        fi
        echo ""
        exit 1
    fi
    
    # Check if Docker daemon is running (critical on Windows)
    if ! docker info &> /dev/null; then
        print_error "Docker is installed but not running"
        echo ""
        if [ "$OS" = "Windows" ]; then
            echo "Please start Docker Desktop:"
            echo "  1. Open Docker Desktop from Start Menu"
            echo "  2. Wait for 'Docker Desktop is running' message"
            echo "  3. Run this installer again"
        else
            echo "Please start the Docker daemon:"
            echo "  sudo systemctl start docker"
        fi
        echo ""
        exit 1
    fi
    
    # Check Docker version
    DOCKER_VERSION=$(docker --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
    DOCKER_MAJOR=$(echo "$DOCKER_VERSION" | cut -d. -f1)
    DOCKER_MINOR=$(echo "$DOCKER_VERSION" | cut -d. -f2)
    
    # Validate version numbers are numeric
    if ! [[ "$DOCKER_MAJOR" =~ ^[0-9]+$ ]] || ! [[ "$DOCKER_MINOR" =~ ^[0-9]+$ ]]; then
        print_warning "Could not parse Docker version"
        log "Docker version parsing failed: $DOCKER_VERSION"
    elif [ "$DOCKER_MAJOR" -lt 20 ] || ([ "$DOCKER_MAJOR" -eq 20 ] && [ "$DOCKER_MINOR" -lt 10 ]); then
        print_warning "Docker version $DOCKER_VERSION is older than recommended (20.10+)"
        log "Docker version $DOCKER_VERSION (warning: old version)"
    else
        print_success "Docker $DOCKER_VERSION is installed and running"
        log "Docker version: $DOCKER_VERSION"
    fi
}

check_docker_compose() {
    print_section "Checking Docker Compose Installation"
    
    # Try docker compose (v2) - standard on Windows Docker Desktop
    if docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
        COMPOSE_VERSION=$(docker compose version --short 2>/dev/null || docker compose version | grep -oE 'v?[0-9]+\.[0-9]+\.[0-9]+' | head -1 | sed 's/v//')
    # Try docker-compose (v1) - older Linux installations
    elif command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
        COMPOSE_VERSION=$(docker-compose --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    else
        print_error "Docker Compose is not available"
        log_error "Docker Compose not found"
        echo ""
        
        if [ "$OS" = "Windows" ]; then
            echo "Docker Compose should be included with Docker Desktop."
            echo ""
            echo "Please ensure:"
            echo "  1. Docker Desktop is fully installed"
            echo "  2. Docker Desktop is running"
            echo "  3. You've restarted your terminal after installing Docker Desktop"
        elif [ "$OS" = "Linux" ]; then
            echo "Docker Compose is required to run Alesqui Intelligence."
            echo ""
            echo "Installation instructions:"
            echo "  # Install Docker Compose v2"
            echo "  sudo curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)\" -o /usr/local/bin/docker-compose"
            echo "  sudo chmod +x /usr/local/bin/docker-compose"
        elif [ "$OS" = "macOS" ]; then
            echo "Docker Desktop for Mac includes Docker Compose"
            echo "Make sure Docker Desktop is running"
        fi
        echo ""
        exit 1
    fi
    
    print_success "Docker Compose $COMPOSE_VERSION is available"
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
    print_section "Checking prerequisites..."
    
    log "Installation log: $INSTALL_LOG"
    
    check_os
    check_docker
    check_docker_compose
    check_utilities
    
    echo ""
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
        read -p "Enter your choice [1-2]: " choice </dev/tty
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
        # Linux and Windows (Git Bash uses GNU sed)
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

configure_environment() {
    print_section "Environment Configuration"
    
    echo ""
    echo "Let's configure your deployment."
    echo ""
    
    # Company Name
    read -p "Company Name [default: My Company]: " company_name </dev/tty
    company_name=${company_name:-"My Company"}
    log "Company name: $company_name"
    
    # MongoDB Configuration - Atlas or Local specific
    if [ "$DEPLOYMENT_TYPE" = "atlas" ]; then
        echo ""
        print_info "MongoDB Atlas Configuration:"
        echo "You need a MongoDB Atlas connection string."
        echo "Get one at: https://cloud.mongodb.com"
        echo ""
        read -p "Enter MongoDB Atlas URI (mongodb+srv://...): " mongodb_uri </dev/tty
        while [[ ! $mongodb_uri =~ ^mongodb\+srv:// ]]; do
            print_error "Invalid URI. Must start with mongodb+srv://"
            read -p "Enter MongoDB Atlas URI: " mongodb_uri </dev/tty
        done
        
        # Extract database name from URI for user confirmation
        extracted_db=""
        if [[ $mongodb_uri =~ \.net/([^?]+) ]] && [[ -n "${BASH_REMATCH[1]}" ]]; then
            extracted_db="${BASH_REMATCH[1]}"
            print_info "Database name from URI: $extracted_db"
            echo "The application will connect to the '$extracted_db' database."
            echo ""
        else
            print_warning "Could not extract database name from URI."
            echo "Make sure your URI includes the database name after .mongodb.net/"
            echo "Example: mongodb+srv://user:pass@cluster.net/DATABASE_NAME?options"
            echo ""
        fi
        
        log "MongoDB Atlas URI configured (database: ${extracted_db:-unknown})"
    else
        echo ""
        print_info "MongoDB Configuration (Local):"
        read -p "Enter MongoDB password (for local container) [default: mongopassword]: " mongodb_password </dev/tty
        mongodb_password=${mongodb_password:-mongopassword}
        log "MongoDB password configured"
    fi
    
    # JWT Secret Generation
    echo ""
    print_info "JWT Secret Configuration:"
    echo "A JWT secret is required for authentication token signing."
    read -p "Generate JWT secret automatically? [Y/n]: " generate_jwt </dev/tty
    if [[ $generate_jwt =~ ^[Nn]$ ]]; then
        read -p "Enter your JWT secret (minimum 32 characters): " jwt_secret </dev/tty
        while [ ${#jwt_secret} -lt 32 ]; do
            print_error "JWT secret must be at least 32 characters"
            read -p "Enter JWT secret: " jwt_secret </dev/tty
        done
    else
        jwt_secret=$(generate_jwt_secret)
        print_success "Generated JWT secret"
    fi
    log "JWT secret configured"
    
    # OpenAI API Key
    echo ""
    print_info "OpenAI API Key:"
    echo "Get your API key at: https://platform.openai.com/api-keys"
    read -p "Enter OpenAI API key (sk-...): " openai_key </dev/tty
    while [[ ! $openai_key =~ ^sk- ]]; do
        print_error "Invalid API key. Must start with 'sk-'"
        read -p "Enter OpenAI API key: " openai_key </dev/tty
    done
    log "OpenAI API key configured"
    
    # SMTP Configuration (REQUIRED)
    echo ""
    print_info "SMTP Configuration (REQUIRED for user account activation):"
    echo "Supported providers: Gmail, SendGrid, Mailgun, Amazon SES, or company SMTP"
    echo ""
    read -p "SMTP Host (e.g., smtp.gmail.com): " smtp_host </dev/tty
    while [ -z "$smtp_host" ]; do
        print_error "SMTP Host is required"
        read -p "SMTP Host (e.g., smtp.gmail.com): " smtp_host </dev/tty
    done
    
    read -p "SMTP Port [default: 587]: " smtp_port </dev/tty
    smtp_port=${smtp_port:-587}
    
    read -p "SMTP User (email address): " smtp_user </dev/tty
    while [ -z "$smtp_user" ]; do
        print_error "SMTP User is required"
        read -p "SMTP User (email address): " smtp_user </dev/tty
    done
    
    read -sp "SMTP Password: " smtp_password </dev/tty
    echo ""
    while [ -z "$smtp_password" ]; do
        print_error "SMTP Password is required"
        read -sp "SMTP Password: " smtp_password </dev/tty
        echo ""
    done
    
    read -p "Email 'From' address [default: $smtp_user]: " from_email </dev/tty
    from_email=${from_email:-$smtp_user}
    log "SMTP configured"
    
    # Frontend URL
    echo ""
    if [ "$DEPLOYMENT_TYPE" = "atlas" ]; then
        read -p "Frontend URL [default: https://intelligence.yourcompany.com]: " frontend_url </dev/tty
        frontend_url=${frontend_url:-"https://intelligence.yourcompany.com"}
    else
        read -p "Frontend URL [default: http://localhost]: " frontend_url </dev/tty
        frontend_url=${frontend_url:-"http://localhost"}
    fi
    log "Frontend URL: $frontend_url"
    
    # Admin Email (REQUIRED)
    echo ""
    read -p "Admin email address: " admin_email </dev/tty
    while [[ ! $admin_email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; do
        print_error "Invalid email format"
        read -p "Admin email address: " admin_email </dev/tty
    done
    log "Admin email: $admin_email"
    
    print_success "Environment configuration completed"
}



create_env_file() {
    print_section "Creating .env file..."
    
    ENV_FILE="$DEPLOYMENT_DIR/.env"
    
    # Check if .env already exists
    if [ -f "$ENV_FILE" ]; then
        print_warning ".env file already exists"
        read -p "Do you want to overwrite it? [y/N]: " overwrite </dev/tty
        if [[ ! $overwrite =~ ^[Yy]$ ]]; then
            print_info "Using existing .env file"
            log "Using existing .env file"
            return
        fi
    fi
    
    cat > "$ENV_FILE" << EOF
# =============================================================================
# GENERAL
# =============================================================================
COMPANY_NAME=$company_name

# =============================================================================
# SECURITY
# =============================================================================
JWT_SECRET=$jwt_secret
JWT_EXPIRATION=900000
JWT_REFRESH_EXPIRATION=604800000
OPENAI_API_KEY=$openai_key

# =============================================================================
# DATABASE
# =============================================================================
EOF

    if [ "$DEPLOYMENT_TYPE" = "atlas" ]; then
        cat >> "$ENV_FILE" << EOF
MONGODB_ATLAS_URI=$mongodb_uri
MONGODB_DATABASE=$extracted_db
EOF
    else
        cat >> "$ENV_FILE" << EOF
MONGODB_PASSWORD=$mongodb_password
# MONGODB_URI: The \$ prevents shell expansion during file creation,
# allowing Docker Compose to substitute MONGODB_PASSWORD at container runtime
MONGODB_URI=mongodb://admin:\${MONGODB_PASSWORD}@mongodb:27017/alesqui_intelligence?authSource=admin
MONGODB_DATABASE=alesqui_intelligence
MONGODB_USER=admin
MONGODB_AUTH_DB=admin
EOF
    fi

    cat >> "$ENV_FILE" << EOF

# =============================================================================
# APPLICATION
# =============================================================================
PORT=8080
FRONTEND_URL=$frontend_url

# =============================================================================
# EMAIL CONFIGURATION
# =============================================================================
SMTP_HOST=$smtp_host
SMTP_PORT=$smtp_port
SMTP_USER=$smtp_user
SMTP_PASSWORD=$smtp_password
MAIL_FROM_EMAIL=$from_email
MAIL_FROM_NAME="$company_name - Intelligence"

# =============================================================================
# AUDIT LOGGING
# =============================================================================
AUDIT_RETENTION_DAYS=730

# =============================================================================
# ADMIN
# =============================================================================
INITIAL_ADMIN_EMAIL=$admin_email
EOF

    # Normalize line endings (remove CRLF on Windows)
    if [ "$OS" = "Windows" ]; then
        # Use dos2unix if available, otherwise use sed
        if command -v dos2unix &> /dev/null; then
            dos2unix "$ENV_FILE" 2>/dev/null || true
        else
            # Fallback: use sed to remove CR characters
            sed -i 's/\r$//' "$ENV_FILE" 2>/dev/null || true
        fi
    fi

    print_success "Configuration saved to $ENV_FILE"
    log "Created .env file at $ENV_FILE"
    echo ""
}

# =============================================================================
# DEPLOYMENT
# =============================================================================

run_deployment() {
    print_section "Starting deployment..."
    echo "This may take a few minutes to download Docker images."
    echo ""
    
    cd "$DEPLOYMENT_DIR"
    
    if [ "$DEPLOYMENT_TYPE" = "atlas" ]; then
        bash ../scripts/start-atlas.sh
    else
        bash ../scripts/start-local.sh
    fi
    
    DEPLOY_EXIT_CODE=$?
    cd "$REPO_DIR"
    
    return $DEPLOY_EXIT_CODE
}

# =============================================================================
# HEALTH CHECKS
# =============================================================================

health_check() {
    print_section "Performing health checks..."
    echo "Waiting for services to be ready..."
    
    sleep 10
    
    # Check backend
    for i in {1..30}; do
        if curl -sf http://localhost:8080/actuator/health > /dev/null 2>&1; then
            print_success "Backend is healthy"
            log "Backend health check passed"
            break
        fi
        if [ $i -eq 30 ]; then
            print_warning "Backend health check timeout"
            log "Backend health check timeout"
            break
        fi
        sleep 2
    done
    
    # Check frontend
    if curl -sf http://localhost > /dev/null 2>&1; then
        print_success "Frontend is accessible"
        log "Frontend health check passed"
    else
        print_warning "Frontend not yet accessible"
        log "Frontend not yet accessible"
    fi
    
    echo ""
}

# =============================================================================
# SUCCESS MESSAGE
# =============================================================================

show_success_message() {
    # Save installation info
    # Get date with timezone (UTC if supported, local otherwise)
    if date -u +"%Y-%m-%d %H:%M:%S UTC" > /dev/null 2>&1; then
        INSTALL_DATE=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    else
        # Fall back to local time without UTC label
        INSTALL_DATE=$(date +"%Y-%m-%d %H:%M:%S")
    fi
    
    cat > "$REPO_DIR/.install-info" << EOF
INSTALL_DATE="$INSTALL_DATE"
INSTALL_DIR="$REPO_DIR"
DEPLOYMENT_TYPE="$DEPLOYMENT_TYPE"
OS="$OS"
VERSION="1.0.0"
EOF

    echo "Installation info saved to: $REPO_DIR/.install-info"
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}   🎉 Installation Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Access your application:"
    echo -e "  ${BLUE}Frontend:${NC}     $frontend_url"
    echo -e "  ${BLUE}Backend API:${NC}  http://localhost:8080"
    echo -e "  ${BLUE}Health:${NC}       http://localhost:8080/actuator/health"
    echo ""
    
    echo "Installation directory:"
    echo -e "  ${BLUE}$REPO_DIR${NC}"
    echo ""
    
    if [ "$OS" = "Windows" ]; then
        echo "Windows-specific notes:"
        echo "  • Docker Desktop must remain running"
        echo "  • Services accessible from Windows browser at localhost"
        echo ""
    fi
    
    echo "To manage your installation:"
    echo -e "  ${BLUE}cd $REPO_DIR${NC}"
    if [ "$DEPLOYMENT_TYPE" = "atlas" ]; then
        echo "  cd atlas && docker compose logs      # View logs"
        echo "  cd atlas && docker compose down      # Stop services"
        echo "  cd atlas && docker compose up -d     # Start services"
    else
        echo "  cd local && docker compose logs      # View logs"
        echo "  cd local && docker compose down      # Stop services"
        echo "  cd local && docker compose up -d     # Start services"
    fi
    echo ""
    echo "Or use the management script:"
    echo "  ./manage.sh start    # Start services"
    echo "  ./manage.sh stop     # Stop services"
    echo "  ./manage.sh restart  # Restart services"
    echo "  ./manage.sh logs     # View logs"
    echo "  ./manage.sh status   # Check status"
    echo ""
    
    echo "Next steps:"
    echo "  1. Visit $frontend_url to access the application"
    echo "  2. The initial admin account has been created automatically"
    echo "  3. To get the auto-generated password, check the backend logs:"
    echo "     cd $DEPLOYMENT_DIR && docker compose logs backend | grep 'Password:'"
    echo "  4. Login with:"
    echo "     • Email: $admin_email"
    echo "     • Password: (from logs above)"
    echo "  5. ⚠️  IMPORTANT: Change the password immediately after first login!"
    echo ""
    echo "Documentation:"
    echo "  https://github.com/eloisa-alesqui/alesqui-intelligence-distribution"
    echo ""
    echo "Need help? support@alesqui.com"
    echo ""
    
    log "Installation completed successfully"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    # Welcome
    echo "========================================"
    echo "   Alesqui Intelligence Installer"
    echo "========================================"
    echo ""
    echo "This script will guide you through the installation"
    echo "of Alesqui Intelligence on your system."
    echo ""
    
    # Initialize log
    echo "=== Alesqui Intelligence Installation ===" > "$INSTALL_LOG"
    log "Installation started"
    
    # Check dependencies
    check_dependencies
    
    # Add Windows-specific warning after OS detection
    if [ "$OS" = "Windows" ]; then
        # Check if stdin is a pipe (non-interactive)
        if [ ! -t 0 ]; then
            # Running from pipe (curl | bash), skip interactive prompt
            echo ""
            echo -e "${YELLOW}⚠️  Windows Installation Notes:${NC}"
            echo "  • Docker Desktop for Windows is required"
            echo "  • Make sure Docker Desktop is running before proceeding"
            echo "  • This script must be run in Git Bash (not PowerShell/CMD)"
            echo ""
            echo "Continuing with installation..."
            echo ""
        else
            # Running interactively, ask for confirmation
            echo ""
            echo -e "${YELLOW}⚠️  Windows Installation Notes:${NC}"
            echo "  • Docker Desktop for Windows is required"
            echo "  • Make sure Docker Desktop is running before proceeding"
            echo "  • This script must be run in Git Bash (not PowerShell/CMD)"
            echo ""
            read -p "Press Enter to continue or Ctrl+C to cancel..." </dev/tty
            echo ""
        fi
    fi
    
    # Choose deployment
    choose_deployment
    
    # Configure environment
    configure_environment
    
    # Create .env file
    create_env_file
    
    # Run deployment
    if run_deployment; then
        health_check
        show_success_message
    else
        echo ""
        echo -e "${RED}========================================${NC}"
        echo -e "${RED}   ✗ Installation Failed${NC}"
        echo -e "${RED}========================================${NC}"
        echo ""
        echo "Please check the error messages above."
        echo "For help, visit:"
        echo "  https://github.com/eloisa-alesqui/alesqui-intelligence-distribution/issues"
        echo ""
        exit 1
    fi
}

# Run main function
main
