# Distribution — Guide for Claude

## Purpose

Production-ready Docker distribution package. Deploys the full platform (backend + frontend + MongoDB) with a single installation script, abstracting all Docker complexity for users without deep technical expertise.

---

## Stack / Tools

| Component | Technology |
|-----------|-----------|
| Orchestration | Docker Compose 2.0+ |
| Automation | Bash scripts |
| CI/CD | GitHub Actions (packaging and release) |
| Docker images | `alesquiintelligence/backend:latest`, `alesquiintelligence/frontend:latest` |
| Database | MongoDB 7.0 (local container) or MongoDB Atlas (cloud) |
| Platforms | Linux, macOS, Windows (WSL) |

**This is not a Node.js or Java project.** It has no `package.json` or `pom.xml`.

---

## Directory Structure

```
alesqui-intelligence-distribution/
├── local/                          # Local MongoDB deployment
│   ├── docker-compose.yml          # Includes mongo:7.0.15 service
│   ├── .env.example                # Environment variable template
│   └── README.md
├── atlas/                          # MongoDB Atlas (cloud) deployment
│   ├── docker-compose.yml          # No MongoDB service
│   ├── .env.example                # Template with MONGODB_ATLAS_URI
│   └── README.md
├── scripts/
│   ├── install.sh                  # Main installer (interactive wizard)
│   ├── manage.sh                   # Post-install management (root)
│   ├── quick-install.sh            # Quick installation
│   ├── test-install.sh             # Installation test
│   ├── backup.sh                   # MongoDB backup
│   ├── generate-secrets.sh         # JWT secret generation
│   ├── health-check.sh             # Service health verification
│   ├── package.sh                  # Manual release packaging
│   ├── start-local.sh              # Start local deployment
│   ├── start-atlas.sh              # Start Atlas deployment
│   ├── stop.sh                     # Stop services
│   ├── update.sh                   # Update Docker images
│   └── uninstall.sh                # Complete uninstall
├── .github/workflows/
│   └── release.yml                 # GitHub Actions: package and publish release
├── .env.example                    # Generic root template
├── README.md                       # Main guide
├── CONFIGURATION.md                # Full configuration reference
├── INSTALLATION.md                 # Manual step-by-step installation
├── INSTALLATION_SCRIPTS.md         # Script documentation
├── TROUBLESHOOTING.md              # Common issues and solutions
└── RELEASING.md                    # Release process
```

---

## Deployment Modes

### Local (MongoDB in Docker)
```yaml
# local/docker-compose.yml
services:
  mongodb:    # mongo:7.0.15
  backend:    # alesquiintelligence/backend:latest
  frontend:   # alesquiintelligence/frontend:latest

networks:
  alesqui-network: bridge

volumes:
  mongodb_data:
  mongodb_config:
```

### Atlas (MongoDB in the cloud)
```yaml
# atlas/docker-compose.yml
services:
  backend:    # No mongodb service
  frontend:

networks:
  alesqui-network: bridge
```

---

## Environment Variables

### Security (critical)
```bash
JWT_SECRET=<minimum 32 random characters>
JWT_EXPIRATION=900000          # 15 minutes in ms
JWT_REFRESH_EXPIRATION=604800000  # 7 days in ms
```

### Database
```bash
# Local mode
MONGODB_URI=mongodb://admin:password@mongodb:27017/alesqui_intelligence?authSource=admin
MONGODB_USERNAME=admin
MONGODB_PASSWORD=<password>
MONGODB_DATABASE=alesqui_intelligence

# Atlas mode
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/dbname?retryWrites=true&w=majority
```

### AI and application
```bash
OPENAI_API_KEY=sk-proj-...
DEPLOYMENT_MODE=CORPORATE       # or TRIAL
COMPANY_NAME=My Company
FRONTEND_URL=http://localhost   # For CORS
```

