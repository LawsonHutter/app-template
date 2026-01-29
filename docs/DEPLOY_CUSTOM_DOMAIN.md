# Deploy to Your Custom Domain - Step by Step

This guide walks you through connecting your EC2 deployment to your custom domain.

## Prerequisites ✅

- ✅ EC2 instance running
- ✅ Docker containers running
- ✅ App working on IP address (`http://54.157.14.153:8000`)
- ✅ Your domain name ready

---

## Step 1: Get Elastic IP (Recommended)

**Why?** EC2 instances get new IPs when restarted. Elastic IP keeps it permanent.

### In AWS Console:

1. **Go to EC2** → **Elastic IPs** (left sidebar)
2. **Allocate Elastic IP address**
   - **Network border group**: Choose your region
   - Click **"Allocate"**
3. **Associate Elastic IP**:
   - Select the Elastic IP you just created
   - Click **"Associate Elastic IP address"**
   - **Instance**: Select your `survey-app` instance
   - Click **"Associate"**

**Note your new Elastic IP** (e.g., `54.123.45.67`) - you'll use this instead of `54.157.14.153`

---

## Step 2: Point Your Domain to EC2

### At Your Domain Registrar:

1. **Log in** to your domain registrar (GoDaddy, Namecheap, etc.)
2. **Go to DNS Management** (or DNS Settings)
3. **Add/Edit A Records**:

   **Record 1** (Root domain):
   - **Type**: A
   - **Name**: `@` (or leave blank, depends on registrar)
   - **Value**: `54.123.45.67` (your Elastic IP or EC2 IP)
   - **TTL**: 3600 (or default)

   **Record 2** (www subdomain):
   - **Type**: A
   - **Name**: `www`
   - **Value**: `54.123.45.67` (same IP)
   - **TTL**: 3600

4. **Save changes**

### DNS Propagation

- **Wait 5-60 minutes** for DNS to propagate
- **Check propagation**: Visit `https://dnschecker.org` and search for your domain
- **Verify**: Run `ping yourdomain.com` - should show your EC2 IP

---

## Step 3: Update Environment Variables

On your EC2 server:

```bash
cd ~/survey-web-app

# Edit .env file
nano .env
```

**Update these values**:

```bash
SECRET_KEY=your-secret-key-here
DEBUG=0
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com,54.157.14.153
DATABASE_URL=postgresql://survey_user:password123@db:5432/survey_db
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
POSTGRES_PASSWORD=password123
```

