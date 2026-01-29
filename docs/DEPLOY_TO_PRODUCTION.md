# Deploy Counter App to Your Domain

This guide walks you through deploying your Flutter + Django counter app to your own domain.

## 🎯 Quick Overview

You have several deployment options:
1. **AWS** (This guide focuses on AWS options)
   - **AWS EC2** - VPS server, full control
   - **AWS App Runner** - Easiest, handles Docker automatically
   - **AWS ECS** - Container orchestration
2. **Other VPS/Cloud** (DigitalOcean, Linode, etc.)
3. **Platform-as-a-Service** (Railway, Render)

---

## ☁️ AWS Deployment Options

### Option 1: AWS App Runner (Easiest) ⭐ Recommended for AWS

**Best for**: Simple deployment, automatic scaling, SSL handled

**Pros**: 
- Automatically builds from Docker
- Handles SSL/HTTPS automatically
- Auto-scaling
- Pay only for what you use

**Cons**: 
- Less control over infrastructure
- Slightly more expensive than EC2

**Cost**: ~$5-20/month depending on traffic

### Option 2: AWS EC2 (Most Control)

**Best for**: Full control, custom configurations, cost optimization

**Pros**:
- Full control over server
- Can optimize costs
- Good for learning AWS

**Cons**:
- Requires more setup
- You manage SSL, backups, security

**Cost**: ~$3-12/month (t2.micro/t2.small)

### Option 3: AWS ECS (Production Scale)

**Best for**: Production apps needing orchestration

**Pros**:
- Professional container orchestration
- Auto-scaling
- Good for larger apps

**Cons**:
- More complex setup
- Higher learning curve

**Cost**: ~$10-30/month

---

## ☁️ AWS Deployment (See [DEPLOY_AWS.md](DEPLOY_AWS.md))

