# 🚀 Alesqui Intelligence - Docker Distribution

**Deploy Alesqui Intelligence on your own servers with a single command.**

This repository provides two deployment options for the complete Alesqui Intelligence stack using Docker:
- ✅ **Local Deployment** - Self-hosted MongoDB in Docker container
- ✅ **Atlas Deployment** - Cloud-managed MongoDB Atlas
- ✅ React Frontend (Nginx) on port 80
- ✅ Java Spring Boot Backend on port 8080
- ✅ Complete orchestration with Docker Compose

---

## 🚀 Quick Start

Deploy Alesqui Intelligence in minutes with our automated installer:

```bash
curl -fsSL https://raw.githubusercontent.com/eloisa-alesqui/alesqui-intelligence-distribution/main/install.sh | bash
```

The installer will:
- ✅ Check system requirements
- ✅ Guide you through configuration
- ✅ Set up your `.env` file
- ✅ Deploy all services
- ✅ Perform health checks

**Alternative:** [Download manually](#-installation-methods) and follow the installation guide.

---

## 📦 Installation Methods

### Method 1: Quick Install (Recommended)

Deploy Alesqui Intelligence with the automated installer:

```bash
curl -fsSL https://raw.githubusercontent.com/eloisa-alesqui/alesqui-intelligence-distribution/main/install.sh | bash
```

### Method 2: Download Release Package

Download the latest stable release:

```bash
# Download
wget https://github.com/eloisa-alesqui/alesqui-intelligence-distribution/releases/latest/download/alesqui-intelligence.tar.gz

# Verify integrity (optional but recommended)
wget https://github.com/eloisa-alesqui/alesqui-intelligence-distribution/releases/latest/download/checksums.txt
sha256sum -c checksums.txt

# Extract
tar -xzf alesqui-intelligence.tar.gz
cd alesqui-intelligence

# Install
./install.sh
```

Or download a specific version:

```bash
VERSION=v1.0.0
wget https://github.com/eloisa-alesqui/alesqui-intelligence-distribution/releases/download/${VERSION}/alesqui-intelligence.tar.gz
```

### Method 3: Clone Repository

Clone the repository and run the installer:

```bash
git clone https://github.com/eloisa-alesqui/alesqui-intelligence-distribution.git
cd alesqui-intelligence-distribution
./install.sh
```

---

## 📋 Deployment Options

Choose your deployment option:

### Local MongoDB (Recommended for Development)

```bash
# Clone repository
git clone https://github.com/eloisa-alesqui/alesqui-intelligence-distribution.git
cd alesqui-intelligence-distribution

# Run automated setup script
./scripts/start-local.sh
```

The script will:
1. Check prerequisites (Docker, Docker Compose)
2. Validate configuration
3. Pull latest images
4. Start all services with health checks
5. Show access URLs

📖 **[Full Local Setup Guide →](local/README.md)**

### MongoDB Atlas (Recommended for Production)

```bash
# Clone repository
git clone https://github.com/eloisa-alesqui/alesqui-intelligence-distribution.git
cd alesqui-intelligence-distribution

# Set up MongoDB Atlas first (see atlas/README.md)
# Then run automated setup script
./scripts/start-atlas.sh
```

📖 **[Full Atlas Setup Guide →](atlas/README.md)**

### Access Your Application

Once services are healthy:
- **Frontend:** http://localhost
- **Backend API:** http://localhost:8080
- **API Health:** http://localhost:8080/actuator/health

---

## 🔐 First Login

After starting the services, an admin user is automatically created on first startup.

To get your admin credentials:

```bash
# View the auto-generated password in logs
docker-compose logs backend | grep InitialAdmin
```

Default admin email: `admin@company.com`

**Important:** Change the password after your first login!

See the [local setup guide](local/README.md#-initial-admin-user) or [Atlas setup guide](atlas/README.md#-initial-admin-user) for more details on customizing admin credentials.

---

## 📦 Post-Installation Management

After installation, your Alesqui Intelligence instance is installed in a permanent directory (by default: `~/alesqui-intelligence`) and can be easily managed.

### Installation Directory

The installer saves your installation to a permanent location that persists across reboots:

- **Default location:** `~/alesqui-intelligence`
- **Custom location:** You can specify during installation
- **Installation info:** Stored in `.install-info` file in the installation directory

### Management Script

Use the `manage.sh` script to easily control your installation:

```bash
cd ~/alesqui-intelligence  # or your custom installation directory

# Start services
./manage.sh start

# Stop services
./manage.sh stop

# Restart services
./manage.sh restart

# View logs (all services)
./manage.sh logs

# View logs for specific service
./manage.sh logs backend

# Check installation and service status
./manage.sh status

# Create backup of configuration
./manage.sh backup

# Update to latest version
./manage.sh update

# Show help
./manage.sh help
```

### Manual Docker Compose Management

You can also manage services directly with Docker Compose:

```bash
cd ~/alesqui-intelligence

# For Atlas deployment
cd atlas && docker compose up -d      # Start services
cd atlas && docker compose down       # Stop services
cd atlas && docker compose logs -f    # View logs

# For Local deployment
cd local && docker compose up -d      # Start services
cd local && docker compose down       # Stop services
cd local && docker compose logs -f    # View logs
```

### Backup Your Configuration

Create a backup of your configuration files:

```bash
# Using management script
./manage.sh backup

# Or using the backup script directly
./scripts/backup.sh
```

Backups are stored in `~/alesqui-backups/` and include:
- Environment configuration (`.env`)
- Installation metadata (`.install-info`)

### Update to Latest Version

Update your installation to the latest version:

```bash
# Using management script (recommended - includes automatic backup)
./manage.sh update

# Or manually
git pull origin main
./manage.sh restart
```

### Uninstall

To completely remove Alesqui Intelligence:

```bash
cd ~/alesqui-intelligence
./scripts/uninstall.sh
```

The uninstall script will:
1. Stop all Docker containers
2. Remove containers and networks
3. Optionally remove database volumes
4. Optionally remove the installation directory

### Troubleshooting Installation Issues

If you encounter issues after installation:

```bash
# Check service status
./manage.sh status

# View logs for errors
./manage.sh logs

# Check Docker containers
docker ps -a

# Restart services
./manage.sh restart
```

---

## 🗂️ Repository Structure

```
alesqui-intelligence-distribution/
├── README.md                    # This file - Main documentation
├── .gitignore                   # Git ignore patterns
│
├── local/                       # Local MongoDB deployment
│   ├── docker-compose.yml       # Compose file with MongoDB container
│   ├── .env.example             # Environment template
│   └── README.md                # Detailed local setup guide
│
├── atlas/                       # MongoDB Atlas deployment
│   ├── docker-compose.yml       # Compose file for Atlas (no MongoDB)
│   ├── .env.example             # Environment template for Atlas
│   └── README.md                # Detailed Atlas setup guide
│
└── scripts/                     # Utility scripts
    ├── start-local.sh           # Start local deployment
    ├── start-atlas.sh           # Start Atlas deployment
    ├── stop.sh                  # Stop all services
    ├── update.sh                # Update Docker images
    ├── generate-secrets.sh      # Generate secure secrets
    └── health-check.sh          # Health check utility
```

---

## 🔄 Deployment Comparison

| Feature | Local MongoDB | MongoDB Atlas |
|---------|--------------|---------------|
| **Best For** | Development, testing, self-hosted | Production, scalable applications |
| **Database Location** | Docker container on your server | Cloud-managed by MongoDB |
| **Setup Complexity** | ⭐ Simple | ⭐⭐ Requires Atlas account |
| **Maintenance** | Manual backups, updates | Automatic backups, managed |
| **Cost** | Free (self-hosted) | Free tier available, paid for production |
| **Scalability** | Limited by server resources | Easy horizontal scaling |
| **Backups** | Manual | Automatic with point-in-time recovery |
| **Monitoring** | Basic Docker logs | Built-in performance monitoring |
| **Ports Required** | 80, 8080, 27017 | 80, 8080 only |
| **RAM Required** | 4GB minimum | 2GB minimum |

---

## 🎯 Components

### Services

- **Frontend (port 80)**
  - React + TypeScript + Vite
  - Served by Nginx
  - Health endpoint available
  
- **Backend (port 8080)**
  - Java 21 + Spring Boot 3 + WebFlux
  - RESTful API with OpenAI integration
  - Health check: `/actuator/health`
  
- **MongoDB (port 27017)** *(Local deployment only)*
  - MongoDB 7.0
  - Persistent storage with Docker volumes
  - Authentication enabled

### Docker Images

- **Backend:** `alesquiintelligence/backend:latest`
- **Frontend:** `alesquiintelligence/frontend:latest`
- **MongoDB:** `mongo:7.0` (local deployment only)

---

## 🔧 Common Commands

### Using Utility Scripts (Recommended)

```bash
# Start local deployment
./scripts/start-local.sh

# Start Atlas deployment
./scripts/start-atlas.sh

# Stop all services
./scripts/stop.sh

# Update to latest version
./scripts/update.sh

# Check service health
./scripts/health-check.sh

# Generate secure credentials
./scripts/generate-secrets.sh
```

### Manual Docker Compose Commands

**Local Deployment:**
```bash
cd local/
docker-compose up -d          # Start services
docker-compose ps             # Check status
docker-compose logs -f        # View logs
docker-compose down           # Stop services
```

**Atlas Deployment:**
```bash
cd atlas/
docker-compose up -d          # Start services
docker-compose ps             # Check status
docker-compose logs -f        # View logs
docker-compose down           # Stop services
```

---

## 📚 Documentation

- **[Local Deployment Guide](local/README.md)** - Complete guide for local MongoDB setup
- **[Atlas Deployment Guide](atlas/README.md)** - Complete guide for MongoDB Atlas setup
- **[Installation Guide](INSTALLATION.md)** - Legacy installation instructions
- **[Troubleshooting](TROUBLESHOOTING.md)** - Common issues and solutions

---

## 🔒 Security Best Practices

### Before Deployment

- [ ] Generate strong JWT_SECRET (minimum 32 characters): `openssl rand -base64 32`
- [ ] Create secure MongoDB password (local) or configure Atlas access
- [ ] Obtain valid OpenAI API key
- [ ] Configure production SMTP service

### For Production

- [ ] Use HTTPS with valid SSL certificates (Let's Encrypt, etc.)
- [ ] Set up reverse proxy (Nginx, Traefik, Caddy)
- [ ] Configure firewall rules (allow only 80, 443; block 8080, 27017 externally)
- [ ] Use production-grade SMTP (SendGrid, Mailgun, Amazon SES)
- [ ] Enable automated backups
- [ ] Set up monitoring and alerting
- [ ] Regular security updates: `./scripts/update.sh`
- [ ] Restrict MongoDB Atlas IP access (not 0.0.0.0/0)

---

## 🌐 Production Deployment

### SSL/TLS with Reverse Proxy

**Nginx Example:**
```nginx
server {
    listen 443 ssl http2;
    server_name intelligence.yourcompany.com;
    
    ssl_certificate /etc/letsencrypt/live/yourcompany.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourcompany.com/privkey.pem;
    
    location / {
        proxy_pass http://localhost:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
    }
}
```

**Caddy Example (Automatic HTTPS):**
```caddy
intelligence.yourcompany.com {
    reverse_proxy localhost:80
    
    handle /api* {
        reverse_proxy localhost:8080
    }
}
```

---

## 🏗️ Architecture

### Local Deployment
```
┌─────────────────────────────────────────────┐
│           Docker Network                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │ MongoDB  │←→│ Backend  │←→│ Frontend │ │
│  │  :27017  │  │  :8080   │  │   :80    │ │
│  └──────────┘  └──────────┘  └──────────┘ │
└─────────────────────────────────────────────┘
       ↓              ↓              ↓
   localhost:    localhost:    localhost
     27017          8080           :80
```

### Atlas Deployment
```
┌──────────────────────────────┐    ┌─────────────┐
│     Docker Network           │    │  MongoDB    │
│  ┌──────────┐  ┌──────────┐ │    │   Atlas     │
│  │ Backend  │←→│ Frontend │ │ ←→ │  (Cloud)    │
│  │  :8080   │  │   :80    │ │    │             │
│  └──────────┘  └──────────┘ │    └─────────────┘
└──────────────────────────────┘
       ↓              ↓
   localhost:    localhost
     8080           :80
```

---

## 🚨 Troubleshooting

### Quick Diagnostics

```bash
# Check service status
./scripts/health-check.sh

# View all logs
cd local/  # or cd atlas/
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mongodb  # local only

# Check container health
docker-compose ps
```

### Common Issues

**Services won't start:**
- Check `.env` file exists and is configured
- Verify ports 80, 8080 (and 27017 for local) are available
- Check Docker and Docker Compose are installed

**Backend can't connect to database:**
- **Local:** Verify MongoDB container is healthy: `docker-compose ps`
- **Atlas:** Check IP is whitelisted in Atlas Network Access
- Verify connection string format and credentials

**Users exist in Atlas but application says "no users found":**

**Cause:** Database name mismatch between URI and MONGODB_DATABASE variable.

**Solution:**
1. Check your `.env` file:
   ```bash
   grep MONGODB atlas/.env
   ```

2. Remove `MONGODB_DATABASE` if present:
   ```bash
   nano atlas/.env
   # Delete or comment out: MONGODB_DATABASE=...
   ```

3. Verify the database name in your URI:
   ```
   mongodb+srv://user:pass@cluster.net/YOUR_DATABASE_NAME?...
                                       ^^^^^^^^^^^^^^^^^^
   ```

4. Recreate containers:
   ```bash
   docker compose down
   docker compose up -d --force-recreate
   ```

5. Check which database it's connecting to:
   ```bash
   docker logs alesqui-backend | grep -iE 'mongo|database'
   ```

**For more detailed troubleshooting:** See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## 📞 Support

- **GitHub Issues:** [Report a bug or request a feature](https://github.com/eloisa-alesqui/alesqui-intelligence-distribution/issues)
- **Email:** support@alesqui.com
- **Documentation:** Full guides available in `local/` and `atlas/` directories

---

## 📄 License

This software is the property of Alesqui Intelligence.  
All rights reserved.

---

## 🆕 What's New

This repository now offers:
- ✨ **Separate deployment configurations** for local and Atlas
- ✨ **Automated setup scripts** with validation and health checks
- ✨ **Comprehensive documentation** for each deployment option
- ✨ **Production-ready configurations** with security best practices
- ✨ **Easy migration path** from local to Atlas deployment
