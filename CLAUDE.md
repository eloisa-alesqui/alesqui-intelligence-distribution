# Distribution — Guía para Claude

## Propósito

Paquete de distribución Docker listo para producción. Permite desplegar la plataforma completa (backend + frontend + MongoDB) con un solo script de instalación, abstrayendo toda la complejidad de Docker para usuarios sin experiencia técnica profunda.

---

## Stack / Herramientas

| Componente | Tecnología |
|-----------|-----------|
| Orquestación | Docker Compose 2.0+ |
| Automatización | Bash scripts |
| CI/CD | GitHub Actions (empaquetado y release) |
| Imágenes Docker | `alesquiintelligence/backend:latest`, `alesquiintelligence/frontend:latest` |
| Base de datos | MongoDB 7.0 (container local) o MongoDB Atlas (cloud) |
| Plataformas | Linux, macOS, Windows (WSL) |

**No es un proyecto Node.js ni Java.** No tiene `package.json` ni `pom.xml`.

---

## Estructura de Directorios

```
alesqui-intelligence-distribution/
├── local/                          # Despliegue con MongoDB local
│   ├── docker-compose.yml          # Incluye servicio mongo:7.0.15
│   ├── .env.example                # Template de variables de entorno
│   └── README.md
├── atlas/                          # Despliegue con MongoDB Atlas (cloud)
│   ├── docker-compose.yml          # Sin servicio MongoDB
│   ├── .env.example                # Template con MONGODB_ATLAS_URI
│   └── README.md
├── scripts/
│   ├── install.sh                  # Instalador principal (wizard interactivo)
│   ├── manage.sh                   # Gestión post-instalación (root)
│   ├── quick-install.sh            # Instalación rápida
│   ├── test-install.sh             # Test de instalación
│   ├── backup.sh                   # Backup de MongoDB
│   ├── generate-secrets.sh         # Generación de secretos JWT
│   ├── health-check.sh             # Verificación de salud de servicios
│   ├── package.sh                  # Empaquetado manual de release
│   ├── start-local.sh              # Arranque local
│   ├── start-atlas.sh              # Arranque Atlas
│   ├── stop.sh                     # Parada de servicios
│   ├── update.sh                   # Actualización de imágenes Docker
│   └── uninstall.sh                # Desinstalación completa
├── .github/workflows/
│   └── release.yml                 # GitHub Actions: empaqueta y publica release
├── .env.example                    # Template genérico raíz
├── README.md                       # Guía principal
├── CONFIGURATION.md                # Referencia completa de configuración
├── INSTALLATION.md                 # Instalación paso a paso manual
├── INSTALLATION_SCRIPTS.md         # Documentación de scripts
├── TROUBLESHOOTING.md              # Problemas comunes y soluciones
└── RELEASING.md                    # Proceso de release
```

---

## Modos de Despliegue

### Local (MongoDB en Docker)
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

### Atlas (MongoDB en la nube)
```yaml
# atlas/docker-compose.yml
services:
  backend:    # Sin servicio mongodb
  frontend:

networks:
  alesqui-network: bridge
```

---

## Variables de Entorno

### Seguridad (críticas)
```bash
JWT_SECRET=<mínimo 32 caracteres aleatorios>
JWT_EXPIRATION=900000          # 15 minutos en ms
JWT_REFRESH_EXPIRATION=604800000  # 7 días en ms
```

### Base de datos
```bash
# Modo local
MONGODB_URI=mongodb://admin:password@mongodb:27017/alesqui_intelligence?authSource=admin
MONGODB_USERNAME=admin
MONGODB_PASSWORD=<password>
MONGODB_DATABASE=alesqui_intelligence

# Modo Atlas
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/dbname?retryWrites=true&w=majority
```

### IA y aplicación
```bash
OPENAI_API_KEY=sk-proj-...
DEPLOYMENT_MODE=CORPORATE       # o TRIAL
COMPANY_NAME=Mi Empresa
FRONTEND_URL=http://localhost   # Para CORS
```

### Email (SMTP)
```bash
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=...
MAIL_FROM_EMAIL=noreply@empresa.com
MAIL_FROM_NAME=Alesqui Intelligence
```