### Email (SMTP)
```bash
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=...
MAIL_FROM_EMAIL=noreply@company.com
MAIL_FROM_NAME=Alesqui Intelligence
```

### Initial admin
```bash
INITIAL_ADMIN_EMAIL=admin@company.com
INITIAL_ADMIN_PASSWORD=  # If empty, auto-generated
```

### Retention and Docker
```bash
AUDIT_RETENTION_DAYS=730
TRIAL_DURATION_DAYS=14
BACKEND_IMAGE=alesquiintelligence/backend
FRONTEND_IMAGE=alesquiintelligence/frontend
BACKEND_VERSION=latest
FRONTEND_VERSION=latest
```

---

## Main Scripts

### Installation

```bash
# Method 1: interactive installer
./scripts/install.sh
# → Step-by-step wizard: choose local/atlas, configure .env, start services

# Method 2: curl pipe (remote installation)
curl -fsSL https://releases.../install.sh | bash

# Method 3: direct start
./scripts/start-local.sh    # Local MongoDB
./scripts/start-atlas.sh    # MongoDB Atlas
```

### Post-install management (manage.sh)

```bash
./manage.sh start     # Start services
./manage.sh stop      # Stop services
./manage.sh restart   # Restart
./manage.sh status    # View container status
./manage.sh logs      # View real-time logs
./manage.sh backup    # Back up MongoDB
./manage.sh update    # Update to new Docker images
```

`manage.sh` reads `.install-info` to know whether it was installed as local or atlas.

---

## Health Checks (docker-compose)

| Service | Health Check | Interval | Start period |
|---------|-------------|----------|--------------|
| MongoDB | `mongosh --eval "db.adminCommand('ping')"` | 10s | - |
| Backend | `curl /actuator/health` | 30s | 60s |
| Frontend | `curl /health` | 30s | - |

Dependencies: frontend → backend → mongodb

---

## Release Process

### Automatic (GitHub Actions)
```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
# → GitHub Actions packages and creates GitHub Release automatically
```

### Manual (emergencies)
```bash
./scripts/package.sh v1.0.0
```

### Release Artifacts
- `alesqui-intelligence-v1.0.0.tar.gz` — versioned package
- `alesqui-intelligence.tar.gz` — latest
- `checksums.txt` — SHA256 for verification

### Package contents (excludes .git, .env, node_modules)
```
atlas/
local/
scripts/
manage.sh
install.sh
README.md
INSTALLATION.md
CONFIGURATION.md
```

---

## Docker Networking

```
Port 80   → frontend (Nginx)
Port 8080 → backend (Spring Boot) — internal only in production
Port 27017 → MongoDB — local mode ONLY, do not expose in production
```

Internal network: `alesqui-network` (bridge). Services communicate by DNS name:
- Frontend → `http://backend:8080`
- Backend → `mongodb://mongodb:27017`

---

## Conventions

- **One `.env` per mode**: use `local/.env` or `atlas/.env`, never the root `.env.example` directly.
- **Never commit `.env`**: `.gitignore` excludes them. Only commit `.env.example`.
- **Secrets**: use `generate-secrets.sh` to generate a secure `JWT_SECRET`.
- **Image versioning**: in production use explicit tags (`v1.0.0`) instead of `latest`.
- **Documentation**: all end-user documentation goes in the root `.md` files, not inside scripts.
- **POSIX scripts**: bash scripts must be compatible with Linux, macOS, and Windows WSL.

---

## Documentation Files

| File | Audience | Content |
|------|----------|---------|
| `README.md` | Everyone | Quick start, local vs atlas comparison, common commands |
| `CONFIGURATION.md` | Admins | Full variable reference, SMTP providers, audit |
| `INSTALLATION.md` | Technical | Manual step-by-step installation |
| `INSTALLATION_SCRIPTS.md` | Technical | Documentation for each script |
| `TROUBLESHOOTING.md` | Support | Common issues and diagnostics |
| `RELEASING.md` | Maintainers | Release process and semantic versioning |
