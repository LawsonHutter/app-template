# EC2 Deployment Steps - What to Do Now

You're connected to your EC2 instance! Follow these steps to deploy your counter app.

## Current Status ✅
- ✅ EC2 instance running
- ✅ Connected via SSH
- ✅ Ready to install and deploy

---

## Step 1: Update System

```bash
sudo apt update && sudo apt upgrade -y
```

This updates all packages on your Ubuntu server.

---

## Step 2: Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group (so you don't need sudo)
sudo usermod -aG docker ubuntu
newgrp docker

# Install Docker Compose
sudo apt install docker-compose-plugin -y

# Verify installation
docker --version
docker compose version
```

**Expected output**: Docker version numbers

---

## Step 3: Transfer Your Code to EC2

You have two options:

### Option A: Clone from GitHub (Recommended)

**If your code is on GitHub:**

```bash
# Install git
sudo apt install git -y

# Clone your repository
git clone https://github.com/yourusername/survey-web-app.git
cd survey-web-app
```

**Replace `yourusername` with your GitHub username!**

### Option B: Copy Files from Your Computer

**From your local Windows machine** (open a NEW PowerShell window):

```powershell
# Navigate to your project
cd C:\Users\Lawson\Desktop\Github\survey-web-app

# Copy files to EC2 (replace with your IP)
scp -i security\survey-app-key.pem -r * ubuntu@54.157.14.153:~/survey-web-app/
```

**Note**: This copies all files. Make sure `.gitignore` is working (it should exclude `db.sqlite3`, `venv/`, etc.)

---

## Step 4: Set Up Environment Variables

On your EC2 server:

```bash
cd ~/survey-web-app  # or wherever you put the files

# Create .env file for production
nano .env
```

**Add these lines** (press `Ctrl+X`, then `Y`, then `Enter` to save):

```bash
SECRET_KEY=your-generated-secret-key-here
DEBUG=0
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com,54.157.14.153
DATABASE_URL=postgresql://survey_user:strong-password@db:5432/survey_db
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
POSTGRES_PASSWORD=strong-password-here
```

**Generate SECRET_KEY** (on your local machine):
```powershell
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Copy the output and use it as `SECRET_KEY` in the `.env` file.

---

## Step 5: Set Up Production Docker Compose

The `docker-compose.prod.yml` should already exist. Verify it:

```bash
cat docker-compose.prod.yml
```

If it doesn't exist or needs updating, create it (see `docs/DEPLOY_AWS.md`).

---

## Step 6: Build and Start Services

```bash
# Build and start all services
docker compose -f docker-compose.prod.yml up -d --build

# Check if containers are running
docker compose -f docker-compose.prod.yml ps
```

**Expected**: You should see `backend`, `db`, `frontend` containers running.

---

## Step 7: Run Database Migrations

```bash
# Run migrations
docker compose -f docker-compose.prod.yml exec backend python manage.py migrate

# Create superuser (optional, for admin access)
docker compose -f docker-compose.prod.yml exec backend python manage.py createsuperuser
```

---

## Step 8: Collect Static Files

```bash
docker compose -f docker-compose.prod.yml exec backend python manage.py collectstatic --noinput
```

---

## Step 9: Test Your App

```bash
# Check if backend is responding
curl http://localhost:8000/api/

# Check if counter API works
curl http://localhost:8000/api/counter/
```

**From your browser** (on your local computer):
- Visit: `http://54.157.14.153:8000/api/` (backend)
- Visit: `http://54.157.14.153:3000` (frontend, if nginx is set up)

---

## Step 10: Set Up Domain (Optional)

If you have a domain:

1. **Point DNS to your EC2 IP**:
   - Go to your domain registrar
   - Add A record: `@` → `54.157.14.153`
   - Add A record: `www` → `54.157.14.153`

2. **Set up SSL with Let's Encrypt**:
   ```bash
   # Install certbot
   sudo apt install certbot python3-certbot-nginx -y
   
   # Get SSL certificate (after DNS is pointing)
   sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com
   ```

3. **Update nginx config** to use SSL (see `docs/DEPLOY_AWS.md`)

---

## Quick Commands Reference

```bash
# View logs
docker compose -f docker-compose.prod.yml logs -f

# Stop services
docker compose -f docker-compose.prod.yml down

# Restart services
docker compose -f docker-compose.prod.yml restart

# View container status
docker compose -f docker-compose.prod.yml ps

# Execute commands in container
docker compose -f docker-compose.prod.yml exec backend python manage.py shell
```

---

## Troubleshooting

### Can't connect to app
- Check security group allows HTTP (80) and HTTPS (443)
- Check containers are running: `docker ps`
- Check logs: `docker compose logs`

### Database errors
- Ensure database container is running
- Check `DATABASE_URL` in `.env`
- Run migrations again

### Port already in use
- Check what's using the port: `sudo netstat -tulpn | grep :8000`
- Stop conflicting services

---

## Next Steps

1. ✅ Install Docker (Step 2)
2. ✅ Transfer code (Step 3)
3. ✅ Set up environment (Step 4)
4. ✅ Deploy (Step 6)
5. ✅ Test (Step 9)
6. ✅ Set up domain (Step 10)

**Start with Step 1** (update system) and work through each step!
