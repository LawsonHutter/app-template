# Fix Port 80 Already in Use for Certbot

When getting an SSL certificate, certbot needs to use port 80 temporarily. If something else is using it, you need to stop it first.

## Quick Fix

### Step 1: Find what's using port 80

```bash
sudo lsof -i :80
# or
sudo netstat -tulpn | grep :80
# or
sudo ss -tulpn | grep :80
```

### Step 2: Stop the service

**If it's nginx:**
```bash
sudo systemctl stop nginx
# or if using Docker
docker compose -f docker-compose.yml -f docker-compose.prod.yml stop nginx
```

**If it's Apache:**
```bash
sudo systemctl stop apache2
```

**If it's another Docker container:**
```bash
docker ps
# Find the container using port 80, then:
docker stop <container-name>
```

### Step 3: Get SSL certificate

```bash
sudo certbot certonly --standalone -d dipoll.net -d www.dipoll.net
```

### Step 4: Restart your services

After getting the certificate:

```bash
# If using Docker
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

---

## Alternative: Use nginx plugin (if nginx is running)

If you want to keep nginx running, use the nginx plugin instead:

```bash
sudo certbot certonly --nginx -d dipoll.net -d www.dipoll.net
```

This works with nginx running, but requires nginx to be configured first.
