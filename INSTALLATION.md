# 📖 Installation Guide - Alesqui Intelligence

Complete installation instructions for deploying Alesqui Intelligence with Docker.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation Steps](#installation-steps)
3. [MongoDB Configuration](#mongodb-configuration)
4. [Environment Variables](#environment-variables)
5. [Starting the Application](#starting-the-application)
6. [Verification](#verification)
7. [Post-Installation](#post-installation)

---

## Prerequisites

### Required Software

**Docker & Docker Compose**
```bash
# Check if installed
docker --version        # Should be 20.10+
docker-compose --version # Should be 2.0+

# Install on Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker run hello-world
```

### System Requirements

- **RAM:** 4GB minimum, 8GB recommended
- **Disk Space:** 10GB minimum
- **CPU:** 2 cores minimum
- **OS:** Linux, macOS, or Windows with WSL2

### Required Credentials

Before starting, you need:
1. **OpenAI API Key** - Get from https://platform.openai.com/api-keys
2. **MongoDB Connection** - Choose local MongoDB or create Atlas cluster

---

## Installation Steps

### Step 1: Clone the Repository

```bash
git clone https://github.com/eloisa-alesqui/alesqui-intelligence-distribution.git
cd alesqui-intelligence-distribution
```

### Step 2: Create Environment File

```bash
cp .env.example .env
```

### Step 3: Generate Secure Secrets

```bash
# Option 1: Use the provided script
./scripts/generate-secrets.sh

# Option 2: Generate manually
openssl rand -base64 32  # For JWT_SECRET
openssl rand -base64 24 | tr -d "=+/" | cut -c1-20  # For MongoDB password
```

### Step 4: Configure Environment Variables

Edit the `.env` file with your favorite editor:
```bash
nano .env
# or
vim .env
# or
code .env
```

**Minimum required changes:**
```bash
# 1. Set MongoDB password (if using local MongoDB)
MONGODB_ROOT_PASSWORD=your_secure_password_here

# 2. Update MongoDB URI with your password
MONGODB_URI=mongodb://admin:your_secure_password_here@mongodb:27017/alesqui_intelligence?authSource=admin

# 3. Set a secure JWT secret
JWT_SECRET=your_generated_jwt_secret_here

# 4. Add your OpenAI API key
OPENAI_API_KEY=sk-proj-your-actual-api-key-here

# 5. Set your company name (optional)
COMPANY_NAME=Your Company Name
```

---

## MongoDB Configuration

You have two options for MongoDB:

### Option A: Local MongoDB (Recommended for Testing)

**Advantages:**
- ✅ No external dependencies
- ✅ Complete control over data
- ✅ No internet required after setup
- ✅ Free

**Configuration in `.env`:**
```bash
# Keep these lines uncommented
MONGODB_ROOT_USER=admin
MONGODB_ROOT_PASSWORD=your_secure_password
MONGODB_DATABASE=alesqui_intelligence
MONGODB_URI=mongodb://admin:your_secure_password@mongodb:27017/alesqui_intelligence?authSource=admin
```

**Start command:**
```bash
docker-compose --profile local-db up -d
```

### Option B: MongoDB Atlas (Recommended for Production)

**Advantages:**
- ✅ Managed service
- ✅ Automatic backups
- ✅ High availability
- ✅ Easy scaling

**Setup Steps:**

1. **Create Atlas Account**
   - Go to https://cloud.mongodb.com
   - Sign up for free account

2. **Create Cluster**
   - Click "Build a Database"
   - Choose "M0 Sandbox" (Free tier)
   - Select cloud provider and region
   - Click "Create"

3. **Configure Access**
   - **Database Access:** Create a database user
     - Username: `alesqui`
     - Password: Generate a secure password
     - Role: `Atlas admin` or `Read and write to any database`
   
   - **Network Access:** Add IP addresses
     - For testing: Add `0.0.0.0/0` (allows from anywhere)
     - For production: Add your server's specific IP

4. **Get Connection String**
   - Click "Connect" on your cluster
   - Choose "Connect your application"
   - Copy the connection string
   - Replace `<password>` with your database user password
   - Replace `<database>` with `alesqui_intelligence`

5. **Update `.env` file:**
   ```bash
   # Comment out local MongoDB variables
   # MONGODB_ROOT_USER=admin
   # MONGODB_ROOT_PASSWORD=...
   # MONGODB_DATABASE=alesqui_intelligence
   
   # Use Atlas connection string
   MONGODB_URI=mongodb+srv://alesqui:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/alesqui_intelligence?retryWrites=true&w=majority
   ```

6. **Start command:**
   ```bash
   docker-compose up -d
   ```

---

## Environment Variables

### Complete Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `COMPANY_NAME` | No | `Alesqui Intelligence` | Your company name |
| `MONGODB_URI` | **Yes** | - | MongoDB connection string |
| `MONGODB_ROOT_USER` | Local only | `admin` | MongoDB root username |
| `MONGODB_ROOT_PASSWORD` | Local only | - | MongoDB root password |
| `MONGODB_DATABASE` | No | `alesqui_intelligence` | Database name |
| `JWT_SECRET` | **Yes** | - | Secret for JWT tokens (min 32 chars) |
| `JWT_EXPIRATION` | No | `900000` | Access token expiration (15 min) |
| `JWT_REFRESH_EXPIRATION` | No | `604800000` | Refresh token expiration (7 days) |
| `OPENAI_API_KEY` | **Yes** | - | OpenAI API key |
| `FRONTEND_URL` | No | `http://localhost` | Frontend URL for CORS |
| `VITE_API_BASE_URL` | No | `http://localhost:8080` | Backend API URL |
| `CORS_ADDITIONAL_ORIGINS` | No | - | Additional CORS origins (comma-separated) |
| `BACKEND_IMAGE` | No | `eloisa-alesqui/...` | Backend Docker image |
| `FRONTEND_IMAGE` | No | `eloisa-alesqui/...` | Frontend Docker image |
| `FRONTEND_PORT` | No | `80` | Frontend exposed port |
| `BACKEND_PORT` | No | `8080` | Backend exposed port |
| `SPRING_PROFILES_ACTIVE` | No | `default` | Spring Boot profile |
| `JAVA_OPTS` | No | Memory settings | JVM options |

---

## Starting the Application

### With Local MongoDB

```bash
# Start all services including MongoDB
docker-compose --profile local-db up -d

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

### With MongoDB Atlas

```bash
# Start backend and frontend only
docker-compose up -d

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

### First Startup

The first time you start the application:
1. Docker will pull images (may take 5-10 minutes)
2. Backend will initialize (may take 30-60 seconds)
3. Frontend will be available immediately

**Expected output:**
```
✔ Container alesqui-mongodb   Started
✔ Container alesqui-backend   Started  
✔ Container alesqui-frontend  Started
```

---

## Verification

### Check Container Status

```bash
docker-compose ps
```

**Expected output:**
```
NAME                 STATUS                   PORTS
alesqui-mongodb      Up 2 minutes (healthy)   0.0.0.0:27017->27017/tcp
alesqui-backend      Up 1 minute (healthy)    0.0.0.0:8080->8080/tcp
alesqui-frontend     Up 1 minute (healthy)    0.0.0.0:80->80/tcp
```

### Check Backend Health

```bash
curl http://localhost:8080/actuator/health
```

**Expected response:**
```json
{"status":"UP"}
```

### Check Frontend

```bash
curl -I http://localhost
```

**Expected response:**
```
HTTP/1.1 200 OK
```

### Access the Application

Open your browser:
- **Frontend:** http://localhost
- **Backend API:** http://localhost:8080
- **Health Check:** http://localhost:8080/actuator/health

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mongodb
```

---

## Post-Installation

### Create Admin User

Access the frontend and register the first user through the UI.

### Run Health Check Script

```bash
./scripts/health-check.sh
```

### Configure Backup (if using local MongoDB)

Create a backup script:
```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker exec alesqui-mongodb mongodump \
  --username admin \
  --password YOUR_PASSWORD \
  --authenticationDatabase admin \
  --out /backup_$DATE
docker cp alesqui-mongodb:/backup_$DATE ./backups/
```

Schedule with cron:
```bash
# Daily backup at 2 AM
0 2 * * * /path/to/backup-script.sh
```

### Configure Firewall

If running on a server, configure firewall:
```bash
# Ubuntu/Debian with UFW
sudo ufw allow 80/tcp     # Frontend
sudo ufw allow 8080/tcp   # Backend (if needed)
sudo ufw deny 27017/tcp   # MongoDB (don't expose)

# CentOS/RHEL with firewalld
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

### Set Up HTTPS (Production)

Use a reverse proxy like Nginx or Caddy:

**With Caddy (easiest):**
```bash
# Install Caddy
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy

# Configure Caddy
sudo nano /etc/caddy/Caddyfile
```

Add:
```
intelligence.yourcompany.com {
    reverse_proxy localhost:80
}

api.intelligence.yourcompany.com {
    reverse_proxy localhost:8080
}
```

Start Caddy:
```bash
sudo systemctl restart caddy
```

### Update .env for Production

```bash
# Update frontend URL to your domain
FRONTEND_URL=https://intelligence.yourcompany.com

# Update API URL
VITE_API_BASE_URL=https://api.intelligence.yourcompany.com
```

Restart services:
```bash
docker-compose down
docker-compose up -d
```

---

## Updating the Application

### Pull New Versions

```bash
# Stop services
docker-compose down

# Pull latest images
docker-compose pull

# Start with new versions
docker-compose up -d
```

### Backup Before Update

```bash
# If using local MongoDB
./scripts/backup-database.sh

# Or manually
docker exec alesqui-mongodb mongodump \
  --out /backup_before_update
```

---

## Uninstalling

### Remove Containers and Images

```bash
# Stop and remove containers
docker-compose down

# Remove volumes (⚠️ DELETES DATA!)
docker-compose down -v

# Remove images
docker rmi eloisa-alesqui/alesqui-intelligence-backend:latest
docker rmi eloisa-alesqui/alesqui-intelligence-frontend:latest
docker rmi mongo:7
```

---

## Next Steps

- Read the [Troubleshooting Guide](TROUBLESHOOTING.md) for common issues
- Configure automated backups
- Set up monitoring and alerting
- Review security best practices
- Plan for scaling if needed

---

## Getting Help

- **Documentation:** https://docs.alesqui.com
- **Email:** support@alesqui.com
- **GitHub Issues:** https://github.com/eloisa-alesqui/alesqui-intelligence-distribution/issues

---

**Happy deploying! 🚀**
