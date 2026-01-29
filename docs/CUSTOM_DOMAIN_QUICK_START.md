# Deploy to Custom Domain - Quick Start

After Docker is set up, follow these steps to deploy to your custom domain.

## Step-by-Step Process

### 1. Point DNS to Your EC2 IP

**At your domain registrar** (GoDaddy, Namecheap, etc.):

1. Go to **DNS Management**
2. Add **A Record**:
   - **Name**: `@` (or blank)
   - **Value**: `54.157.14.153` (your EC2 IP)
3. Add **A Record** for www:
   - **Name**: `www`
   - **Value**: `54.157.14.153`

**Wait 5-60 minutes** for DNS to propagate.

---

### 2. Update Environment Variables

On your EC2 server:

```bash
cd ~/survey-web-app
nano .env
```

**Update** (replace `yourdomain.com` with your actual domain):

```bash
SECRET_KEY=your-secret-key-here
DEBUG=0
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com,54.157.14.153
DATABASE_URL=postgresql://survey_user:password123@db:5432/survey_db
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
POSTGRES_PASSWORD=password123
```

Save: `Ctrl+X`, `Y`, `Enter`

---

### 3. Update Frontend API URL

```bash
nano frontend/lib/main.dart
```

Find and change:
```dart
// From:
static const String apiBaseUrl = 'http://localhost:8000/api/counter/';

// To:
static const String apiBaseUrl = 'https://yourdomain.com/api/counter/';
```

Save: `Ctrl+X`, `Y`, `Enter`

---

### 4. Update Nginx Config with Your Domain

```bash
nano infra/nginx/nginx.prod.conf
```

**Replace `yourdomain.com`** in two places:
- Line 10: `server_name yourdomain.com www.yourdomain.com;`
- Line 16: `server_name yourdomain.com www.yourdomain.com;`
- Line 19: `/etc/letsencrypt/live/yourdomain.com/fullchain.pem`
- Line 20: `/etc/letsencrypt/live/yourdomain.com/privkey.pem`

Save: `Ctrl+X`, `Y`, `Enter`

---

### 5. Get SSL Certificate

**Wait for DNS to propagate first!** Check: https://dnschecker.org

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx -y

# Stop nginx temporarily
docker compose -f docker-compose.prod.yml stop nginx

# Get SSL certificate (replace with your domain)
sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com
```

**When prompted**:
- Email: Enter your email
- Agree: Type `A` and Enter
- Share email: `Y` or `N`

---

### 6. Deploy Everything

```bash
# Rebuild frontend (with new API URL)
docker compose -f docker-compose.yml -f docker-compose.prod.yml build frontend

# Start all services
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Run migrations
docker compose -f docker-compose.yml -f docker-compose.prod.yml exec backend python manage.py migrate

# Check status
docker compose -f docker-compose.yml -f docker-compose.prod.yml ps
```

---

### 7. Test Your Domain

Visit in browser:
- `https://yourdomain.com` ✅
- `https://www.yourdomain.com` ✅
- `https://yourdomain.com/api/counter/` ✅

---

### 8. Set Up Auto-Renewal

```bash
# Test renewal
sudo certbot renew --dry-run

# Add to crontab
sudo crontab -e
```

Add this line:
```
0 2 * * * certbot renew --quiet && docker compose -f /home/ubuntu/survey-web-app/docker-compose.yml -f /home/ubuntu/survey-web-app/docker-compose.prod.yml restart nginx
```

---

## Important Notes

1. **DNS must propagate first** before getting SSL certificate
2. **Security group** must allow HTTP (80) and HTTPS (443)
3. **Replace `yourdomain.com`** everywhere with your actual domain
4. **Use both compose files**: `-f docker-compose.yml -f docker-compose.prod.yml`

---

## Troubleshooting

**Can't get SSL certificate?**
- Wait for DNS to propagate (check dnschecker.org)
- Ensure ports 80 and 443 are open in security group
- Verify DNS is pointing to correct IP

**Domain not loading?**
- Check security group allows HTTP/HTTPS
- Verify nginx container is running: `docker ps`
- Check logs: `docker compose logs nginx`

**Mixed content errors?**
- Ensure frontend uses `https://` in API URLs
- Check CORS settings

---

**Full detailed guide**: See `docs/DEPLOY_CUSTOM_DOMAIN.md`