For AWS-specific deployment instructions, see the complete AWS guide:
- **[AWS App Runner](DEPLOY_AWS.md#-aws-app-runner-easiest-method--recommended)** - Easiest AWS option
- **[AWS EC2](DEPLOY_AWS.md#-aws-ec2-full-control-method)** - Full control
- **[AWS RDS](DEPLOY_AWS.md#-aws-rds-database-service)** - Managed PostgreSQL

**Quick links**:
- AWS App Runner: ~$5-20/month, automatic SSL
- AWS EC2: ~$3-12/month, full control
- AWS RDS: ~$12-15/month (or free tier)

---

## 🖥️ Option 1: VPS Deployment (Non-AWS)

### Step 1: Choose a VPS Provider

Popular options:
- **DigitalOcean** - $4-12/month, simple
- **Linode** - $5-12/month, good performance
- **Hetzner** - €3-10/month, good value
- **AWS EC2** - Pay-as-you-go, more complex
- **Google Cloud** - Pay-as-you-go

For this guide, we'll use **DigitalOcean** as an example.

### Step 2: Create a VPS Server

1. Sign up at your VPS provider
2. Create a new "Droplet" (server):
   - **OS**: Ubuntu 22.04 LTS (or latest)
   - **Plan**: $6/month (1GB RAM) or $12/month (2GB RAM)
   - **Region**: Choose closest to your users
   - **SSH Key**: Add your SSH key (or use password)

### Step 3: Connect to Your Server

```bash
ssh root@your-server-ip
# or
ssh root@your-domain.com
```

### Step 4: Install Docker on Server

```bash
# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
apt install docker-compose-plugin -y

# Verify installation
docker --version
docker compose version
```

### Step 5: Point Your Domain to the Server

1. Go to your domain registrar (e.g., Namecheap, GoDaddy)
2. Add DNS records:
   - **A Record**: `@` → `your-server-ip`
   - **A Record**: `www` → `your-server-ip` (optional)

DNS propagation can take a few hours (usually 5-60 minutes).

### Step 6: Prepare Production Files

On your local machine, create production configuration:

```bash
# Clone your project (or copy files to server)
git clone your-repo-url
cd survey-web-app
```

Create `.env.production` file:

```bash
# backend/.env.production
SECRET_KEY=your-super-secret-key-change-this
DEBUG=0
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com,your-server-ip
DATABASE_URL=postgresql://survey_user:strong-password-here@db:5432/survey_db
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
```

### Step 7: Set Up Production Docker Compose

Create or update `docker-compose.prod.yml`:

```yaml
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
      target: production
    environment:
      - DEBUG=0
      - SECRET_KEY=${SECRET_KEY}
      - ALLOWED_HOSTS=${ALLOWED_HOSTS}
      - DATABASE_URL=${DATABASE_URL}
      - CORS_ALLOWED_ORIGINS=${CORS_ALLOWED_ORIGINS}
    volumes:
      - backend_static:/app/staticfiles
      - backend_media:/app/media
    command: gunicorn survey_backend.wsgi:application --bind 0.0.0.0:8000 --workers 3
    depends_on:
      - db

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=survey_user
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=survey_db
    volumes:
      - postgres_data:/var/lib/postgresql/data

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "80:80"
    depends_on:
      - backend

  nginx:
    image: nginx:alpine
    ports:
      - "443:443"
    volumes:
      - ./infra/nginx/nginx.prod.conf:/etc/nginx/nginx.conf
      - ./infra/ssl:/etc/nginx/ssl
      - backend_static:/var/www/static
    depends_on:
      - backend
      - frontend

volumes:
  postgres_data:
  backend_static:
  backend_media:
```

### Step 8: Set Up SSL with Let's Encrypt

Install Certbot:

```bash
apt install certbot python3-certbot-nginx -y
```

Get SSL certificate:

```bash
certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com
```

Certificates will be stored in `/etc/letsencrypt/live/yourdomain.com/`

### Step 9: Configure Nginx for Production

Create `infra/nginx/nginx.prod.conf`:

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    # Frontend (Flutter web app)
    location / {
        proxy_pass http://frontend:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Backend API
    location /api/ {
        proxy_pass http://backend:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static files
    location /static/ {
        alias /var/www/static/;
    }
}
```

### Step 10: Deploy to Server

On your server:

```bash
# Navigate to your project
cd /opt/survey-web-app  # or wherever you put it

# Build and start
docker compose -f docker-compose.prod.yml up -d --build

# Run migrations
docker compose -f docker-compose.prod.yml exec backend python manage.py migrate

# Collect static files
docker compose -f docker-compose.prod.yml exec backend python manage.py collectstatic --noinput
```

### Step 11: Set Up Auto-Renewal for SSL

```bash
# Add to crontab
crontab -e

# Add this line:
0 0 * * * certbot renew --quiet && docker compose -f /opt/survey-web-app/docker-compose.prod.yml restart nginx
```

---

## 🚀 Option 2: Platform-as-a-Service (Easier)

### Option 2a: Railway (Easiest)

1. Sign up at [railway.app](https://railway.app)
2. Connect your GitHub repo
3. Railway auto-detects Docker
4. Add environment variables
5. Deploy!

### Option 2b: Render

1. Sign up at [render.com](https://render.com)
2. Create new "Web Service"
3. Connect GitHub repo
4. Build command: `docker compose build`
5. Start command: `docker compose up`

### Option 2c: Fly.io

1. Install Fly CLI: `curl -L https://fly.io/install.sh | sh`
2. Login: `fly auth login`
3. Launch: `fly launch`
4. Deploy: `fly deploy`

---

## 📋 Production Checklist

Before deploying:

- [ ] Set `DEBUG=0` in production
- [ ] Change `SECRET_KEY` to a secure random string
- [ ] Set `ALLOWED_HOSTS` to your domain
- [ ] Use strong database password
- [ ] Set up SSL/HTTPS
- [ ] Configure CORS for your domain
- [ ] Run database migrations
- [ ] Test locally with production settings
- [ ] Set up backups for database
- [ ] Configure firewall (UFW on Ubuntu)
- [ ] Set up monitoring/logging

---

## 🔧 Production Environment Variables

Create `.env.production` on your server:

```bash
# Django
SECRET_KEY=generate-a-long-random-string-here
DEBUG=0
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com

# Database
POSTGRES_PASSWORD=strong-password-here
DATABASE_URL=postgresql://survey_user:strong-password-here@db:5432/survey_db

# CORS
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
```

**Generate SECRET_KEY**:
```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

---

## 🔐 Security Settings

Update `backend/survey_backend/settings.py` for production:

```python
# Security settings
if not DEBUG:
    SECURE_SSL_REDIRECT = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    SECURE_BROWSER_XSS_FILTER = True
    SECURE_CONTENT_TYPE_NOSNIFF = True
    X_FRAME_OPTIONS = 'DENY'
```

---

## 🗄️ Database Backups

Set up automated backups:

```bash
# Backup script
cat > /opt/survey-web-app/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/opt/backups"
DATE=$(date +%Y%m%d_%H%M%S)
docker compose -f /opt/survey-web-app/docker-compose.prod.yml exec -T db pg_dump -U survey_user survey_db > "$BACKUP_DIR/backup_$DATE.sql"
find $BACKUP_DIR -name "backup_*.sql" -mtime +7 -delete
EOF

chmod +x /opt/survey-web-app/backup.sh

# Add to crontab (daily at 2 AM)
crontab -e
# Add: 0 2 * * * /opt/survey-web-app/backup.sh
```

---

## 📊 Monitoring (Optional)

### Basic Monitoring

Check container status:
```bash
docker compose -f docker-compose.prod.yml ps
docker compose -f docker-compose.prod.yml logs -f
```

### Health Check

Add to `docker-compose.prod.yml`:
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8000/api/"]
  interval: 30s
  timeout: 10s
  retries: 3
```

---

## 🐛 Troubleshooting

### Can't connect to domain
- Check DNS propagation: `dig yourdomain.com`
- Check firewall: `ufw status`
- Check if Docker containers are running: `docker ps`

### SSL certificate issues
- Ensure ports 80 and 443 are open
- Check DNS is pointing correctly
- Verify domain is accessible

### Database connection errors
- Check `DATABASE_URL` environment variable
- Ensure database container is running
- Check database password is correct

### Static files not loading
- Run `python manage.py collectstatic`
- Check nginx configuration
- Verify volume mounts

---

## 🚢 Quick Deploy Script

Create a deployment script on your server:

```bash
#!/bin/bash
# deploy.sh

cd /opt/survey-web-app

# Pull latest code
git pull origin main

# Build and restart
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d --build

# Run migrations
docker compose -f docker-compose.prod.yml exec backend python manage.py migrate

# Collect static
docker compose -f docker-compose.prod.yml exec backend python manage.py collectstatic --noinput

echo "Deployment complete!"
```

---

## 📝 Next Steps

After deployment:

1. Test your domain: `https://yourdomain.com`
2. Click the button to test the counter
3. Check logs: `docker compose logs -f`
4. Set up monitoring/alerting
5. Configure backups
6. Add CI/CD for automated deployments

---

**Recommended for beginners**: Start with **Railway** or **Render** - they handle SSL, scaling, and infrastructure for you!

**Recommended for more control**: Use **VPS with Docker** - you have full control and it's cheaper long-term.
