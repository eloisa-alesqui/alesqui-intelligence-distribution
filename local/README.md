# 🚀 Alesqui Intelligence - Local Deployment

Deploy Alesqui Intelligence with a self-hosted MongoDB container running locally in Docker.

## 🚀 Quick Start

**Easiest method - Automated installer:**

```bash
curl -fsSL https://raw.githubusercontent.com/eloisa-alesqui/alesqui-intelligence-distribution/main/install.sh | bash
# Select option [2] for Local deployment
```

The installer will guide you through:
- ✅ MongoDB password generation
- ✅ JWT secret generation
- ✅ OpenAI API key setup
- ✅ SMTP configuration (optional)
- ✅ Automated deployment

**Manual method:** Follow the [detailed instructions](#-installation-steps) below.

---

## 📋 Overview

This deployment option includes:
- ✅ **MongoDB 7.0** - Local database container with persistent storage
- ✅ **Backend API** - Java Spring Boot application (port 8080)
- ✅ **Frontend UI** - React application served by Nginx (port 80)

**Best for:** Development, testing, and self-hosted production environments where you want complete control over the database.

---

## 🔧 Prerequisites

Before starting, ensure you have:

### Required Software
- **Docker** 20.10 or later
- **Docker Compose** 2.0 or later

Check your versions:
```bash
docker --version
docker-compose --version
```

### Required Credentials
1. **OpenAI API Key** - Get from [OpenAI Platform](https://platform.openai.com/api-keys)
2. **SMTP Credentials** - For sending emails (Gmail, SendGrid, etc.)

### System Requirements
- **RAM:** 4GB minimum, 8GB recommended
- **Disk:** 10GB minimum for application and database
- **CPU:** 2 cores minimum
- **Ports:** 80, 8080, and 27017 must be available

---

## 📥 Installation Steps

### Step 1: Navigate to Local Directory

```bash
cd local/
```

### Step 2: Create Environment File

```bash
cp .env.example .env
```

### Step 3: Generate Secure Credentials

Generate a secure JWT secret and MongoDB password:

```bash
# Generate JWT secret (32+ characters)
openssl rand -base64 32

# Generate MongoDB password
openssl rand -base64 32
```

Or use the convenience script from the root directory:
```bash
../scripts/generate-secrets.sh
```

### Step 4: Configure Environment Variables

Edit the `.env` file with your preferred editor:

```bash
nano .env
```

**Required Changes:**

1. **MongoDB Password** (line 27)
   ```bash
   MONGODB_PASSWORD=your_generated_secure_password
   ```

2. **JWT Secret** (line 37)
   ```bash
   JWT_SECRET=your_generated_jwt_secret_at_least_32_chars
   ```

3. **OpenAI API Key** (line 51)
   ```bash
   OPENAI_API_KEY=sk-proj-your-actual-openai-key
   ```

4. **SMTP Configuration** (lines 81-96)
   ```bash
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USER=your-email@gmail.com
   SMTP_PASSWORD=your-app-specific-password
   MAIL_FROM_EMAIL=noreply@yourdomain.com
   MAIL_FROM_NAME=Alesqui Intelligence
   ```

**Optional Changes:**
- `COMPANY_NAME` - Your company name
- `FRONTEND_URL` - Change if using a custom domain
- `AUDIT_RETENTION_DAYS` - Adjust audit log retention period

### Step 5: Start the Services

```bash
docker-compose up -d
```

This will:
1. Pull the required Docker images
2. Start MongoDB with health checks
3. Start the backend (waits for MongoDB to be healthy)
4. Start the frontend (waits for backend to be healthy)

### Step 6: Verify Deployment

Wait for all services to become healthy (2-3 minutes):

```bash
docker-compose ps
```

All services should show "healthy" status.

Check service health:

```bash
# Check backend health
curl http://localhost:8080/actuator/health

# Check frontend (should return the HTML page)
curl http://localhost
```

---

## 🌐 Accessing the Application

Once all services are healthy:

- **Frontend:** http://localhost
- **Backend API:** http://localhost:8080
- **API Health Check:** http://localhost:8080/actuator/health
- **MongoDB:** localhost:27017 (accessible from host)

**Default Admin Login:**
Follow the setup wizard on first launch to create your admin account.

---

## 🔐 Initial Admin User

On first startup, if no users exist in the database, an admin account will be created automatically. This makes it easy to get started without manual user creation.

### Default Credentials

By default, the admin user is created with:
- **Email:** `admin@company.com`
- **Password:** Auto-generated (shown in logs)

### Viewing the Generated Password

To see the auto-generated password, check the backend logs:

```bash
docker-compose logs backend | grep InitialAdmin
```

You'll see output like:

```
[InitialAdmin] ========================================
[InitialAdmin] INITIAL ADMIN USER CREATED SUCCESSFULLY
[InitialAdmin] ========================================
[InitialAdmin] 
[InitialAdmin] Login Credentials:
[InitialAdmin]   Email:    admin@company.com
[InitialAdmin]   Password: aB3!xK9mP2wQ7nL5
[InitialAdmin] 
[InitialAdmin] ⚠️  Password was auto-generated
[InitialAdmin] 🔒 IMPORTANT: Change this password after first login!
[InitialAdmin] 
[InitialAdmin] Access the application at: http://localhost
[InitialAdmin] ========================================
```

### Customizing Admin Credentials

You can customize the initial admin credentials in your `.env` file:

```bash
# Custom admin email
INITIAL_ADMIN_EMAIL=admin@mycompany.com

# Custom admin password (optional, leave commented to auto-generate)
INITIAL_ADMIN_PASSWORD=MySecurePassword123!
```

**Security Best Practices:**
- ✅ Use the auto-generated password (more secure)
- ✅ Change the password immediately after first login
- ✅ Use a strong, unique password if setting manually
- ❌ Don't commit the password to version control

---

## 📊 Managing Services

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mongodb
```

### Stop Services

```bash
docker-compose down
```

To also remove volumes (⚠️ deletes all data):
```bash
docker-compose down -v
```

### Restart a Service

```bash
docker-compose restart backend
```

### Update to Latest Version

```bash
# Pull latest images
docker-compose pull

# Restart with new images
docker-compose up -d
```

Or use the convenience script:
```bash
../scripts/update.sh
```

---

## 🗄️ Database Management

### Access MongoDB Shell

```bash
docker exec -it alesqui-mongodb mongosh -u admin -p
```

Then enter your `MONGODB_PASSWORD` when prompted.

### Backup Database

```bash
# Create backup
docker exec alesqui-mongodb mongodump \
  --username admin \
  --password YOUR_PASSWORD \
  --authenticationDatabase admin \
  --db alesqui_intelligence \
  --out /tmp/backup

# Copy backup to host
docker cp alesqui-mongodb:/tmp/backup ./mongodb-backup-$(date +%Y%m%d)
```

### Restore Database

```bash
# Copy backup to container
docker cp ./mongodb-backup-YYYYMMDD alesqui-mongodb:/tmp/restore

# Restore database
docker exec alesqui-mongodb mongorestore \
  --username admin \
  --password YOUR_PASSWORD \
  --authenticationDatabase admin \
  --db alesqui_intelligence \
  /tmp/restore/alesqui_intelligence
```

### Database Persistence

MongoDB data is stored in Docker volumes:
- `mongodb_data` - Database files
- `mongodb_config` - Configuration files

These volumes persist even when containers are stopped or removed (unless you use `docker-compose down -v`).

---

## 🔧 Configuration Details

### MongoDB Configuration

- **Version:** MongoDB 7.0
- **Port:** 27017 (exposed to host)
- **Authentication:** Username/password (defined in .env)
- **Database Name:** alesqui_intelligence (configurable)
- **Connection String:** `mongodb://admin:password@mongodb:27017/alesqui_intelligence?authSource=admin`

### Backend Configuration

- **Port:** 8080
- **Health Endpoint:** /actuator/health
- **JWT Expiration:** 15 minutes (access token), 7 days (refresh token)
- **CORS:** Configured via FRONTEND_URL and CORS_ADDITIONAL_ORIGINS

### Frontend Configuration

- **Port:** 80
- **API URL:** http://localhost:8080
- **Web Server:** Nginx

---

## 🚨 Troubleshooting

### Services Won't Start

**Problem:** Container exits immediately or shows unhealthy status.

**Solutions:**

1. Check logs for errors:
   ```bash
   docker-compose logs backend
   ```

2. Verify .env file exists and has correct values:
   ```bash
   cat .env | grep -v "^#" | grep -v "^$"
   ```

3. Ensure ports aren't already in use:
   ```bash
   netstat -tuln | grep -E ':(80|8080|27017)'
   ```

### Backend Can't Connect to MongoDB

**Problem:** Backend logs show "Connection refused" or "Authentication failed".

**Solutions:**

1. Verify MongoDB is healthy:
   ```bash
   docker-compose ps mongodb
   ```

2. Check MongoDB password matches in .env:
   ```bash
   grep MONGODB_PASSWORD .env
   ```

3. Test MongoDB connection:
   ```bash
   docker exec alesqui-mongodb mongosh \
     --username admin \
     --password YOUR_PASSWORD \
     --authenticationDatabase admin \
     --eval "db.adminCommand('ping')"
   ```

### Frontend Can't Reach Backend

**Problem:** Frontend loads but API calls fail.

**Solutions:**

1. Verify backend is healthy:
   ```bash
   curl http://localhost:8080/actuator/health
   ```

2. Check browser console for CORS errors

3. Verify FRONTEND_URL in .env matches where you're accessing from:
   ```bash
   grep FRONTEND_URL .env
   ```

### Port Already in Use

**Problem:** Error: "port is already allocated".

**Solutions:**

1. Find process using the port:
   ```bash
   lsof -i :80
   lsof -i :8080
   ```

2. Stop conflicting service or change ports in .env

### Out of Disk Space

**Problem:** Docker fails with disk space errors.

**Solutions:**

1. Check disk usage:
   ```bash
   docker system df
   ```

2. Clean up unused images and containers:
   ```bash
   docker system prune -a
   ```

3. Clean up old volumes (⚠️ careful with data):
   ```bash
   docker volume ls
   docker volume rm <unused-volumes>
   ```

### Email Not Sending

**Problem:** Users don't receive emails.

**Solutions:**

1. Check SMTP configuration in .env

2. For Gmail, use [App Passwords](https://support.google.com/accounts/answer/185833)

3. Test SMTP connection:
   ```bash
   docker-compose logs backend | grep -i smtp
   ```

---

## 🔒 Security Best Practices

### Production Deployment

When deploying to production:

1. **Change all default passwords** in .env
2. **Use strong JWT secret** (minimum 32 characters)
3. **Enable HTTPS** using a reverse proxy (Nginx, Traefik, Caddy)
4. **Restrict MongoDB port** - Don't expose 27017 externally
5. **Set up firewall rules** - Only allow necessary ports
6. **Regular backups** - Automate database backups
7. **Update regularly** - Keep Docker images up to date
8. **Use production SMTP** - Not personal email accounts
9. **Monitor logs** - Set up log aggregation and alerts
10. **SSL/TLS for MongoDB** - Consider enabling encryption

### Firewall Configuration

Example using UFW (Ubuntu):

```bash
# Allow SSH
sudo ufw allow 22

# Allow HTTP/HTTPS
sudo ufw allow 80
sudo ufw allow 443

# Block MongoDB from external access
sudo ufw deny 27017

# Enable firewall
sudo ufw enable
```

---

## 📈 Performance Tuning

### Increase Java Heap Memory

Edit .env:
```bash
JAVA_OPTS=-XX:+UseContainerSupport -XX:MaxRAMPercentage=80.0 -Xms2g -Xmx4g
```

### MongoDB Performance

For production workloads:

1. Enable MongoDB indexes (already configured via `MONGODB_AUTO_INDEX=true`)
2. Consider increasing MongoDB memory with WiredTiger cache
3. Monitor with MongoDB Compass or mongostat

### Docker Resource Limits

Add to docker-compose.yml if needed:
```yaml
backend:
  deploy:
    resources:
      limits:
        memory: 2G
        cpus: '2.0'
```

---

## 🔄 Backup Strategy

### Automated Daily Backups

Create a cron job:

```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /path/to/backup-script.sh
```

Backup script example:
```bash
#!/bin/bash
BACKUP_DIR="/backups/mongodb"
DATE=$(date +%Y%m%d_%H%M%S)

docker exec alesqui-mongodb mongodump \
  --username admin \
  --password $MONGODB_PASSWORD \
  --authenticationDatabase admin \
  --db alesqui_intelligence \
  --out /tmp/backup

docker cp alesqui-mongodb:/tmp/backup "$BACKUP_DIR/backup-$DATE"

# Keep only last 7 days
find "$BACKUP_DIR" -name "backup-*" -mtime +7 -delete
```

---

## 📞 Getting Help

- **Documentation:** [Main README](../README.md)
- **Troubleshooting:** [Troubleshooting Guide](../TROUBLESHOOTING.md)
- **GitHub Issues:** [Report an issue](https://github.com/eloisa-alesqui/alesqui-intelligence-distribution/issues)
- **Email Support:** support@alesqui.com

---

## 📝 Next Steps

After successful deployment:

1. **Create admin account** - Follow setup wizard
2. **Configure users** - Add team members
3. **Test AI features** - Verify OpenAI integration
4. **Set up backups** - Implement backup strategy
5. **Monitor logs** - Check for any errors or warnings
6. **Plan for production** - Consider moving to Atlas for better scalability

---

## 🔄 Migrating to Atlas

If you want to migrate from local MongoDB to Atlas later:

1. Export your data:
   ```bash
   docker exec alesqui-mongodb mongodump --username admin --password $PASSWORD --authenticationDatabase admin --db alesqui_intelligence --out /tmp/export
   docker cp alesqui-mongodb:/tmp/export ./mongodb-export
   ```

2. Set up MongoDB Atlas cluster

3. Import your data to Atlas:
   ```bash
   mongorestore --uri "mongodb+srv://user:pass@cluster.mongodb.net" --db alesqui_intelligence ./mongodb-export/alesqui_intelligence
   ```

4. Switch to [Atlas deployment](../atlas/README.md)
