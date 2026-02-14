# Configuration Guide

This guide explains how to configure Alesqui Intelligence for deployment. The application requires several environment variables to be set in a `.env` file.

## 📋 Overview

Alesqui Intelligence consists of three main components:
- **Backend API** - Java Spring Boot application that handles business logic and API requests
- **Frontend UI** - React + TypeScript application for the user interface
- **Database** - MongoDB (either self-hosted or MongoDB Atlas)

All components are deployed using Docker and Docker Compose, with configuration managed through environment variables.

---

## 🔧 Configuration File Location

The `.env` file should be created in the appropriate directory based on your deployment type:

- **Atlas Deployment**: `atlas/.env` (MongoDB Atlas cloud database)
- **Local Deployment**: `local/.env` (Self-hosted MongoDB in Docker)

Copy the corresponding `.env.example` file to `.env` and update the values according to your environment.

---

## 🔐 Required Configuration

### 1. Security - JWT Configuration

JSON Web Tokens (JWT) are used for authentication and session management.

```bash
# Secret key for signing JWT tokens
# MUST be at least 256 bits (32 characters) for security
# Generate using: openssl rand -base64 32
JWT_SECRET=your-very-secure-jwt-secret-change-in-production

# Access token expiration in milliseconds
# Default: 900000 (15 minutes)
# Recommended for production: 900000 - 1800000 (15-30 minutes)
JWT_EXPIRATION=900000

# Refresh token expiration in milliseconds
# Default: 604800000 (7 days)
# Recommended for production: 604800000 - 2592000000 (7-30 days)
JWT_REFRESH_EXPIRATION=604800000
```

**Security Best Practices:**
- ✅ Generate a strong, random secret: `openssl rand -base64 32`
- ✅ Use different secrets for development, staging, and production
- ✅ Never commit JWT secrets to version control
- ✅ Rotate JWT secrets periodically in production

### 2. AI Configuration - OpenAI

The application uses OpenAI's GPT models for AI-powered features.

```bash
# OpenAI API Key
# Get your key from https://platform.openai.com/api-keys
OPENAI_API_KEY=sk-proj-...
```