**Important changes**:
- Replace `yourdomain.com` with your actual domain
- Update `ALLOWED_HOSTS` to include your domain
- Update `CORS_ALLOWED_ORIGINS` to use `https://` (we'll set up SSL next)

Save: `Ctrl+X`, then `Y`, then `Enter`

---

## Step 4: Update Frontend API URL

Update the frontend to use your domain:

```bash
# Edit frontend main.dart
nano frontend/lib/main.dart
```

Find this line:
```dart
static const String apiBaseUrl = 'http://localhost:8000/api/counter/';
```

Change to:
```dart
static const String apiBaseUrl = 'https://yourdomain.com/api/counter/';
```

Save: `Ctrl+X`, then `Y`, then `Enter`

---

## Step 5: Set Up SSL with Let's Encrypt

### Install Certbot

```bash
sudo apt update
sudo apt install certbot python3-certbot-nginx -y
```

### Get SSL Certificate

**Important**: DNS must be pointing to your server first! Wait for DNS propagation.

```bash
# Stop nginx temporarily (if running)
docker compose -f docker-compose.prod.yml stop nginx

# Get SSL certificate
sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com
```

**Replace `yourdomain.com` with your actual domain!**

When prompted:
- **Email**: Enter your email (for renewal notices)
- **Agree to terms**: Type `A` and press Enter
- **Share email**: Type `Y` or `N` (your choice)

**Success message**: "Congratulations! Your certificate and chain have been saved..."

Certificates are saved in: `/etc/letsencrypt/live/yourdomain.com/`

---

## Step 6: Create Production Nginx Config

Create nginx configuration for your domain:

```bash
# Create directory if it doesn't exist
mkdir -p infra/nginx

# Create production nginx config
nano infra/nginx/nginx.prod.conf
```

**Add this configuration**:

```nginx
# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;

    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    # SSL settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Frontend (Flutter web app)
    location / {
        proxy_pass http://frontend:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
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

    # Media files
    location /media/ {
        alias /var/www/media/;
    }
}
```

**Replace `yourdomain.com` with your actual domain!**

Save: `Ctrl+X`, then `Y`, then `Enter`

---

## Step 7: Update docker-compose.prod.yml

Make sure your production compose file includes nginx with SSL:

```bash
# Check if docker-compose.prod.yml exists
cat docker-compose.prod.yml
```

If nginx isn't configured, update it. The nginx service should:

```yaml
nginx:
  image: nginx:alpine
  ports:
    - "80:80"
    - "443:443"
  volumes:
    - ./infra/nginx/nginx.prod.conf:/etc/nginx/nginx.conf
    - /etc/letsencrypt:/etc/letsencrypt:ro  # SSL certificates
    - backend_static:/var/www/static
    - backend_media:/var/www/media
  depends_on:
    - backend
    - frontend
  networks:
    - survey-network
```

---

## Step 8: Rebuild and Restart Services

```bash
# Rebuild frontend (with updated API URL)
docker compose -f docker-compose.prod.yml build frontend

# Restart all services
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d

# Verify containers are running
docker compose -f docker-compose.prod.yml ps
```

---

## Step 9: Test Your Domain

### Test HTTPS

Open in your browser:
- `https://yourdomain.com`
- `https://www.yourdomain.com`
- `https://yourdomain.com/api/counter/`

**Expected**: 
- ✅ Green lock icon (SSL working)
- ✅ Frontend loads
- ✅ Counter API works

### Test HTTP Redirect

Visit: `http://yourdomain.com`

**Expected**: Automatically redirects to `https://yourdomain.com`

---

## Step 10: Set Up Auto-Renewal for SSL

SSL certificates expire every 90 days. Set up auto-renewal:

```bash
# Test renewal (dry run)
sudo certbot renew --dry-run

# Add to crontab for automatic renewal
sudo crontab -e
```

**Add this line** (runs daily at 2 AM):
```
0 2 * * * certbot renew --quiet && docker compose -f /home/ubuntu/survey-web-app/docker-compose.prod.yml restart nginx
```

Save: `Ctrl+X`, then `Y`, then `Enter`

---

## Step 11: Update Security Group

Make sure your EC2 security group allows:

- **HTTP (80)**: From anywhere (for Let's Encrypt verification)
- **HTTPS (443)**: From anywhere
- **SSH (22)**: From your IP (for security)

**In AWS Console**:
1. EC2 → **Security Groups**
2. Select your security group
3. **Inbound rules** → **Edit inbound rules**
4. Ensure:
   - HTTP (80) from 0.0.0.0/0
   - HTTPS (443) from 0.0.0.0/0
   - SSH (22) from your IP

---

## Troubleshooting

### DNS not resolving
- Wait longer (can take up to 48 hours, usually 5-60 minutes)
- Check DNS propagation: `https://dnschecker.org`
- Verify A records are correct at your registrar

### SSL certificate fails
- Ensure DNS is pointing correctly first
- Ports 80 and 443 must be open in security group
- Try: `sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com --dry-run`

### Can't access via domain
- Check security group allows HTTP/HTTPS
- Verify DNS is pointing to correct IP
- Check nginx logs: `docker compose logs nginx`

### Mixed content errors (HTTP/HTTPS)
- Ensure frontend uses `https://` in API URLs
- Check CORS settings allow your domain
- Verify `ALLOWED_HOSTS` includes your domain

---

## Quick Checklist

- [ ] Elastic IP allocated and associated
- [ ] DNS A records pointing to EC2 IP
- [ ] DNS propagated (checked with dnschecker.org)
- [ ] `.env` updated with domain in `ALLOWED_HOSTS`
- [ ] Frontend API URL updated to use domain
- [ ] SSL certificate obtained
- [ ] Nginx configured with SSL
- [ ] Security group allows HTTP/HTTPS
- [ ] Services restarted
- [ ] Domain accessible via HTTPS
- [ ] Auto-renewal configured

---

## Summary

1. **Point DNS** → Your domain registrar
2. **Update .env** → Add domain to `ALLOWED_HOSTS`
3. **Get SSL** → Let's Encrypt with certbot
4. **Configure nginx** → Use SSL certificates
5. **Restart** → Rebuild and restart containers
6. **Test** → Visit `https://yourdomain.com`

Your app should now be live on your custom domain with HTTPS! 🎉
