# 🆘 Troubleshooting Guide

Common issues and solutions for Alesqui Intelligence deployment.

---

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [Backend Issues](#backend-issues)
3. [Frontend Issues](#frontend-issues)
4. [MongoDB Issues](#mongodb-issues)
5. [Network Issues](#network-issues)
6. [Performance Issues](#performance-issues)
7. [Docker Issues](#docker-issues)
8. [Diagnostic Commands](#diagnostic-commands)

---

## Installation Issues

### Quick Installer Fails

**Problem:** The quick installer script fails or hangs.

**Solutions:**

1. **Check that you have all prerequisites:**
   ```bash
   docker --version        # Should be 20.10+
   docker compose version  # Should be 2.0+
   ```

2. **Download and run the installer manually:**
   ```bash
   curl -LO https://raw.githubusercontent.com/eloisa-alesqui/alesqui-intelligence-distribution/main/install.sh
   chmod +x install.sh
   ./install.sh
   ```

3. **Check installation logs:**
   ```bash
   cat /tmp/alesqui-install.log
   ```

4. **Verify network connectivity:**
   ```bash
   curl -I https://github.com
   ping google.com
   ```

5. **If Docker permission errors:**
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   # Or run installer with sudo
   sudo ./install.sh
   ```

### Cannot Download Installer

**Problem:** `curl` command fails with connection error.

**Solutions:**

1. **Check internet connection:**
   ```bash
   ping github.com
   curl -I https://github.com
   ```

2. **Try with wget instead:**
   ```bash
   wget https://raw.githubusercontent.com/eloisa-alesqui/alesqui-intelligence-distribution/main/install.sh
   chmod +x install.sh
   ./install.sh
   ```

3. **Download manually from GitHub:**
   - Go to https://github.com/eloisa-alesqui/alesqui-intelligence-distribution
   - Click "Code" → "Download ZIP"
   - Extract and run `./install.sh`

4. **Clone the repository instead:**
   ```bash
   git clone https://github.com/eloisa-alesqui/alesqui-intelligence-distribution.git
   cd alesqui-intelligence-distribution
   ./install.sh
   ```

### Installation Hangs at "Pulling Docker Images"

**Problem:** Docker image download takes too long or appears stuck.

**Solutions:**

1. **Check Docker Hub connectivity:**
   ```bash
   docker pull hello-world
   ```

2. **Check available disk space:**
   ```bash
   df -h
   docker system df
   ```

3. **If disk space is low, clean up:**
   ```bash
   docker system prune -a
   ```

4. **Try pulling images manually first:**
   ```bash
   docker pull alesquiintelligence/backend:latest
   docker pull alesquiintelligence/frontend:latest
   docker pull mongo:7.0  # Only for local deployment
   ```

5. **Check your internet speed:**
   - Images are ~1-2GB total
   - Slow connections may take 10-20 minutes

### Environment Configuration Errors

**Problem:** Installer rejects configuration values.

**Solutions:**

1. **MongoDB Atlas URI format issues:**
   - Must start with `mongodb+srv://`
   - Special characters in password must be URL-encoded
   - Example: `@` becomes `%40`, `#` becomes `%23`

2. **JWT Secret too short:**
   - Must be at least 32 characters
   - Let installer generate it automatically (recommended)

3. **OpenAI API Key format:**
   - Must start with `sk-proj-` or `sk-`
   - Get valid key from https://platform.openai.com/api-keys

4. **Edit .env file manually if needed:**
   ```bash
   cd atlas/  # or local/
   nano .env
   ```

### Services Fail to Start After Installation

**Problem:** Docker Compose reports errors when starting services.

**Solutions:**

1. **Check if ports are already in use:**
   ```bash
   sudo lsof -i :80
   sudo lsof -i :8080
   sudo lsof -i :27017  # Local deployment only
   ```

2. **Stop conflicting services:**
   ```bash
   sudo systemctl stop apache2  # If using port 80
   sudo systemctl stop nginx    # If using port 80
   ```

3. **Check Docker daemon is running:**
   ```bash
   sudo systemctl status docker
   sudo systemctl start docker
   ```

4. **View service logs:**
   ```bash
   cd atlas/  # or local/
   docker-compose logs
   ```

5. **Restart the installation:**
   ```bash
   cd atlas/  # or local/
   docker-compose down
   docker-compose up -d
   ```

---

## Backend Issues

### Backend Won't Start

**Symptoms:**
- Container exits immediately
- Error: "Connection refused" to MongoDB
- Container status shows "Exited"

**Solutions:**

1. **Check MongoDB is running:**
   ```bash
   docker-compose ps
   ```
   MongoDB should show "healthy" status.

2. **Verify connection string:**
   ```bash
   docker-compose config | grep MONGODB_URI
   ```
   Ensure password matches and format is correct.

3. **Check logs:**
   ```bash
   docker-compose logs backend
   ```
   Look for specific error messages.

4. **If using Atlas:**
   - Verify IP whitelist includes your server IP (or `0.0.0.0/0` for testing)
   - Check credentials in connection string
   - Ensure cluster is active (not paused)
   - Test connection: `mongosh "YOUR_MONGODB_URI"`

5. **Wait for MongoDB to be healthy:**
   ```bash
   # Restart backend after MongoDB is ready
   docker-compose restart backend
   ```

### Backend Health Check Fails

**Symptoms:**
- Health check endpoint returns error
- `wget` command fails in health check

**Solutions:**

1. **Check if `wget` is available:**
   ```bash
   docker exec alesqui-backend which wget
   ```

2. **Alternative: Use `curl` instead**
   Edit `docker-compose.yml`:
   ```yaml
   healthcheck:
     test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
   ```

3. **Increase startup time:**
   ```yaml
   healthcheck:
     start_period: 90s  # Give more time for startup
   ```

### JWT Token Errors

**Symptoms:**
- "Invalid JWT signature"
- "JWT expired"

**Solutions:**

1. **Verify JWT_SECRET is set:**
   ```bash
   docker-compose config | grep JWT_SECRET
   ```

2. **Ensure JWT_SECRET is consistent:**
   Don't change JWT_SECRET after users have logged in, or they'll need to re-login.

3. **Generate new secret:**
   ```bash
   openssl rand -base64 32
   ```
   Update `.env` and restart:
   ```bash
   docker-compose restart backend
   ```

---

## Frontend Issues

### Frontend Can't Connect to Backend

**Symptoms:**
- API calls fail in browser
- CORS errors in browser console
- Network errors in DevTools

**Solutions:**

1. **Verify backend is running:**
   ```bash
   curl http://localhost:8080/actuator/health
   ```

2. **Check CORS configuration:**
   Ensure `FRONTEND_URL` in `.env` matches how you access the frontend.
   
   **Examples:**
   - Accessing via `http://localhost` → `FRONTEND_URL=http://localhost`
   - Accessing via `https://app.company.com` → `FRONTEND_URL=https://app.company.com`
   - Accessing via IP → `FRONTEND_URL=http://192.168.1.100`

3. **Check VITE_API_BASE_URL:**
   Should point to backend. For local deployment:
   ```bash
   VITE_API_BASE_URL=http://localhost:8080
   ```
   For production with separate domains:
   ```bash
   VITE_API_BASE_URL=https://api.yourcompany.com
   ```

4. **Restart frontend after .env changes:**
   ```bash
   docker-compose restart frontend
   ```

### Frontend Shows Blank Page

**Symptoms:**
- White screen in browser
- No errors in console

**Solutions:**

1. **Check frontend logs:**
   ```bash
   docker-compose logs frontend
   ```

2. **Verify nginx is serving files:**
   ```bash
   docker exec alesqui-frontend ls -la /usr/share/nginx/html
   ```

3. **Check browser console:**
   Open DevTools (F12) and look for JavaScript errors.

4. **Clear browser cache:**
   Hard refresh: Ctrl+Shift+R (Linux/Windows) or Cmd+Shift+R (Mac)

### Frontend Health Check Fails

**Symptoms:**
- Container marked as unhealthy

**Solutions:**

1. **Check if `/health` endpoint exists:**
   ```bash
   curl http://localhost/health
   ```

2. **If endpoint doesn't exist, remove or modify health check:**
   Edit `docker-compose.yml`:
   ```yaml
   healthcheck:
     test: ["CMD", "wget", "-qO-", "http://localhost/"]
   ```

---

## MongoDB Issues

### MongoDB Won't Start

**Symptoms:**
- MongoDB container exits immediately
- Error: "Permission denied"

**Solutions:**

1. **Check MongoDB logs:**
   ```bash
   docker-compose logs mongodb
   ```

2. **Ensure password is set:**
   ```bash
   grep MONGODB_ROOT_PASSWORD .env
   ```

3. **Remove corrupted volumes:**
   ```bash
   docker-compose down -v
   docker volume rm alesqui-intelligence-distribution_mongodb_data
   docker-compose --profile local-db up -d
   ```
   ⚠️ **Warning:** This deletes all database data!

4. **Check disk space:**
   ```bash
   df -h
   ```

### MongoDB Atlas Connection Timeout

**Symptoms:**
- Backend logs show "connection timeout"
- Can't reach Atlas cluster

**Solutions:**

1. **Check IP whitelist:**
   - Go to Atlas dashboard → Network Access
   - Add IP Address → `0.0.0.0/0` (allow from anywhere) for testing
   - Or add your specific server IP

2. **Verify internet connectivity:**
   ```bash
   ping google.com
   curl -I https://cloud.mongodb.com
   ```

3. **Test connection string:**
   ```bash
   docker run -it --rm mongo:7 mongosh "YOUR_MONGODB_URI"
   ```
   If this fails, the connection string is incorrect.

4. **Check cluster status:**
   - Go to Atlas dashboard
   - Ensure cluster is not paused
   - Check for maintenance windows

5. **Verify DNS resolution:**
   ```bash
   nslookup your-cluster.mongodb.net
   ```

### Can't Connect to Local MongoDB from Host

**Symptoms:**
- Connection refused when trying to connect from host machine

**Solutions:**

1. **Ensure port is exposed:**
   ```bash
   docker-compose ps
   ```
   Should show `0.0.0.0:27017->27017/tcp`

2. **Connect using correct credentials:**
   ```bash
   mongosh "mongodb://admin:YOUR_PASSWORD@localhost:27017/alesqui_intelligence?authSource=admin"
   ```

3. **Check if port is already in use:**
   ```bash
   sudo lsof -i :27017
   # or
   sudo netstat -tulpn | grep 27017
   ```

---

## Network Issues

### Port Already in Use

**Symptoms:**
- Error: "bind: address already in use"
- Container fails to start

**Solutions:**

1. **Identify what's using the port:**
   ```bash
   # For port 80
   sudo lsof -i :80
   # For port 8080
   sudo lsof -i :8080
   # For port 27017
   sudo lsof -i :27017
   ```

2. **Option A: Stop the conflicting service:**
   ```bash
   sudo systemctl stop apache2  # If Apache is using port 80
   sudo systemctl stop nginx    # If Nginx is using port 80
   ```

3. **Option B: Change ports in `.env`:**
   ```bash
   FRONTEND_PORT=3000
   BACKEND_PORT=9090
   ```
   Then restart:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

### Containers Can't Communicate

**Symptoms:**
- Backend can't reach MongoDB
- Frontend can't reach Backend

**Solutions:**

1. **Check network exists:**
   ```bash
   docker network ls | grep alesqui
   ```

2. **Recreate network:**
   ```bash
   docker-compose down
   docker network prune
   docker-compose up -d
   ```

3. **Verify containers are on same network:**
   ```bash
   docker network inspect alesqui-intelligence-distribution_alesqui-network
   ```

---

## Performance Issues

### Backend Running Slow

**Solutions:**

1. **Check resource usage:**
   ```bash
   docker stats
   ```

2. **Increase memory for Java:**
   In `.env`:
   ```bash
   JAVA_OPTS=-XX:+UseContainerSupport -XX:MaxRAMPercentage=80.0 -XX:InitialRAMPercentage=50.0
   ```

3. **Check MongoDB indexes:**
   Ensure proper indexes are created for your queries.

4. **Monitor logs for errors:**
   ```bash
   docker-compose logs -f backend | grep -i error
   ```

### Out of Disk Space

**Symptoms:**
- Containers won't start
- Error: "no space left on device"

**Solutions:**

1. **Check disk usage:**
   ```bash
   df -h
   docker system df
   ```

2. **Clean Docker resources:**
   ```bash
   # Remove unused containers, networks, images
   docker system prune -a
   
   # Remove unused volumes (⚠️ be careful!)
   docker volume prune
   ```

3. **Remove old logs:**
   ```bash
   docker-compose logs --no-log-prefix > /tmp/logs.txt
   # Then truncate Docker logs
   sudo sh -c "truncate -s 0 /var/lib/docker/containers/*/*-json.log"
   ```

4. **Increase disk space:**
   Add more storage to your server or move Docker data to larger partition.

---

## Docker Issues

### Permission Denied Errors

**Symptoms:**
- Error: "permission denied while trying to connect to Docker daemon"

**Solutions:**

1. **Add user to docker group:**
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

2. **Or use sudo:**
   ```bash
   sudo docker-compose up -d
   ```

3. **Check Docker daemon is running:**
   ```bash
   sudo systemctl status docker
   sudo systemctl start docker
   ```

### Docker Compose Not Found

**Symptoms:**
- `docker-compose: command not found`

**Solutions:**

1. **Install Docker Compose:**
   ```bash
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

2. **Verify installation:**
   ```bash
   docker-compose --version
   ```

3. **Use `docker compose` (v2 syntax):**
   ```bash
   docker compose up -d
   ```

### Images Won't Pull

**Symptoms:**
- Error pulling images
- "image not found"

**Solutions:**

1. **Check internet connection:**
   ```bash
   ping google.com
   ```

2. **Check Docker Hub status:**
   Visit https://status.docker.com/

3. **Try pulling manually:**
   ```bash
   docker pull alesquiintelligence/backend:latest
   ```

4. **If using private registry, login:**
   ```bash
   docker login
   ```

5. **Check image names in .env:**
   ```bash
   grep IMAGE .env
   ```

---

## Diagnostic Commands

### Check Everything

```bash
# System info
docker --version
docker-compose --version
df -h

# Container status
docker-compose ps

# View all logs
docker-compose logs

# Check configuration
docker-compose config

# Resource usage
docker stats --no-stream

# Network info
docker network ls
docker network inspect alesqui-intelligence-distribution_alesqui-network

# Volume info
docker volume ls
docker volume inspect alesqui-intelligence-distribution_mongodb_data
```

### Backend Diagnostics

```bash
# Health check
curl http://localhost:8080/actuator/health

# View logs
docker-compose logs -f backend

# View last 100 lines
docker-compose logs --tail=100 backend

# Access container shell
docker exec -it alesqui-backend sh

# Check environment variables
docker exec alesqui-backend env | grep -E 'MONGODB|JWT|OPENAI'

# Check Java process
docker exec alesqui-backend ps aux | grep java
```

### Frontend Diagnostics

```bash
# Check if running
curl -I http://localhost

# View logs
docker-compose logs -f frontend

# Check nginx config
docker exec alesqui-frontend cat /etc/nginx/nginx.conf

# Check served files
docker exec alesqui-frontend ls -la /usr/share/nginx/html

# Access container shell
docker exec -it alesqui-frontend sh
```

### MongoDB Diagnostics

```bash
# Check if running
docker-compose ps mongodb

# View logs
docker-compose logs -f mongodb

# Access MongoDB shell
docker exec -it alesqui-mongodb mongosh -u admin -p YOUR_PASSWORD --authenticationDatabase admin

# Check databases
docker exec alesqui-mongodb mongosh -u admin -p YOUR_PASSWORD --authenticationDatabase admin --eval "show dbs"

# Check collections
docker exec alesqui-mongodb mongosh -u admin -p YOUR_PASSWORD --authenticationDatabase admin alesqui_intelligence --eval "show collections"
```

### Generate Full Diagnostic Report

```bash
#!/bin/bash
echo "=== ALESQUI INTELLIGENCE DIAGNOSTIC REPORT ===" > diagnostic-report.txt
echo "Date: $(date)" >> diagnostic-report.txt
echo "" >> diagnostic-report.txt

echo "=== Docker Version ===" >> diagnostic-report.txt
docker --version >> diagnostic-report.txt
docker-compose --version >> diagnostic-report.txt
echo "" >> diagnostic-report.txt

echo "=== Container Status ===" >> diagnostic-report.txt
docker-compose ps >> diagnostic-report.txt
echo "" >> diagnostic-report.txt

echo "=== Disk Usage ===" >> diagnostic-report.txt
df -h >> diagnostic-report.txt
echo "" >> diagnostic-report.txt

echo "=== Docker Resources ===" >> diagnostic-report.txt
docker system df >> diagnostic-report.txt
echo "" >> diagnostic-report.txt

echo "=== Recent Logs ===" >> diagnostic-report.txt
docker-compose logs --tail=50 >> diagnostic-report.txt

echo "Report saved to diagnostic-report.txt"
```

---

## Getting Help

If you've tried everything and still have issues:

1. **Collect diagnostic information:**
   ```bash
   # Save configuration
   docker-compose config > config.txt
   
   # Save logs
   docker-compose logs > logs.txt
   
   # Save container status
   docker-compose ps > status.txt
   ```

2. **Contact support:**
   - Email: support@alesqui.com
   - Include the diagnostic files
   - Describe what you were trying to do
   - Include your environment details:
     - Operating system
     - Docker version
     - Docker Compose version
     - Deployment method (local MongoDB or Atlas)

3. **GitHub Issues:**
   - Create an issue at: https://github.com/eloisa-alesqui/alesqui-intelligence-distribution/issues
   - Use the bug report template
   - Include diagnostic information

---

## Additional Resources

- **Installation Guide:** [INSTALLATION.md](INSTALLATION.md)
- **Docker Documentation:** https://docs.docker.com
- **MongoDB Atlas Docs:** https://docs.atlas.mongodb.com
- **Spring Boot Actuator:** https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html

---

**Still stuck? Don't hesitate to reach out to support@alesqui.com! 💪**
