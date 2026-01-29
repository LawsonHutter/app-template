# Deploy to dipoll.net - Step by Step

This guide walks you through deploying your app to `dipoll.net`.

## Prerequisites ✅

- ✅ EC2 instance running (IP: 52.73.150.104)
- ✅ Docker installed on EC2
- ✅ Project files on EC2 (`git pull` completed)
- ✅ Domain `dipoll.net` registered

---

## Step 1: Point DNS to Your EC2 IP

**At your domain registrar** (where you bought dipoll.net):

1. **Log in** to your domain registrar
2. **Go to DNS Management** (or DNS Settings)
3. **Add/Edit A Records**:

   **Record 1** (Root domain):
   - **Type**: A
   - **Name**: `@` (or leave blank, depends on registrar)
   - **Value**: `52.73.150.104` (your EC2 IP)
   - **TTL**: 3600 (or default)

   **Record 2** (www subdomain):
   - **Type**: A
   - **Name**: `www`
   - **Value**: `52.73.150.104` (same IP)
   - **TTL**: 3600

4. **Save changes**

### Verify DNS Propagation

**Wait 5-60 minutes** for DNS to propagate, then check:

- Visit: https://dnschecker.org
- Search for: `dipoll.net`
- Should show: `52.73.150.104` in multiple locations

Or test locally:
```bash
ping dipoll.net
# Should show: 52.73.150.104
```

---

## Step 2: Update Environment Variables on EC2

SSH into your EC2 instance:

```bash
ssh -i security/survey-app-key.pem ubuntu@52.73.150.104
```

Then:

```bash
cd ~/survey-web-app
nano .env
```

**Add/Update** (create the file if it doesn't exist):

```bash
SECRET_KEY=your-secret-key-here
DEBUG=0
ALLOWED_HOSTS=dipoll.net,www.dipoll.net,52.73.150.104
DATABASE_URL=postgresql://survey_user:password123@db:5432/survey_db
CORS_ALLOWED_ORIGINS=https://dipoll.net,https://www.dipoll.net
POSTGRES_PASSWORD=password123
```

**Important**: 
- Replace `your-secret-key-here` with a real Django secret key
- Change `password123` to a strong password

**Save**: `Ctrl+X`, then `Y`, then `Enter`

---

## Step 3: Update Frontend API URL

The frontend code has already been updated to use `https://dipoll.net/api/counter/`. 

**On EC2**, pull the latest changes:

```bash
cd ~/survey-web-app
git pull
```

This will get the updated `frontend/lib/main.dart` with the correct API URL.

---

## Step 4: Update Nginx Config

The nginx config has already been updated for `dipoll.net`. Verify on EC2:

```bash
cat infra/nginx/nginx.prod.conf | grep server_name
```

Should show: `dipoll.net www.dipoll.net`

---

## Step 5: Get SSL Certificate

**IMPORTANT**: Wait for DNS to propagate first! Check at https://dnschecker.org

Once DNS is pointing to your EC2 IP, get SSL certificate:

```bash
# Install certbot
sudo apt update
sudo apt install certbot python3-certbot-nginx -y

# Stop nginx temporarily (if running)
docker compose -f docker-compose.yml -f docker-compose.prod.yml stop nginx 2>/dev/null || true

# Get SSL certificate
sudo certbot certonly --standalone -d dipoll.net -d www.dipoll.net
```

**When prompted**:
- **Email**: Enter your email (for renewal notices)
- **Agree to terms**: Type `A` and press Enter
- **Share email**: Type `Y` or `N` (your choice)

**Success message**: "Congratulations! Your certificate and chain have been saved..."

Certificates are saved in: `/etc/letsencrypt/live/dipoll.net/`

---

## Step 6: Verify Security Group

**In AWS Console**:

1. Go to **EC2** → **Security Groups**
2. Select your security group
3. **Inbound rules** → **Edit inbound rules**
4. Ensure you have:
   - **HTTP (80)**: From `0.0.0.0/0` (for Let's Encrypt)
   - **HTTPS (443)**: From `0.0.0.0/0`
   - **SSH (22)**: From your IP (for security)

---

## Step 7: Deploy Everything

On EC2:

```bash
cd ~/survey-web-app

# Rebuild frontend (with updated API URL)
docker compose -f docker-compose.yml -f docker-compose.prod.yml build frontend

# Start all services
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Run migrations
docker compose -f docker-compose.yml -f docker-compose.prod.yml exec backend python manage.py migrate

# Check status
docker compose -f docker-compose.yml -f docker-compose.prod.yml ps
```

You should see:
- `survey-backend` - Running
- `survey-db` - Running
- `survey-frontend` - Running
- `survey-nginx` - Running

---

## Step 8: Test Your Domain

Visit in your browser:
- ✅ `https://dipoll.net`
- ✅ `https://www.dipoll.net`
- ✅ `https://dipoll.net/api/counter/`

**Expected**:
- Green lock icon (SSL working)
- Frontend loads
- Counter button works
- API returns JSON

---

## Step 9: Set Up Auto-Renewal for SSL

SSL certificates expire every 90 days. Set up auto-renewal:

```bash
# Test renewal (dry run)
sudo certbot renew --dry-run

# Add to crontab
sudo crontab -e
```

**Add this line** (runs daily at 2 AM):
```
0 2 * * * certbot renew --quiet && docker compose -f /home/ubuntu/survey-web-app/docker-compose.yml -f /home/ubuntu/survey-web-app/docker-compose.prod.yml restart nginx
```

Save: `Ctrl+X`, `Y`, `Enter`

---

## Troubleshooting

### DNS not resolving
- Wait longer (can take up to 48 hours, usually 5-60 minutes)
- Check: https://dnschecker.org
- Verify A records are correct at your registrar

### SSL certificate fails
- Ensure DNS is pointing correctly first
- Ports 80 and 443 must be open in security group
- Try: `sudo certbot certonly --standalone -d dipoll.net -d www.dipoll.net --dry-run`

### Can't access via domain
- Check security group allows HTTP/HTTPS
- Verify DNS is pointing to correct IP: `ping dipoll.net`
- Check nginx logs: `docker compose logs nginx`

### Mixed content errors
- Ensure frontend uses `https://` in API URLs (already done)
- Check CORS settings in `.env`
- Verify `ALLOWED_HOSTS` includes `dipoll.net`

### Backend not responding
- Check backend logs: `docker compose logs backend`
- Verify database is running: `docker compose ps`
- Check migrations: `docker compose exec backend python manage.py migrate`

---

## Quick Checklist

- [ ] DNS A records pointing to `52.73.150.104`
- [ ] DNS propagated (checked at dnschecker.org)
- [ ] `.env` file created with `dipoll.net` in `ALLOWED_HOSTS`
- [ ] Frontend code pulled (with updated API URL)
- [ ] SSL certificate obtained
- [ ] Security group allows HTTP/HTTPS
- [ ] Docker containers running
- [ ] Migrations run
- [ ] Domain accessible via HTTPS
- [ ] Auto-renewal configured

---

## Summary

1. **Point DNS** → Your domain registrar (A records to `52.73.150.104`)
2. **Wait for DNS** → Check at dnschecker.org
3. **Update .env** → Add `dipoll.net` to `ALLOWED_HOSTS`
4. **Get SSL** → Let's Encrypt with certbot
5. **Deploy** → `docker compose up -d`
6. **Test** → Visit `https://dipoll.net`

Your app should now be live on `https://dipoll.net`! 🎉
