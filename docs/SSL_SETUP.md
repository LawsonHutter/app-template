# SSL Setup (HTTPS) with Let's Encrypt

Set up free HTTPS on your EC2 instance using Let's Encrypt (Certbot).

## Prerequisites

- Domain pointing to EC2 (A records for `@` and `www`)
- HTTP working at `http://yourdomain.com`
- EC2 security group allows **port 443** (HTTPS)

---

## Quick Setup (Automated)

From your project root:

```powershell
.\scripts\setup-ssl.ps1
```

The script will:
1. Create nginx HTTPS config from template
2. SSH to EC2, stop nginx, install Certbot, obtain certificate
3. Commit and push the nginx config and docker-compose.ssl.yml
4. Enable SSL in Docker on EC2

It does **not** rebuild or deploy the frontend by default. Run with `-RebuildAndDeploy` to also rebuild the frontend for HTTPS and deploy. You'll be prompted for an email if `SSL_EMAIL` isn't in `security/deployment.config`.

---

## Manual Setup

### Step 1: Get the Certificate on EC2

SSH to EC2:

```powershell
.\scripts\connect-ec2.ps1
```

On the EC2 instance:

```bash
cd ~/app

# Stop nginx so Certbot can use port 80
docker compose -f docker-compose.yml -f docker-compose.prod.yml stop nginx

# Install Certbot
sudo apt update
sudo apt install certbot -y

# Get certificate (replace lawsonhutter.com with YOUR domain)
sudo certbot certonly --standalone -d lawsonhutter.com -d www.lawsonhutter.com
```

When prompted: enter your email, agree to terms. Certificates are saved under `/etc/letsencrypt/live/yourdomain.com/`.

---

## Step 2: Add HTTPS Nginx Config

On your **local machine**:

1. Copy the template and replace the domain:
   ```powershell
   copy infra\nginx\nginx.https.conf.example infra\nginx\nginx.https.conf
   ```
2. Open `infra/nginx/nginx.https.conf` and replace **every** `yourdomain.com` with your real domain (e.g. `lawsonhutter.com`).
3. Commit and push:
   ```powershell
   git add infra/nginx/nginx.https.conf
   git commit -m "Add HTTPS nginx config"
   git push origin main
   ```

---

## Step 3: Enable SSL in Docker on EC2

On EC2, pull the latest code and start the stack with the SSL override:

```bash
cd ~/app
git pull origin main

# Start with SSL (uses nginx.https.conf and mounts /etc/letsencrypt)
docker compose -f docker-compose.yml -f docker-compose.prod.yml -f docker-compose.ssl.yml up -d
```

Check that nginx is running and listening on 443:

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml -f docker-compose.ssl.yml ps
sudo ss -tulpn | grep 443
```

---

## Step 4: Rebuild Frontend for HTTPS

On your **local machine**, set the API URL to HTTPS and rebuild:

**Option A – Use config**

1. In `security/deployment.config` set:
   ```
   USE_HTTPS=true
   ```
2. Build and deploy:
   ```powershell
   .\scripts\build-frontend-local.ps1
   git add frontend/build
   git commit -m "Build frontend for HTTPS"
   git push origin main
   .\scripts\auto-deploy-ec2.ps1
   ```

**Option B – Override URL once**

```powershell
.\scripts\build-frontend-local.ps1 -ApiUrl "https://lawsonhutter.com/api/counter/"
git add frontend/build
git commit -m "Build frontend for HTTPS"
git push origin main
.\scripts\auto-deploy-ec2.ps1
```

After deploy, use the SSL compose file on EC2 so nginx keeps using HTTPS:

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml -f docker-compose.ssl.yml up -d
```

---

## Step 5: Deployments After SSL

With `USE_HTTPS=true` in `security/deployment.config`, `.\scripts\auto-deploy-ec2.ps1` automatically uses the SSL compose file. Just run:

```powershell
.\scripts\auto-deploy-ec2.ps1
```

To deploy manually on EC2:

```bash
cd ~/app
git pull origin main
docker compose -f docker-compose.yml -f docker-compose.prod.yml -f docker-compose.ssl.yml up -d --build
```

---

## Renewing Certificates

Let's Encrypt certs expire after 90 days. Renew on EC2:

```bash
cd ~/app
docker compose -f docker-compose.yml -f docker-compose.prod.yml -f docker-compose.ssl.yml stop nginx
sudo certbot renew
docker compose -f docker-compose.yml -f docker-compose.prod.yml -f docker-compose.ssl.yml start nginx
```

To renew automatically, add a cron job on EC2:

```bash
sudo crontab -e
```

Add:

```
0 3 * * * certbot renew --quiet --deploy-hook "cd /home/ubuntu/app && docker compose -f docker-compose.yml -f docker-compose.prod.yml -f docker-compose.ssl.yml restart nginx"
```

---

## Troubleshooting

| Problem | What to check |
|--------|----------------|
| Certificate errors in browser | Domain in nginx.https.conf matches the cert (e.g. `lawsonhutter.com`). Cert paths: `/etc/letsencrypt/live/yourdomain.com/`. |
| Connection refused on 443 | EC2 security group allows inbound 443. Nginx is running: `docker compose ... ps`. |
| Certbot says port 80 in use | Stop nginx before running `certbot certonly --standalone`. |
| Page is HTTPS but API fails | Rebuild frontend with HTTPS API URL (`USE_HTTPS=true` or `-ApiUrl "https://..."`) and redeploy. |

---

## Quick Reference

| Item | Value |
|------|--------|
| Certificates on EC2 | `/etc/letsencrypt/live/yourdomain.com/` |
| HTTPS config | `infra/nginx/nginx.https.conf` (from `.example`) |
| Compose with SSL | `docker compose -f docker-compose.yml -f docker-compose.prod.yml -f docker-compose.ssl.yml up -d` |
| Frontend HTTPS | `USE_HTTPS=true` in deployment.config, then `build-frontend-local.ps1` |
