# Deploy to AWS - Complete Guide

This guide covers deploying your Flutter + Django counter app to AWS.

## 🚀 AWS App Runner (Easiest Method) ⭐ Recommended

**Best for**: Quick deployment, automatic SSL, auto-scaling

### Prerequisites

- AWS Account ([aws.amazon.com](https://aws.amazon.com))
- Your project pushed to GitHub (or AWS CodeCommit)

### Step 1: Push Code to GitHub

```bash
# If not already done
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/yourusername/survey-web-app.git
git push -u origin main
```

### Step 2: Create App Runner Service

1. **Go to AWS Console** → **App Runner**
2. **Click "Create an App Runner service"**
3. **Choose "Source code repository"** → Connect to GitHub
4. **Authorize** AWS to access your GitHub
5. **Select repository**: `survey-web-app`
6. **Select branch**: `main`

### Step 3: Configure Build

**Build settings**:
- **Build command**: (leave empty, App Runner detects Docker automatically)
- **Port**: `8000` (backend) or `3000` (frontend) - we'll use frontend with nginx

**Note**: App Runner expects a single Dockerfile. You have two options:

**Option A: Use Frontend Dockerfile** (serves both via nginx)
- App Runner will build `frontend/Dockerfile`
- You'll need to configure nginx to proxy to backend

**Option B: Combine into single docker-compose** (complex)

### Step 4: Configure Service

**Service settings**:
- **Service name**: `survey-counter-app`
- **Virtual CPU**: 0.5 vCPU (minimum)
- **Memory**: 1 GB (minimum)

### Step 5: Environment Variables

Add these environment variables:

```
SECRET_KEY=your-generated-secret-key-here
DEBUG=0
ALLOWED_HOSTS=yourdomain.com,*.apprunner.awsapps.com
DATABASE_URL=postgresql://... (use AWS RDS, see below)
CORS_ALLOWED_ORIGINS=https://yourdomain.com
```

**Generate SECRET_KEY**:
```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

### Step 6: Configure Database (AWS RDS)

Since App Runner is stateless, use AWS RDS for PostgreSQL:

1. **Go to AWS Console** → **RDS**
2. **Create database**:
   - **Engine**: PostgreSQL
   - **Template**: Free tier (if eligible) or Dev/Test
   - **Instance**: db.t3.micro
   - **Master username**: `survey_user`
   - **Master password**: (strong password)
   - **Database name**: `survey_db`
   - **VPC**: Default VPC
   - **Public access**: Yes (for App Runner)
3. **Note the endpoint**: `your-db.xxxxx.us-east-1.rds.amazonaws.com`

**Update DATABASE_URL** in App Runner:
```
DATABASE_URL=postgresql://survey_user:your-password@your-db.xxxxx.us-east-1.rds.amazonaws.com:5432/survey_db
```

### Step 7: Deploy

1. **Click "Create & deploy"**
2. Wait 5-10 minutes for deployment
3. App Runner provides URL: `https://xxxxx.us-east-1.awsapprunner.com`

### Step 8: Connect Your Domain

1. In App Runner service → **Custom domains**
2. **Add domain**: Enter your domain
3. **Add DNS records** (provided by AWS):
   - Add CNAME record in your domain DNS
4. AWS handles SSL automatically! ✨

### Step 9: Run Migrations

```bash
# Connect to App Runner instance (via AWS CLI or console)
# Or use AWS Systems Manager Session Manager

# Run migrations
python manage.py migrate
```

Or create a one-time task/container to run migrations.

**Cost**: ~$5-20/month (pay per use)

---

## 🖥️ AWS EC2 (Full Control Method)

**Best for**: Learning, cost optimization, full control

### Step 1: Launch EC2 Instance

1. **Go to AWS Console** → **EC2**
2. **Launch Instance**:
   - **Name**: `survey-counter-app`
   - **AMI**: Ubuntu Server 22.04 LTS
   - **Instance type**: `t2.micro` (free tier) or `t2.small`
   - **Key pair**: Create new or use existing
   - **Security group**: 
     - Allow SSH (22) from your IP
     - Allow HTTP (80) from anywhere
     - Allow HTTPS (443) from anywhere
3. **Launch instance**

### Step 2: Connect to EC2

```bash
# Using SSH
ssh -i your-key.pem ubuntu@your-ec2-ip

# Or use AWS Session Manager (no key needed)
```

### Step 3: Install Docker on EC2

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker ubuntu
newgrp docker

# Install Docker Compose
sudo apt install docker-compose-plugin -y

# Verify
docker --version
docker compose version
```

### Step 4: Set Up Domain

1. **Get Elastic IP** (optional but recommended):
   - EC2 → Elastic IPs → Allocate → Associate with your instance

2. **Point DNS to EC2**:
   - Go to your domain registrar
   - Add A record: `@` → `your-ec2-ip` (or Elastic IP)
   - Add A record: `www` → `your-ec2-ip`

### Step 5: Transfer Your Code

**Option A: Clone from GitHub**
```bash
# Install git
sudo apt install git -y

# Clone your repo
git clone https://github.com/yourusername/survey-web-app.git
cd survey-web-app
```

**Option B: Upload via SCP**
```bash
# From your local machine
scp -i your-key.pem -r survey-web-app ubuntu@your-ec2-ip:~/
```

### Step 6: Set Up Environment Variables

Create `.env` file:

```bash
cd survey-web-app
nano .env
```

Add:
```bash
SECRET_KEY=your-generated-secret-key-here
DEBUG=0
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com,your-ec2-ip
DATABASE_URL=postgresql://survey_user:password@db:5432/survey_db
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
```

### Step 7: Set Up SSL with Let's Encrypt

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# For now, we'll set up basic HTTP first
# SSL will be configured after nginx is running
```

### Step 8: Set Up Production Docker Compose

Update or create `docker-compose.prod.yml` for EC2:

```yaml
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
      target: production
    environment:
      - DEBUG=${DEBUG:-0}
      - SECRET_KEY=${SECRET_KEY}
      - ALLOWED_HOSTS=${ALLOWED_HOSTS}
      - DATABASE_URL=${DATABASE_URL}
      - CORS_ALLOWED_ORIGINS=${CORS_ALLOWED_ORIGINS}
    volumes:
      - backend_static:/app/staticfiles
    command: gunicorn survey_backend.wsgi:application --bind 0.0.0.0:8000 --workers 3
    depends_on:
      - db
    networks:
      - app-network

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=survey_user
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=survey_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    networks:
      - app-network

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./infra/nginx/nginx.prod.conf:/etc/nginx/nginx.conf
      - /etc/letsencrypt:/etc/letsencrypt:ro
      - backend_static:/var/www/static
    depends_on:
      - backend
      - frontend
    networks:
      - app-network

volumes:
  postgres_data:
  backend_static:

networks:
  app-network:
    driver: bridge
```

### Step 9: Create Production Nginx Config

Create `infra/nginx/nginx.prod.conf`:

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    
    # Redirect HTTP to HTTPS (after SSL is set up)
    # return 301 https://$server_name$request_uri;
    
    # For now, serve HTTP (change after SSL)
    location / {
        proxy_pass http://frontend:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /api/ {
        proxy_pass http://backend:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /static/ {
        alias /var/www/static/;
    }
}

# After SSL is set up, add this:
# server {
#     listen 443 ssl http2;
#     server_name yourdomain.com www.yourdomain.com;
#     
#     ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
#     ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
#     
#     location / {
#         proxy_pass http://frontend:80;
#     }
#     
#     location /api/ {
#         proxy_pass http://backend:8000;
#     }
# }
```

### Step 10: Deploy

```bash
# Build and start services
docker compose -f docker-compose.prod.yml up -d --build

# Run migrations
docker compose -f docker-compose.prod.yml exec backend python manage.py migrate

# Collect static files
docker compose -f docker-compose.prod.yml exec backend python manage.py collectstatic --noinput
```

### Step 11: Set Up SSL

After everything is running on HTTP:

```bash
# Stop nginx temporarily
docker compose -f docker-compose.prod.yml stop nginx

# Get SSL certificate
sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com

# Update nginx config to use SSL (uncomment SSL section)
# Restart nginx
docker compose -f docker-compose.prod.yml start nginx
```

### Step 12: Set Up Auto-Renewal

```bash
# Test renewal
sudo certbot renew --dry-run

# Add to crontab
sudo crontab -e
# Add: 0 0 * * * certbot renew --quiet && docker compose -f /home/ubuntu/survey-web-app/docker-compose.prod.yml restart nginx
```

### Step 13: Set Up Auto-Start on Reboot

```bash
# Create systemd service or add to /etc/rc.local
# Or use Docker's restart policy (already set in docker-compose)
```

**Cost**: ~$3-12/month (t2.micro free tier for first year)

---

## 🗄️ AWS RDS (Database Service)

For production, use AWS RDS instead of PostgreSQL in Docker:

### Create RDS Instance

1. **Go to AWS Console** → **RDS**
2. **Create database**:
   - **Engine**: PostgreSQL 15
   - **Template**: Free tier (if eligible) or Dev/Test
   - **Instance**: db.t3.micro or db.t4g.micro
   - **Storage**: 20 GB (free tier) or as needed
   - **Master username**: `survey_user`
   - **Master password**: (strong password)
   - **Database name**: `survey_db`
   - **VPC**: Default VPC
   - **Public access**: Yes (if needed for App Runner/EC2)
   - **Security group**: Allow PostgreSQL (5432) from your EC2/App Runner

3. **Note the endpoint**: `your-db.xxxxx.us-east-1.rds.amazonaws.com`

### Update DATABASE_URL

In your `.env` or App Runner environment variables:

```bash
DATABASE_URL=postgresql://survey_user:your-password@your-db.xxxxx.us-east-1.rds.amazonaws.com:5432/survey_db
```

**Cost**: Free tier for first year, then ~$10-15/month

---

## 📊 AWS Pricing Summary

### App Runner
- **CPU**: $0.064/vCPU-hour
- **Memory**: $0.007/GB-hour
- **Approx**: $5-20/month for small traffic

### EC2 (t2.micro)
- **Free tier**: First year free
- **After**: ~$8.50/month (on-demand)
- **Reserved**: ~$4-5/month (1-year commitment)

### RDS (db.t3.micro)
- **Free tier**: First year free
- **After**: ~$12-15/month

### Total (after free tier)
- **App Runner + RDS**: ~$15-35/month
- **EC2 + RDS**: ~$15-30/month

---

## 🔧 AWS-Specific Scripts

### Update Frontend API URL for Production

Update `frontend/lib/main.dart`:

```dart
// Production
static const String apiBaseUrl = 'https://yourdomain.com/api/counter/';

// Or use environment variable
static const String apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'https://yourdomain.com/api/counter/',
);
```

### Deployment Script for EC2

Create `scripts/deploy-aws-ec2.sh` on your EC2:

```bash
#!/bin/bash
# deploy-aws-ec2.sh

