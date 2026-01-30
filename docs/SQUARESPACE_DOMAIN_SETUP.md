# Squarespace Domain Setup for EC2

This guide explains how to point your Squarespace domain to your EC2 instance.

## How It Works

```
User types: myapp.com
         ↓
Squarespace DNS (you configure this)
         ↓
A Record: myapp.com → 52.201.192.84 (your EC2 Elastic IP)
         ↓
Your EC2 Instance receives the request
         ↓
Nginx routes to your app
```

**Key concept**: Squarespace acts as your DNS provider. You create "A records" that tell the internet "when someone visits myapp.com, send them to IP address X".

---

## Prerequisites

1. **Domain purchased through Squarespace** (or transferred to Squarespace)
2. **EC2 Elastic IP** (static IP that doesn't change when you restart EC2)
   - Get this from AWS Console → EC2 → Elastic IPs → Allocate
   - Associate it with your EC2 instance
   - Update `EC2_ELASTIC_IP` in `security/deployment.config`

---

## Step 1: Get Your Elastic IP

If you haven't already:

1. **AWS Console** → **EC2** → **Elastic IPs** (left sidebar)
2. Click **Allocate Elastic IP address**
3. Click **Allocate**
4. Select the new Elastic IP → **Actions** → **Associate Elastic IP address**
5. Choose your EC2 instance → **Associate**

**Note your Elastic IP** (e.g., `52.201.192.84`) - you'll use this in Squarespace.

---

## Step 2: Configure Squarespace DNS

1. **Log in to Squarespace** → Go to your domain
2. **Settings** → **Domains** → Click your domain
3. **DNS Settings** (or "Advanced DNS Settings")

### Add A Records

Add these DNS records:

| Type | Host | Data/Value | TTL |
|------|------|------------|-----|
| **A** | `@` | `52.201.192.84` (your Elastic IP) | Automatic or 3600 |
| **A** | `www` | `52.201.192.84` (your Elastic IP) | Automatic or 3600 |

**What these mean:**
- `@` = the root domain (e.g., `myapp.com`)
- `www` = the www subdomain (e.g., `www.myapp.com`)
- Both point to your EC2 IP

### Alternative: CNAME for www

Instead of an A record for www, you can use a CNAME:

| Type | Host | Data/Value | TTL |
|------|------|------------|-----|
| **A** | `@` | `52.201.192.84` | Automatic |
| **CNAME** | `www` | `myapp.com` | Automatic |

This makes `www.myapp.com` redirect to `myapp.com`.

---

## Step 3: Wait for DNS Propagation

DNS changes take time to propagate globally:
- **Typically**: 5-30 minutes
- **Maximum**: Up to 48 hours (rare)

**Check propagation:**
- Use [whatsmydns.net](https://www.whatsmydns.net/) to check if your domain resolves to your IP
- Or run: `nslookup myapp.com`

---

## Step 4: Update Your EC2 Configuration

### Update deployment.config

```
EC2_ELASTIC_IP=52.201.192.84
DOMAIN=myapp.com
```

### Update nginx config

The `auto-deploy-ec2.ps1` script updates nginx automatically, but if you need to do it manually:

SSH to EC2:
```bash
ssh -i security/counter-app-key.pem ubuntu@52.201.192.84
```

Edit nginx config:
```bash
nano ~/app/infra/nginx/nginx.http.conf
```

Update `server_name`:
```nginx
server {
    listen 80;
    server_name myapp.com www.myapp.com;
    
    # ... rest of config
}
```

Restart nginx:
```bash
cd ~/app
docker compose -f docker-compose.yml -f docker-compose.prod.yml restart nginx
```

### Update CORS and Allowed Hosts

In your EC2 `.env` file (`~/app/.env`):

```bash
ALLOWED_HOSTS=myapp.com,www.myapp.com,52.201.192.84
CORS_ALLOWED_ORIGINS=http://myapp.com,https://myapp.com,https://www.myapp.com
```

Then restart:
```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml restart backend
```

---

## Step 5: Test Your Domain

After DNS propagation:

1. **Visit your domain**: `http://myapp.com`
2. **Test API**: `http://myapp.com/api/counter/`

---

## Step 6: Set Up SSL (HTTPS)

For production, you need SSL. Use Let's Encrypt (free):

SSH to EC2:
```bash
ssh -i security/counter-app-key.pem ubuntu@52.201.192.84
```

Install Certbot and get certificate:
```bash
# Stop nginx temporarily (certbot needs port 80)
cd ~/app
docker compose -f docker-compose.yml -f docker-compose.prod.yml stop nginx

# Install certbot
sudo apt update
sudo apt install certbot -y

# Get certificate
sudo certbot certonly --standalone -d myapp.com -d www.myapp.com

# Restart nginx
docker compose -f docker-compose.yml -f docker-compose.prod.yml start nginx
```

Then update nginx config to use SSL (see `docs/DEPLOY_CUSTOM_DOMAIN.md`).

---

## Squarespace DNS vs External DNS

### If Your Domain is on Squarespace
You manage DNS in **Squarespace Settings → Domains → DNS Settings**.

### If You Want to Use External DNS (Route 53, Cloudflare, etc.)
1. In Squarespace: **Domains** → Your domain → **DNS Settings**
2. Change nameservers to your external provider
3. Manage DNS records in the external provider

**Most users**: Just use Squarespace DNS (simpler).

---

## Common Issues

### Domain shows Squarespace site, not EC2
- Check A record is set correctly
- Wait for DNS propagation
- Clear browser cache

### Connection refused
- Check EC2 security group allows HTTP (80) and HTTPS (443)
- Check nginx is running: `docker compose ps`

### SSL certificate errors
- Make sure DNS is fully propagated before running certbot
- Certbot needs to verify domain ownership via HTTP

### www works but root domain doesn't (or vice versa)
- Make sure both `@` and `www` records are set
- Check nginx `server_name` includes both

---

## Quick Reference

### Squarespace DNS Records for EC2

| Type | Host | Value | Purpose |
|------|------|-------|---------|
| A | @ | Your Elastic IP | Root domain (myapp.com) |
| A | www | Your Elastic IP | www subdomain |

### deployment.config

```
EC2_ELASTIC_IP=52.201.192.84
DOMAIN=myapp.com
KEY_PATH=security/counter-app-key.pem
```

### Deploy with domain

```powershell
.\scripts\auto-deploy-ec2.ps1
```

The script reads `DOMAIN` from config and updates nginx automatically.

---

## Timeline

1. **Configure Squarespace DNS** (5 minutes)
2. **Wait for propagation** (5-30 minutes)
3. **Run auto-deploy** (5-10 minutes)
4. **Set up SSL** (5 minutes)

**Total: ~30-60 minutes**
