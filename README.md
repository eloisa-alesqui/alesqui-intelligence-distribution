# 🚀 Alesqui Intelligence - Docker Distribution

**Deploy Alesqui Intelligence on your own servers with a single command.**

This repository provides two deployment options for the complete Alesqui Intelligence stack using Docker:
- ✅ **Local Deployment** - Self-hosted MongoDB in Docker container
- ✅ **Atlas Deployment** - Cloud-managed MongoDB Atlas
- ✅ React Frontend (Nginx) on port 80
- ✅ Java Spring Boot Backend on port 8080
- ✅ Complete orchestration with Docker Compose

---

## 📋 Quick Start

Choose your deployment option:

### Option A: Local MongoDB (Recommended for Development)

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

### Option B: MongoDB Atlas (Recommended for Production)

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