cd /home/ubuntu/survey-web-app

# Pull latest code
git pull origin main

# Rebuild and restart
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d --build

# Run migrations
docker compose -f docker-compose.prod.yml exec backend python manage.py migrate

# Collect static
docker compose -f docker-compose.prod.yml exec backend python manage.py collectstatic --noinput

echo "Deployment complete!"
```

Make it executable:
```bash
chmod +x scripts/deploy-aws-ec2.sh
```

---

## 🛡️ AWS Security Best Practices

1. **Security Groups**: Only open necessary ports (80, 443, 22)
2. **IAM Roles**: Use IAM roles instead of access keys when possible
3. **Secrets Manager**: Store SECRET_KEY in AWS Secrets Manager
4. **CloudWatch**: Enable logging and monitoring
5. **Backups**: Enable automated RDS backups
6. **Firewall**: Use AWS WAF if needed

---

## 📋 AWS Deployment Checklist

- [ ] AWS account created
- [ ] Code pushed to GitHub
- [ ] EC2 instance created (or App Runner service)
- [ ] Domain DNS pointed to AWS
- [ ] SSL certificate configured
- [ ] RDS database created
- [ ] Environment variables set
- [ ] Migrations run
- [ ] Static files collected
- [ ] Security groups configured
- [ ] Backups enabled
- [ ] Monitoring set up

---

## 🆘 Troubleshooting

### Can't connect to EC2
- Check security group allows SSH (22) from your IP
- Verify key pair is correct
- Check instance is running

### App Runner build fails
- Check Dockerfile is in correct location
- Verify build context
- Check environment variables

### Database connection errors
- Verify RDS security group allows EC2/App Runner
- Check DATABASE_URL format
- Ensure RDS is publicly accessible (if needed)

### SSL certificate issues
- Ensure DNS is pointing correctly
- Ports 80 and 443 must be open
- Wait for DNS propagation (can take hours)

---

**Next Steps**: Choose your AWS deployment method and follow the detailed steps above!