**How to obtain your OpenAI API Key:**
1. Go to [OpenAI Platform](https://platform.openai.com/api-keys)
2. Sign in or create an account
3. Navigate to API Keys section
4. Click "Create new secret key"
5. Copy the key (you won't be able to see it again)
6. Set usage limits and restrictions as needed

### 3. Database Configuration

Configuration differs based on your deployment type.

#### Option A: MongoDB Atlas (Cloud-Managed)

For production deployments using MongoDB Atlas:

```bash
# MongoDB Atlas connection string
# Format: mongodb+srv://username:password@cluster.mongodb.net/dbname?retryWrites=true&w=majority
MONGODB_ATLAS_URI=mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/alesqui_intelligence?retryWrites=true&w=majority

# Database name (should match the database in your connection string)
MONGODB_DATABASE=alesqui_intelligence
```

**Important Notes for Atlas:**
- Use `mongodb+srv://` protocol (not `mongodb://`)
- URL-encode special characters in passwords:
  - `@` → `%40`
  - `#` → `%23`
  - `%` → `%25`
  - `/` → `%2F`
- Whitelist your server IP in Atlas Network Access settings
- For development, you can temporarily use `0.0.0.0/0` (not recommended for production)

**Getting your Atlas connection string:**
1. Log in to [MongoDB Atlas](https://cloud.mongodb.com)
2. Click "Connect" on your cluster
3. Choose "Connect your application"
4. Select "Driver: Java" and "Version: 4.3 or later"
5. Copy the connection string and replace `<password>` with your actual password
6. Add your database name before the `?`: `.../alesqui_intelligence?retryWrites=...`

#### Option B: Local MongoDB (Self-Hosted)

For local development or self-hosted production:

```bash
# MongoDB connection details
MONGODB_URI=mongodb://mongodb:27017/alesqui_intelligence
MONGODB_DATABASE=alesqui_intelligence
MONGODB_USER=admin
MONGODB_PASSWORD=secure_password_here
MONGODB_AUTH_DB=admin
```

**Security Notes:**
- ✅ Generate a strong password: `openssl rand -base64 32`
- ✅ Never use default passwords in production
- ✅ Restrict MongoDB port (27017) to internal network only

### 4. Email Configuration (SMTP)

Email service is **required** for:
- User account activation
- Password reset functionality
- System notifications

```bash
# SMTP server configuration
SMTP_HOST=smtp.yourcompany.com
SMTP_PORT=587
SMTP_USER=user@yourcompany.com
SMTP_PASSWORD=smtp_password

# Email sender information
MAIL_FROM_EMAIL=noreply@yourcompany.com
MAIL_FROM_NAME=Alesqui Intelligence
```

**Common SMTP Providers:**

**SendGrid** (Recommended for production):
```bash
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=SG.your-sendgrid-api-key
```

**Gmail** (Development only):
```bash
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-specific-password
```
Note: For Gmail, you must use [App Passwords](https://support.google.com/accounts/answer/185833), not your regular password.

**Mailgun**:
```bash
SMTP_HOST=smtp.mailgun.org
SMTP_PORT=587
SMTP_USER=postmaster@yourdomain.mailgun.org
SMTP_PASSWORD=your-mailgun-smtp-password
```

**Amazon SES**:
```bash
SMTP_HOST=email-smtp.us-east-1.amazonaws.com
SMTP_PORT=587
SMTP_USER=your-ses-smtp-username
SMTP_PASSWORD=your-ses-smtp-password
```

---

## 🎛️ Optional Configuration

### Application Settings

```bash
# Company name displayed in the application
COMPANY_NAME=My Company

# Backend server port (internal Docker port)
PORT=8080
```

### Frontend Configuration

```bash
# URL where users will access the frontend
# For production, use your actual domain with HTTPS
# Examples:
#   - Production: https://intelligence.yourcompany.com
#   - Staging: https://intelligence-staging.yourcompany.com
#   - Development: http://localhost
FRONTEND_URL=https://intelligence.yourcompany.com

# API URL for frontend to connect to backend
# For production behind reverse proxy: https://intelligence.yourcompany.com/api
# For development: http://localhost:8080
VITE_API_URL=https://intelligence.yourcompany.com/api

# Additional CORS allowed origins (comma-separated, optional)
# Example: https://app.example.com,https://test.example.com
CORS_ADDITIONAL_ORIGINS=
```

### Audit Logging

```bash
# Number of days to retain audit logs before automatic deletion
# Default: 730 days (2 years)
# MongoDB TTL background task automatically removes expired logs every 60 seconds
# Minimum recommended: 90 days for compliance purposes
#
# Compliance recommendations:
# - SOC 2 / GDPR: 730 days (2 years)
# - HIPAA: 2190 days (6 years)
AUDIT_RETENTION_DAYS=730
```

### Initial Admin User

On first startup, an admin account is automatically created if no users exist in the database.

```bash
# Custom admin email (optional)
# Default: admin@company.com
INITIAL_ADMIN_EMAIL=admin@mycompany.com

# Custom admin password (optional)
# If commented out, a secure password will be auto-generated
# The auto-generated password will be shown in the backend logs
INITIAL_ADMIN_PASSWORD=MySecurePassword123!
```

**To view the auto-generated password:**
```bash
docker-compose logs backend | grep InitialAdmin
```

**Security Best Practices:**
- ✅ Use auto-generated passwords (more secure)
- ✅ Change the password immediately after first login
- ❌ Don't commit passwords to version control

### Corporate Proxy (Optional)

Only required if your organization uses a corporate proxy.

```bash
# Corporate proxy configuration (optional)
# PROXY_HOST=proxy.mycompany.com
# PROXY_PORT=8080
```

### Docker Image Versions

```bash
# Specify the version tags for Docker images
# Use 'latest' for the most recent version, or specify a version like 'v1.0.0'
BACKEND_VERSION=latest
FRONTEND_VERSION=latest
```

---

## 📝 Complete Configuration Example

### Atlas Deployment Example

```bash
# =============================================================================
# SECURITY
# =============================================================================
JWT_SECRET=P8x9mK2nQ5vW7zA3bC6eF4gH8jL1mN0pR2sT5uV8xY1zA3bC6eF9
JWT_EXPIRATION=900000
JWT_REFRESH_EXPIRATION=604800000

# =============================================================================
# DATABASE - MONGODB ATLAS
# =============================================================================
MONGODB_ATLAS_URI=mongodb+srv://alesqui_admin:MyP%40ss%23123@cluster0.abc123.mongodb.net/alesqui_intelligence?retryWrites=true&w=majority
MONGODB_DATABASE=alesqui_intelligence

# =============================================================================
# AI CONFIGURATION
# =============================================================================
OPENAI_API_KEY=sk-proj-abc123xyz789...

# =============================================================================
# APPLICATION
# =============================================================================
COMPANY_NAME=Acme Corporation
PORT=8080
FRONTEND_URL=https://intelligence.acme.com
VITE_API_URL=https://intelligence.acme.com/api

# =============================================================================
# EMAIL CONFIGURATION
# =============================================================================
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=SG.abc123xyz789...
MAIL_FROM_EMAIL=noreply@acme.com
MAIL_FROM_NAME=Acme Intelligence

# =============================================================================
# AUDIT LOGGING
# =============================================================================
AUDIT_RETENTION_DAYS=730

# =============================================================================
# INITIAL ADMIN USER
# =============================================================================
INITIAL_ADMIN_EMAIL=admin@acme.com
# INITIAL_ADMIN_PASSWORD=  # Leave commented for auto-generation

# =============================================================================
# DOCKER IMAGES
# =============================================================================
BACKEND_VERSION=latest
FRONTEND_VERSION=latest
```

### Local Deployment Example

```bash
# =============================================================================
# SECURITY
# =============================================================================
JWT_SECRET=P8x9mK2nQ5vW7zA3bC6eF4gH8jL1mN0pR2sT5uV8xY1zA3bC6eF9
JWT_EXPIRATION=900000
JWT_REFRESH_EXPIRATION=604800000

# =============================================================================
# DATABASE - LOCAL MONGODB
# =============================================================================
MONGODB_URI=mongodb://mongodb:27017/alesqui_intelligence
MONGODB_DATABASE=alesqui_intelligence
MONGODB_USER=admin
MONGODB_PASSWORD=uX2nM5pQ8sV1wZ4aC7eF0hJ3kL6mN9qR2tU5vX8yA1bD4eG7iK0
MONGODB_AUTH_DB=admin

# =============================================================================
# AI CONFIGURATION
# =============================================================================
OPENAI_API_KEY=sk-proj-abc123xyz789...

# =============================================================================
# APPLICATION
# =============================================================================
COMPANY_NAME=Acme Corporation
PORT=8080
FRONTEND_URL=http://localhost
VITE_API_URL=http://localhost:8080

# =============================================================================
# EMAIL CONFIGURATION
# =============================================================================
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=developer@acme.com
SMTP_PASSWORD=abcd-efgh-ijkl-mnop
MAIL_FROM_EMAIL=noreply@acme.com
MAIL_FROM_NAME=Acme Intelligence

# =============================================================================
# AUDIT LOGGING
# =============================================================================
AUDIT_RETENTION_DAYS=730

# =============================================================================
# INITIAL ADMIN USER
# =============================================================================
INITIAL_ADMIN_EMAIL=admin@acme.com
# INITIAL_ADMIN_PASSWORD=  # Leave commented for auto-generation

# =============================================================================
# DOCKER IMAGES
# =============================================================================
BACKEND_VERSION=latest
FRONTEND_VERSION=latest
```

---

## 🔒 Production Security Checklist

Before deploying to production, ensure you have:

- [ ] Generated strong JWT secret (minimum 32 characters)
- [ ] Created secure database password (if using local MongoDB)
- [ ] Configured production SMTP service (not Gmail)
- [ ] Set up HTTPS with valid SSL certificates
- [ ] Configured reverse proxy (Nginx, Traefik, or Caddy)
- [ ] Restricted MongoDB Atlas IP access (not 0.0.0.0/0)
- [ ] Set up firewall rules (allow only 80, 443; block 8080, 27017 externally)
- [ ] Enabled automated backups
- [ ] Configured proper FRONTEND_URL with HTTPS
- [ ] Set up monitoring and alerting
- [ ] Reviewed audit retention policy for compliance
- [ ] Changed default admin password after first login
- [ ] Documented configuration for your team

---

## 🔍 Troubleshooting Configuration Issues

### Backend Won't Start

**Check configuration:**
```bash
# Verify .env file exists
ls -la .env

# Check for syntax errors (no spaces around =)
cat .env | grep -v "^#" | grep -v "^$"
```

### Database Connection Errors

**MongoDB Atlas:**
```bash
# Verify connection string format
docker-compose config | grep MONGODB_ATLAS_URI

# Check IP whitelist in Atlas Network Access
curl ifconfig.me  # Get your server IP
```

**Local MongoDB:**
```bash
# Test MongoDB connection
docker exec alesqui-mongodb mongosh \
  --username admin \
  --password YOUR_PASSWORD \
  --authenticationDatabase admin \
  --eval "db.adminCommand('ping')"
```

### Email Not Sending

```bash
# Check backend logs for SMTP errors
docker-compose logs backend | grep -i smtp

# Verify SMTP credentials
grep SMTP_ .env
```

### JWT Authentication Errors

```bash
# Verify JWT secret is set and is at least 32 characters
grep JWT_SECRET .env | awk -F= '{print length($2)}'
```

---

## 📚 Related Documentation

- **[Installation Guide](README.md)** - Complete installation instructions
- **[Local Deployment Guide](local/README.md)** - Self-hosted MongoDB setup
- **[Atlas Deployment Guide](atlas/README.md)** - MongoDB Atlas setup
- **[Troubleshooting Guide](TROUBLESHOOTING.md)** - Common issues and solutions

---

## 📞 Support

If you encounter configuration issues:

- **GitHub Issues**: [Report an issue](https://github.com/eloisa-alesqui/alesqui-intelligence-distribution/issues)
- **Email**: support@alesqui.com
- **Documentation**: Full guides available in repository
