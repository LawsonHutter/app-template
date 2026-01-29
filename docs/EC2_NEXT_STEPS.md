# EC2 Deployment - Next Steps After Cloning

You've cloned your code! Here's what to do next on your EC2 server.

## Current Status ✅
- ✅ Code cloned to EC2
- ✅ Ready to deploy

---

## Step 1: Navigate to Project Directory

```bash
cd survey-web-app
ls  # Verify files are there
```

You should see: `backend/`, `frontend/`, `docker-compose.yml`, etc.

---

## Step 2: Install Docker (If Not Done)

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

**Expected output**: Version numbers for Docker and Docker Compose

---

## Step 3: Create Production Environment File

```bash
# Create .env file
nano .env
```

**Add these lines** (press `Ctrl+X`, then `Y`, then `Enter` to save):

```bash
SECRET_KEY=your-secret-key-here
DEBUG=0
ALLOWED_HOSTS=54.157.14.153
DATABASE_URL=postgresql://survey_user:password123@db:5432/survey_db
CORS_ALLOWED_ORIGINS=http://54.157.14.153
POSTGRES_PASSWORD=password123
```

**Generate SECRET_KEY** (run this on your local Windows machine):
```powershell
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Copy the output and replace `your-secret-key-here` in the `.env` file.

**Note**: Change `password123` to a strong password!

---

## Step 4: Check/Update docker-compose.prod.yml

Verify the production compose file exists:

```bash
cat docker-compose.prod.yml
```

If it doesn't exist or needs updating, we'll create it. The file should use:
- Production target for backend
- PostgreSQL database
- Frontend with nginx
- Proper environment variables

---

## Step 5: Build and Start Services

```bash
# Build and start all containers
docker compose -f docker-compose.prod.yml up -d --build

# Watch the build process (takes 5-10 minutes first time)
docker compose -f docker-compose.prod.yml logs -f
```

Press `Ctrl+C` to stop watching logs (containers keep running).

---

## Step 6: Check Container Status

```bash
docker compose -f docker-compose.prod.yml ps
```

**Expected**: All containers should show "Up" status:
- `backend` - Running
- `db` - Running  
- `frontend` - Running

---

## Step 7: Run Database Migrations

```bash
# Run migrations
docker compose -f docker-compose.prod.yml exec backend python manage.py migrate

# You should see:
# Operations to perform:
#   Apply all migrations: admin, auth, click_counter, contenttypes, sessions
# Running migrations:
#   Applying click_counter.0001_initial... OK
```

---

## Step 8: Collect Static Files

```bash
docker compose -f docker-compose.prod.yml exec backend python manage.py collectstatic --noinput
```

---

## Step 9: Test Your App

### Test Backend API

```bash
# Test root API
curl http://localhost:8000/api/

# Test counter API
curl http://localhost:8000/api/counter/
```

**Expected**: JSON response with counter data

### Test from Your Browser

Open these URLs in your browser (on your local computer):

- **Backend API**: `http://54.157.14.153:8000/api/`
- **Counter API**: `http://54.157.14.153:8000/api/counter/`
- **Frontend**: `http://54.157.14.153:3000` (if nginx is configured)

---

## Step 10: Update Frontend API URL (If Needed)

If your frontend needs to connect to the backend, update `frontend/lib/main.dart`:

```dart
// Change from:
static const String apiBaseUrl = 'http://localhost:8000/api/counter/';

// To:
static const String apiBaseUrl = 'http://54.157.14.153:8000/api/counter/';
```

Then rebuild frontend:
```bash
docker compose -f docker-compose.prod.yml build frontend
docker compose -f docker-compose.prod.yml up -d frontend
```

---

## Quick Commands Reference

```bash
# View logs
docker compose -f docker-compose.prod.yml logs -f

# View specific service logs
docker compose -f docker-compose.prod.yml logs -f backend

# Stop all services
docker compose -f docker-compose.prod.yml down

# Restart services
docker compose -f docker-compose.prod.yml restart

# Check container status
docker compose -f docker-compose.prod.yml ps

# Execute command in container
docker compose -f docker-compose.prod.yml exec backend python manage.py shell
```

---

## Troubleshooting

### Containers won't start
- Check logs: `docker compose -f docker-compose.prod.yml logs`
- Verify `.env` file exists and has correct values
- Check if ports are already in use

### Database connection errors
- Ensure `db` container is running: `docker ps`
- Check `DATABASE_URL` in `.env` matches docker-compose settings
- Verify database password is correct

### Can't access from browser
- Check security group allows HTTP (80) and HTTPS (443)
- Verify containers are running: `docker ps`
- Check if nginx is configured correctly

---

## Next: Set Up Domain (Optional)

Once everything works with IP address:

1. Point your domain DNS to `54.157.14.153`
2. Update `ALLOWED_HOSTS` in `.env` to include your domain
3. Set up SSL with Let's Encrypt
4. Update frontend API URL to use domain

---

**Start with Step 1** and work through each step! 🚀
