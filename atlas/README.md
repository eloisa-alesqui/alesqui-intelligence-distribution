# 🚀 Alesqui Intelligence - Atlas Deployment

Deploy Alesqui Intelligence with MongoDB Atlas - a fully managed cloud database service.

## 📋 Overview

This deployment option includes:
- ✅ **MongoDB Atlas** - Cloud-managed database with automatic backups and scaling
- ✅ **Backend API** - Java Spring Boot application (port 8080)
- ✅ **Frontend UI** - React application served by Nginx (port 80)

**Best for:** Production deployments, scalable applications, and teams that want managed database services.

**Advantages:**
- 🔒 Built-in security and encryption
- 📈 Easy scaling as your application grows
- 💾 Automated backups and point-in-time recovery
- 📊 Performance monitoring and optimization suggestions
- 🌍 Global distribution capabilities
- 🔧 No database maintenance required

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

### Required Accounts & Credentials
1. **MongoDB Atlas Account** - Sign up at [cloud.mongodb.com](https://cloud.mongodb.com)
2. **OpenAI API Key** - Get from [OpenAI Platform](https://platform.openai.com/api-keys)
3. **SMTP Service** - Production email service (SendGrid, Mailgun, Amazon SES, etc.)

### System Requirements
- **RAM:** 2GB minimum, 4GB recommended (no local database)
- **Disk:** 5GB minimum for application
- **CPU:** 2 cores minimum
- **Ports:** 80 and 8080 must be available

---

## 📥 MongoDB Atlas Setup

### Step 1: Create MongoDB Atlas Account

1. Go to [cloud.mongodb.com](https://cloud.mongodb.com)
2. Sign up for a free account or log in
3. Create a new organization (if needed)

### Step 2: Create a Cluster

1. Click **"Build a Database"** or **"Create"**
2. Choose your cluster tier:
   - **M0 Free** - Good for development and small projects (512MB storage)
   - **M10+** - Recommended for production (adjustable resources)
3. Select your cloud provider and region:
   - Choose a region close to your application server
   - AWS, Google Cloud, or Azure
4. Name your cluster (e.g., "alesqui-production")
5. Click **"Create Cluster"** (takes 3-5 minutes)

### Step 3: Create Database User

1. Go to **Database Access** in the left sidebar
2. Click **"Add New Database User"**
3. Choose **"Password"** authentication
4. Username: `alesqui_admin` (or your preference)
5. **Auto-generate a secure password** (copy it!)
6. Database User Privileges: **"Read and write to any database"**
7. Click **"Add User"**

**Important:** Save your password securely - you'll need it for the connection string.

### Step 4: Configure Network Access

1. Go to **Network Access** in the left sidebar
2. Click **"Add IP Address"**

**Options:**

**For Development/Testing:**
```
Allow access from anywhere: 0.0.0.0/0
```
⚠️ Not recommended for production!

**For Production:**
Add your server's specific IP address:
```
IP Address: 203.0.113.10 (your server IP)
Description: Production Server
```

To find your server IP:
```bash
curl ifconfig.me
```

3. Click **"Confirm"**

### Step 5: Get Connection String

1. Go back to **Database** in the left sidebar
2. Click **"Connect"** on your cluster
3. Choose **"Connect your application"**
4. Select:
   - **Driver:** Java
   - **Version:** 4.3 or later
5. Copy the connection string, it looks like:
   ```
   mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```

6. **Modify the connection string:**
   - Replace `<password>` with your actual database password
   - Add your database name before the `?`: `.../alesqui_intelligence?retryWrites=...`
   - If your password has special characters, URL-encode them:
     - `@` → `%40`
     - `#` → `%23`
     - `%` → `%25`
     - `/` → `%2F`

**Example:**
```
# Original
mongodb+srv://alesqui_admin:MyP@ss#123@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority

# Corrected (with database name and URL-encoded password)
mongodb+srv://alesqui_admin:MyP%40ss%23123@cluster0.xxxxx.mongodb.net/alesqui_intelligence?retryWrites=true&w=majority
```

---

## 📥 Application Installation

### Step 1: Navigate to Atlas Directory

```bash
cd atlas/
```

### Step 2: Create Environment File

```bash
cp .env.example .env
```

### Step 3: Generate Secure Credentials

Generate a secure JWT secret:

```bash
openssl rand -base64 32
```

Or use the convenience script from the root directory:
```bash
../scripts/generate-secrets.sh
```

### Step 4: Configure Environment Variables

Edit the `.env` file:

```bash
nano .env
```

**Required Changes:**

1. **MongoDB Atlas URI** (line 42)
   ```bash
   MONGODB_ATLAS_URI=mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/alesqui_intelligence?retryWrites=true&w=majority
   ```
   Use the connection string from Step 5 of MongoDB Atlas Setup.

2. **JWT Secret** (line 51)
   ```bash
   JWT_SECRET=your_generated_jwt_secret_at_least_32_chars
   ```

3. **OpenAI API Key** (line 64)
   ```bash
   OPENAI_API_KEY=sk-proj-your-actual-openai-key
   ```

4. **Frontend URL** (line 77)
   ```bash
   FRONTEND_URL=https://intelligence.yourcompany.com
   ```
   Use your actual production domain with HTTPS.

5. **API URL for Frontend** (line 82)
   ```bash
   VITE_API_URL=https://intelligence.yourcompany.com/api
   ```
   Or `http://localhost:8080` for development.

6. **SMTP Configuration** (lines 103-122)
   ```bash
   SMTP_HOST=smtp.sendgrid.net
   SMTP_PORT=587
   SMTP_USER=apikey
   SMTP_PASSWORD=SG.your-sendgrid-api-key
   MAIL_FROM_EMAIL=noreply@yourcompany.com
   MAIL_FROM_NAME=Alesqui Intelligence
   ```

**Optional Changes:**
- `COMPANY_NAME` - Your company name
- `AUDIT_RETENTION_DAYS` - Adjust audit log retention period

### Step 5: Start the Services

```bash
docker-compose up -d
```

This will:
1. Pull the required Docker images
2. Start the backend and connect to MongoDB Atlas
3. Start the frontend

### Step 6: Verify Deployment

Wait for services to become healthy (1-2 minutes):

```bash
docker-compose ps
```

Both services should show "healthy" status.

Check service health:

```bash
# Check backend health
curl http://localhost:8080/actuator/health

# Should return: {"status":"UP"}
```

---

## 🌐 Accessing the Application

Once all services are healthy:

- **Frontend:** http://localhost (or your custom domain)
- **Backend API:** http://localhost:8080 (or your API endpoint)
- **API Health Check:** http://localhost:8080/actuator/health
- **MongoDB:** Managed by Atlas (access via Atlas dashboard)

**Default Admin Login:**
Follow the setup wizard on first launch to create your admin account.

---

## 🔒 Production Configuration

### SSL/TLS Setup

For production, you **must** use HTTPS. Set up a reverse proxy with SSL certificates.

#### Option 1: Nginx with Let's Encrypt

1. Install Nginx and Certbot:
   ```bash
   sudo apt install nginx certbot python3-certbot-nginx
   ```

2. Create Nginx configuration:
   ```nginx
   # /etc/nginx/sites-available/alesqui
   server {
       listen 80;
       server_name intelligence.yourcompany.com;
       return 301 https://$server_name$request_uri;
   }

   server {
       listen 443 ssl http2;
       server_name intelligence.yourcompany.com;
       
       ssl_certificate /etc/letsencrypt/live/intelligence.yourcompany.com/fullchain.pem;
       ssl_certificate_key /etc/letsencrypt/live/intelligence.yourcompany.com/privkey.pem;
       
       # Frontend
       location / {
           proxy_pass http://localhost:80;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
       
       # Backend API
       location /api {
           proxy_pass http://localhost:8080;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```

3. Enable the site:
   ```bash
   sudo ln -s /etc/nginx/sites-available/alesqui /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   ```

4. Get SSL certificate:
   ```bash
   sudo certbot --nginx -d intelligence.yourcompany.com
   ```

#### Option 2: Caddy (Automatic HTTPS)

Caddy automatically obtains and renews SSL certificates.

```caddy
# Caddyfile
intelligence.yourcompany.com {
    # Frontend
    reverse_proxy localhost:80
    
    # Backend API
    handle /api* {
        reverse_proxy localhost:8080
    }
}
```

Start Caddy:
```bash
caddy run
```

### Firewall Configuration

```bash
# Allow SSH
sudo ufw allow 22

# Allow HTTP/HTTPS
sudo ufw allow 80
sudo ufw allow 443

# Block direct access to backend (only via reverse proxy)
sudo ufw deny 8080

# Enable firewall
sudo ufw enable
```

---

## 📊 Managing Services

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
```

### Stop Services

```bash
docker-compose down
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

## 🗄️ Database Management with Atlas

### Access MongoDB

1. **Via Atlas Dashboard:**
   - Go to your cluster in Atlas
   - Click **"Browse Collections"**
   - View and manage data through web interface

2. **Via MongoDB Compass:**
   - Download [MongoDB Compass](https://www.mongodb.com/products/compass)
   - Use your Atlas connection string to connect
   - Visual interface for database management

3. **Via mongosh (CLI):**
   ```bash
   mongosh "mongodb+srv://cluster0.xxxxx.mongodb.net/alesqui_intelligence" --username alesqui_admin
   ```

### Automated Backups

Atlas automatically backs up your data:

1. Go to **Backup** tab in Atlas
2. Configure backup schedule (M10+ clusters)
3. Set retention policy
4. Enable continuous backups for point-in-time recovery

**Manual Backup/Export:**
```bash
# Export all data
mongoexport --uri="mongodb+srv://username:password@cluster.mongodb.net/alesqui_intelligence" --collection=users --out=users.json

# Or use mongodump
mongodump --uri="mongodb+srv://username:password@cluster.mongodb.net/alesqui_intelligence" --out=./backup
```

### Monitoring

Atlas provides built-in monitoring:

1. Go to **Metrics** tab
2. Monitor:
   - Query performance
   - Connection count
   - Storage usage
   - Index recommendations
3. Set up **Alerts** for:
   - High connection count
   - Low storage space
   - Performance degradation

---

## 🚨 Troubleshooting

### Backend Can't Connect to Atlas

**Problem:** Backend logs show "Connection refused" or "Authentication failed".

**Solutions:**

1. **Check IP whitelist in Atlas:**
   - Go to Network Access in Atlas
   - Verify your server IP is whitelisted
   - For testing, temporarily allow `0.0.0.0/0`

2. **Verify connection string:**
   ```bash
   docker-compose config | grep MONGODB_ATLAS_URI
   ```
   - Ensure password is URL-encoded
   - Database name is included
   - Format is `mongodb+srv://` (not `mongodb://`)

3. **Test connection from backend container:**
   ```bash
   docker exec -it alesqui-backend wget -qO- http://localhost:8080/actuator/health
   ```

4. **Check Atlas status:**
   - Visit [status.mongodb.com](https://status.mongodb.com)
   - Verify your cluster is running in Atlas dashboard

### Connection Timeout

**Problem:** "Connection timeout" errors.

**Solutions:**

1. Check firewall isn't blocking outbound connections on port 27017
2. Verify DNS resolution works:
   ```bash
   docker exec alesqui-backend getent hosts cluster0.xxxxx.mongodb.net
   ```
3. Try a different Atlas region if issues persist

### Authentication Failed

**Problem:** "Authentication failed" in logs.

**Solutions:**

1. Verify username and password in connection string
2. Check user has correct privileges in Atlas Database Access
3. Ensure password special characters are URL-encoded
4. Try regenerating database user password in Atlas

### Frontend Can't Reach Backend

**Problem:** Frontend loads but API calls fail.

**Solutions:**

1. Verify backend is healthy:
   ```bash
   curl http://localhost:8080/actuator/health
   ```

2. Check CORS configuration:
   - Verify `FRONTEND_URL` matches where you're accessing from
   - Check browser console for CORS errors

3. For production with reverse proxy:
   - Ensure `VITE_API_URL` points to correct API endpoint
   - Verify reverse proxy configuration

### SSL Certificate Issues

**Problem:** Browser shows certificate warnings.

**Solutions:**

1. Verify SSL certificate is valid:
   ```bash
   curl -vI https://intelligence.yourcompany.com
   ```

2. Renew Let's Encrypt certificate:
   ```bash
   sudo certbot renew
   ```

3. Check certificate paths in Nginx configuration

### Email Not Sending

**Problem:** Users don't receive emails.

**Solutions:**

1. Verify SMTP credentials in .env
2. Check logs for SMTP errors:
   ```bash
   docker-compose logs backend | grep -i smtp
   ```
3. For SendGrid, verify API key has "Mail Send" permissions
4. Test SMTP connection from container:
   ```bash
   docker exec -it alesqui-backend telnet smtp.sendgrid.net 587
   ```

---

## 📈 Scaling with Atlas

### Vertical Scaling (Cluster Size)

To handle more load:

1. Go to your cluster in Atlas
2. Click **"Edit Configuration"**
3. Select a larger tier (M20, M30, etc.)
4. Click **"Review Changes"** and **"Apply"**
5. Atlas will scale with zero downtime

### Horizontal Scaling (Sharding)

For very large datasets:

1. Enable sharding in cluster configuration
2. Choose shard key based on your query patterns
3. Add additional shards as needed

### Read Replicas

For read-heavy workloads:

1. Configure replica set members
2. Update connection string to use read preference
3. Example: `?readPreference=secondaryPreferred`

### Application Scaling

Scale backend containers:

```yaml
# docker-compose.yml
backend:
  deploy:
    replicas: 3
```

Use a load balancer (Nginx, HAProxy) to distribute traffic.

---

## 🔒 Security Best Practices

### Production Checklist

- [x] Use HTTPS for all connections (reverse proxy with SSL)
- [x] Strong JWT secret (32+ characters)
- [x] MongoDB Atlas network access restricted to specific IPs
- [x] Database user with minimal required privileges
- [x] Production SMTP service (not personal email)
- [x] Firewall rules configured (UFW/iptables)
- [x] Regular security updates: `docker-compose pull`
- [x] Atlas backups enabled and tested
- [x] Monitoring and alerting configured
- [x] Audit logs reviewed regularly

### MongoDB Atlas Security Features

1. **Encryption:**
   - Data at rest: Automatically encrypted
   - Data in transit: TLS/SSL enabled by default

2. **Access Control:**
   - Enable IP whitelisting
   - Use strong passwords
   - Implement database-level permissions

3. **Audit Logs:**
   - Available on M10+ clusters
   - Track all database access

4. **VPC Peering:**
   - For M10+ clusters
   - Private connection between app and database

---

## 📞 Getting Help

- **Atlas Documentation:** [docs.atlas.mongodb.com](https://docs.atlas.mongodb.com)
- **MongoDB Support:** [support.mongodb.com](https://support.mongodb.com)
- **Main Documentation:** [Main README](../README.md)
- **Troubleshooting:** [Troubleshooting Guide](../TROUBLESHOOTING.md)
- **GitHub Issues:** [Report an issue](https://github.com/eloisa-alesqui/alesqui-intelligence-distribution/issues)
- **Email Support:** support@alesqui.com

---

## 📝 Next Steps

After successful deployment:

1. **Create admin account** - Follow setup wizard
2. **Configure users** - Add team members
3. **Test AI features** - Verify OpenAI integration
4. **Set up monitoring** - Configure Atlas alerts
5. **Test backups** - Verify automated backups work
6. **Configure SSL** - Set up HTTPS for production
7. **Load testing** - Ensure system handles expected traffic
8. **Documentation** - Document your specific setup for team

---

## 💰 Cost Optimization

### Atlas Pricing Tips

1. **Start with M0 Free Tier:**
   - 512MB storage, shared CPU
   - Good for development/testing
   - No credit card required

2. **Right-size your cluster:**
   - Monitor actual usage in Metrics tab
   - Scale down if overprovisioned
   - M10 suitable for most small-medium apps

3. **Use Auto-scaling:**
   - Available on M10+
   - Automatically adjusts resources based on load
   - Pay only for what you use

4. **Archive old data:**
   - Set up data archival for old records
   - Use Atlas Data Lake for cold storage
   - Keep active database lean

### Application Cost Optimization

1. **Optimize Docker images:**
   - Use specific version tags
   - Clean up unused images regularly

2. **Monitor resource usage:**
   - Adjust Java heap size if needed
   - Set appropriate container limits

3. **Efficient queries:**
   - Use indexes effectively
   - Review slow queries in Atlas Performance Advisor
   - Implement pagination for large result sets
