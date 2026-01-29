# Deploy After EC2 Restart - Quick Steps

After restarting your EC2 instance, follow these steps to get dipoll.net working again.

## Step 1: Connect to EC2

```powershell
# Use the connect script
.\scripts\connect-ec2.ps1

# Or manually
ssh -i security\survey-app-key.pem ubuntu@52.73.150.104
```

**Note**: If your IP changed after restart, update the IP in the command.

---

## Step 2: Navigate to Project Directory

```bash
cd ~/survey-web-app
```

---

## Step 3: Pull Latest Code (if needed)

```bash
git pull
```

This ensures you have the latest code with dipoll.net configuration.

---

## Step 4: Check Docker is Running

```bash
docker --version
docker compose version
```

If Docker isn't installed, install it:
```bash
sudo apt update
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu
newgrp docker
sudo apt install docker-compose-plugin -y
```

---

## Step 5: Create/Check .env File

```bash
nano .env
```

**Add/Verify this content** (update SECRET_KEY and POSTGRES_PASSWORD):

```bash
SECRET_KEY=your-secret-key-here
DEBUG=0
ALLOWED_HOSTS=dipoll.net,www.dipoll.net,52.73.150.104
DATABASE_URL=postgresql://survey_user:password123@db:5432/survey_db
CORS_ALLOWED_ORIGINS=https://dipoll.net,https://www.dipoll.net
POSTGRES_PASSWORD=password123
```

**Save**: `Ctrl+X`, then `Y`, then `Enter`

---

## Step 6: Check SSL Certificate

```bash
# Check if certificate exists
sudo ls -la /etc/letsencrypt/live/dipoll.net/
```

**If certificate exists**: Skip to Step 7

**If certificate doesn't exist**: Get it now:

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx -y

# Stop any services using port 80
docker compose -f docker-compose.yml -f docker-compose.prod.yml down

# Get SSL certificate
sudo certbot certonly --standalone -d dipoll.net -d www.dipoll.net
```

**When prompted**:
- Email: Enter your email
- Agree: Type `A` and Enter
- Share email: `Y` or `N`

---

## Step 7: Deploy Everything

```bash
# Build and start all services
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

# Wait a moment for containers to start
sleep 10

# Check status
docker compose -f docker-compose.yml -f docker-compose.prod.yml ps
```

You should see:
- `survey-backend` - Running
- `survey-db` - Running  
- `survey-frontend` - Running
- `survey-nginx` - Running

---

## Step 8: Run Migrations

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml exec backend python manage.py migrate
```

---

## Step 9: Verify Everything Works

```bash
# Check logs
docker compose -f docker-compose.yml -f docker-compose.prod.yml logs --tail=50

# Test backend API
curl http://localhost:8000/api/counter/

# Check nginx
curl -I http://localhost
```

---

## Step 10: Test in Browser

Visit:
- `https://dipoll.net` ✅
- `https://www.dipoll.net` ✅
- `https://dipoll.net/api/counter/` ✅

---

## Troubleshooting

### Containers won't start
```bash
# Check logs
docker compose -f docker-compose.yml -f docker-compose.prod.yml logs

# Restart specific service
docker compose -f docker-compose.yml -f docker-compose.prod.yml restart nginx
```

### Can't connect to domain
- Check DNS is still pointing to your IP: `ping dipoll.net`
- Verify security group allows HTTP (80) and HTTPS (443)
- Check nginx logs: `docker compose logs nginx`

### SSL certificate issues
- Verify certificate exists: `sudo ls /etc/letsencrypt/live/dipoll.net/`
- Check nginx config has correct paths
- Restart nginx: `docker compose restart nginx`

---

## Quick One-Liner (After Initial Setup)

If everything was already configured before restart:

```bash
cd ~/survey-web-app && \
git pull && \
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d && \
docker compose -f docker-compose.yml -f docker-compose.prod.yml exec backend python manage.py migrate
```

---

## Checklist

- [ ] Connected to EC2
- [ ] In project directory (`~/survey-web-app`)
- [ ] Pulled latest code
- [ ] Docker installed and running
- [ ] `.env` file created with correct values
- [ ] SSL certificate exists (or obtained)
- [ ] All containers running
- [ ] Migrations run
- [ ] Domain accessible in browser
