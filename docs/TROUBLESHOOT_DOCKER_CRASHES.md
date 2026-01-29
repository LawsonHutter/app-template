# Troubleshoot Docker Crashes

If Docker containers are crashing, follow these steps to diagnose and fix.

## Step 1: Check Container Status

```bash
# See which containers are running/crashed
docker compose -f docker-compose.yml -f docker-compose.prod.yml ps -a

# Check Docker logs
docker compose -f docker-compose.yml -f docker-compose.prod.yml logs --tail=100
```

Look for:
- Containers with status "Exited" or "Restarting"
- Error messages in logs

---

## Step 2: Check Individual Service Logs

```bash
# Backend logs
docker compose -f docker-compose.yml -f docker-compose.prod.yml logs backend

# Frontend logs
docker compose -f docker-compose.yml -f docker-compose.prod.yml logs frontend

# Nginx logs
docker compose -f docker-compose.yml -f docker-compose.prod.yml logs nginx

# Database logs
docker compose -f docker-compose.yml -f docker-compose.prod.yml logs db
```

---

## Step 3: Common Issues and Fixes

### Issue 1: Backend Can't Connect to Database

**Symptoms:**
- Backend container keeps restarting
- Logs show: "could not connect to server" or "connection refused"

**Fix:**
```bash
# Check database is running
docker compose -f docker-compose.yml -f docker-compose.prod.yml ps db

# Restart database
docker compose -f docker-compose.yml -f docker-compose.prod.yml restart db

# Wait a few seconds, then restart backend
docker compose -f docker-compose.yml -f docker-compose.prod.yml restart backend
```

---

### Issue 2: Port Already in Use

**Symptoms:**
- Error: "port is already allocated" or "address already in use"

**Fix:**
```bash
# Find what's using the port
sudo lsof -i :80
sudo lsof -i :443
sudo lsof -i :8000

# Stop conflicting services
sudo systemctl stop nginx  # if system nginx is running
docker compose -f docker-compose.yml -f docker-compose.prod.yml down

# Then start again
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

---

### Issue 3: Missing Environment Variables

**Symptoms:**
- Backend crashes on startup
- Logs show: "SECRET_KEY" or "ALLOWED_HOSTS" errors

**Fix:**
```bash
# Check .env file exists
ls -la .env

# Create/update .env file
nano .env
```

Make sure it has:
```bash
SECRET_KEY=your-secret-key-here
DEBUG=0
ALLOWED_HOSTS=dipoll.net,www.dipoll.net,52.73.150.104
DATABASE_URL=postgresql://survey_user:password123@db:5432/survey_db
CORS_ALLOWED_ORIGINS=https://dipoll.net,https://www.dipoll.net
POSTGRES_PASSWORD=password123
```

Then restart:
```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml restart backend
```

---

### Issue 4: SSL Certificate Missing

**Symptoms:**
- Nginx crashes
- Logs show: "SSL certificate not found"

**Fix:**
```bash
# Check certificate exists
sudo ls -la /etc/letsencrypt/live/dipoll.net/

# If missing, get it (stop containers first)
docker compose -f docker-compose.yml -f docker-compose.prod.yml down
sudo systemctl stop nginx
sudo certbot certonly --standalone -d dipoll.net -d www.dipoll.net
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

---

### Issue 5: Out of Memory/Disk Space

**Symptoms:**
- Containers crash randomly
- "No space left on device" errors

**Fix:**
```bash
# Check disk space
df -h

# Check memory
free -h

# Clean up Docker
docker system prune -a
docker volume prune
```

---

### Issue 6: Build Failures

**Symptoms:**
- Build fails during `docker compose build`
- Errors about missing files or dependencies

**Fix:**
```bash
# Rebuild without cache
docker compose -f docker-compose.yml -f docker-compose.prod.yml build --no-cache

# Check if all files are present
ls -la backend/
ls -la frontend/
```

---

## Step 4: Restart Everything Fresh

If nothing else works, do a complete restart:

```bash
# Stop everything
docker compose -f docker-compose.yml -f docker-compose.prod.yml down

# Remove volumes (⚠️ deletes database data!)
# docker compose -f docker-compose.yml -f docker-compose.prod.yml down -v

# Rebuild and start
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

# Check status
docker compose -f docker-compose.yml -f docker-compose.prod.yml ps
```

---

## Step 5: Check System Resources

```bash
# Check Docker is running
sudo systemctl status docker

# Check system resources
htop
# or
top

# Check Docker logs
sudo journalctl -u docker.service
```

---

## Quick Diagnostic Commands

```bash
# See all containers (including stopped)
docker ps -a

# See container resource usage
docker stats

# Inspect a specific container
docker inspect survey-backend

# Check Docker network
docker network ls
docker network inspect survey-web-app_survey-network
```

---

## Get Help

If still crashing, collect this information:

```bash
# Container status
docker compose -f docker-compose.yml -f docker-compose.prod.yml ps -a > container-status.txt

# All logs
docker compose -f docker-compose.yml -f docker-compose.prod.yml logs > all-logs.txt

# System info
docker info > docker-info.txt
df -h > disk-space.txt
free -h > memory.txt
```

Share these files for troubleshooting.
