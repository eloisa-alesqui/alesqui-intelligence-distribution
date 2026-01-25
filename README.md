# 🚀 Alesqui Intelligence - Docker Distribution

**Deploy Alesqui Intelligence on your own servers with a single command.**

This repository contains everything you need to deploy the complete Alesqui Intelligence stack using Docker:
- ✅ React Frontend (Nginx)
- ✅ Java Spring Boot Backend
- ✅ MongoDB Database (Local or Atlas)
- ✅ Complete orchestration with Docker Compose

---

## 📋 Quick Start

### Prerequisites
- Docker 20.10+ and Docker Compose 2.0+
- OpenAI API key
- MongoDB (choose local or Atlas)
- 4GB RAM minimum
- 10GB disk space

### Installation (3 steps)

1. **Clone this repository**
   ```bash
   git clone https://github.com/eloisa-alesqui/alesqui-intelligence-distribution.git
   cd alesqui-intelligence-distribution
   ```

2. **Configure environment**
   ```bash
   cp .env.example .env
   nano .env  # Edit with your values
   ```

3. **Start the application**
   
   **For local MongoDB:**
   ```bash
   docker-compose --profile local-db up -d
   ```
   
   **For MongoDB Atlas:**
   ```bash
   docker-compose up -d
   ```

4. **Access the application**
   - Frontend: http://localhost
   - Backend API: http://localhost:8080
   - Health Check: http://localhost:8080/actuator/health

---

## 📚 Documentation

- **[Installation Guide](INSTALLATION.md)** - Complete setup instructions
- **[Troubleshooting](TROUBLESHOOTING.md)** - Common issues and solutions
- **[Architecture](docs/ARCHITECTURE.md)** - System architecture overview

---

## 🗄️ MongoDB Options

### Option A: Local MongoDB (Docker Container)
✅ Best for: Testing, development, self-hosted production  
✅ Complete control, no external dependencies

```bash
docker-compose --profile local-db up -d
```

### Option B: MongoDB Atlas (Cloud)
✅ Best for: Production deployments  
✅ Managed service, automatic backups, scaling

1. Create Atlas cluster at https://cloud.mongodb.com
2. Get connection string
3. Update `MONGODB_URI` in `.env`
4. Start without local database:
   ```bash
   docker-compose up -d
   ```

---

## 🔧 Useful Commands

### View logs
```bash
docker-compose logs -f
docker-compose logs -f backend
docker-compose logs -f frontend
```

### Stop services
```bash
docker-compose down
```

### Restart a service
```bash
docker-compose restart backend
```

### Update to new version
```bash
docker-compose down
docker-compose pull
docker-compose up -d
```

### Backup database (local MongoDB)
```bash
docker exec alesqui-mongodb mongodump \
  --username admin \
  --password YOUR_PASSWORD \
  --authenticationDatabase admin \
  --out /backup
docker cp alesqui-mongodb:/backup ./mongodb-backup-$(date +%Y%m%d)
```

---

## 🌐 Production Deployment

### Custom Ports
Edit `.env`:
```bash
FRONTEND_PORT=3000
BACKEND_PORT=9090
```

### HTTPS Setup
Use a reverse proxy (Nginx, Traefik, Caddy) in front of the application.

Example Nginx configuration:
```nginx
server {
    listen 443 ssl http2;
    server_name intelligence.yourcompany.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /api {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
    }
}
```

---

## 🔒 Security Checklist

- [ ] Change default MongoDB password
- [ ] Generate strong JWT_SECRET
- [ ] Use HTTPS in production
- [ ] Restrict MongoDB ports (don't expose 27017 publicly)
- [ ] Enable firewall rules
- [ ] Regular security updates: `docker-compose pull`
- [ ] Set up automated backups

---

## 📞 Support

- **Documentation:** https://docs.alesqui.com
- **Email:** support@alesqui.com
- **Issues:** https://github.com/eloisa-alesqui/alesqui-intelligence-distribution/issues

---

## 📄 License

This software is the property of Alesqui Intelligence.  
All rights reserved.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│           Docker Network                    │
│                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │ MongoDB  │←→│ Backend  │←→│ Frontend │ │
│  │  :27017  │  │  :8080   │  │   :80    │ │
│  └──────────┘  └──────────┘  └──────────┘ │
│      ↓              ↓              ↓       │
└─────────────────────────────────────────────┘
          ↓              ↓              ↓
    localhost:27017  localhost:8080  localhost:80
```

---

## 🎯 Components

- **Frontend:** React + TypeScript + Vite + Nginx
- **Backend:** Java 21 + Spring Boot 3 + WebFlux
- **Database:** MongoDB 7
- **AI:** OpenAI GPT-4
- **Authentication:** JWT
- **Containerization:** Docker + Docker Compose