### Admin inicial
```bash
INITIAL_ADMIN_EMAIL=admin@empresa.com
INITIAL_ADMIN_PASSWORD=  # Si vacío, se genera automáticamente
```

### Retención y Docker
```bash
AUDIT_RETENTION_DAYS=730
TRIAL_DURATION_DAYS=14
BACKEND_IMAGE=alesquiintelligence/backend
FRONTEND_IMAGE=alesquiintelligence/frontend
BACKEND_VERSION=latest
FRONTEND_VERSION=latest
```

---

## Scripts Principales

### Instalación

```bash
# Método 1: instalador interactivo
./scripts/install.sh
# → Asistente paso a paso: elige local/atlas, configura .env, arranca servicios

# Método 2: curl pipe (instalación remota)
curl -fsSL https://releases.../install.sh | bash

# Método 3: arranque directo
./scripts/start-local.sh    # MongoDB local
./scripts/start-atlas.sh    # MongoDB Atlas
```

### Gestión post-instalación (manage.sh)

```bash
./manage.sh start     # Arrancar servicios
./manage.sh stop      # Parar servicios
./manage.sh restart   # Reiniciar
./manage.sh status    # Ver estado de containers
./manage.sh logs      # Ver logs en tiempo real
./manage.sh backup    # Hacer backup de MongoDB
./manage.sh update    # Actualizar a nuevas imágenes Docker
```

El script `manage.sh` lee `.install-info` para saber si fue instalado como local o atlas.

---

## Health Checks (docker-compose)

| Servicio | Health Check | Intervalo | Inicio |
|---------|-------------|---------|--------|
| MongoDB | `mongosh --eval "db.adminCommand('ping')"` | 10s | - |
| Backend | `curl /actuator/health` | 30s | 60s |
| Frontend | `curl /health` | 30s | - |

Dependencias: frontend → backend → mongodb

---

## Proceso de Release

### Automático (GitHub Actions)
```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
# → GitHub Actions empaqueta y crea GitHub Release automáticamente
```

### Manual (emergencias)
```bash
./scripts/package.sh v1.0.0
```

### Artefactos de Release
- `alesqui-intelligence-v1.0.0.tar.gz` — paquete versionado
- `alesqui-intelligence.tar.gz` — latest
- `checksums.txt` — SHA256 para verificación

### Contenido del paquete (excluye .git, .env, node_modules)
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

## Networking Docker

```
Puerto 80   → frontend (Nginx)
Puerto 8080 → backend (Spring Boot) — solo interno en producción
Puerto 27017 → MongoDB — SOLO modo local, no exponer en producción
```

Red interna: `alesqui-network` (bridge). Los servicios se comunican por nombre DNS:
- Frontend → `http://backend:8080`
- Backend → `mongodb://mongodb:27017`

---

## Convenciones

- **Un `.env` por modo**: usar `local/.env` o `atlas/.env`, nunca el `.env.example` raíz directamente.
- **Nunca commitear `.env`**: el `.gitignore` los excluye. Solo commitear `.env.example`.
- **Secretos**: usar `generate-secrets.sh` para generar `JWT_SECRET` seguro.
- **Versionado de imágenes**: en producción usar tags explícitos (`v1.0.0`) en lugar de `latest`.
- **Documentación**: toda la documentación del usuario final va en los `.md` de la raíz, no en scripts.
- **Scripts POSIX**: los scripts bash deben ser compatibles con Linux, macOS y Windows WSL.

---

## Archivos de Documentación

| Archivo | Audiencia | Contenido |
|---------|----------|-----------|
| `README.md` | Todos | Quick start, comparativa local vs atlas, comandos comunes |
| `CONFIGURATION.md` | Admins | Referencia completa de variables, SMTP providers, audit |
| `INSTALLATION.md` | Técnicos | Instalación manual paso a paso |
| `INSTALLATION_SCRIPTS.md` | Técnicos | Documentación de cada script |
| `TROUBLESHOOTING.md` | Soporte | Problemas comunes y diagnóstico |
| `RELEASING.md` | Mantenedores | Proceso de release y versionado semántico |
