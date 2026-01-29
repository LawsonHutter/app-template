# Docker Commands Reference

Quick reference for all Docker commands used in this project.

## 🚀 Basic Commands

### Build Images
```bash
# Build all services
docker compose build

# Build specific service
docker compose build backend
docker compose build frontend

# Build without cache (fresh start)
docker compose build --no-cache
```

### Start Services
```bash
# Start in foreground (see logs)
docker compose up

# Start in background (detached)
docker compose up -d

# Start with rebuild
docker compose up --build

# Start production mode
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Stop Services
```bash
# Stop all services
docker compose down

# Stop and remove volumes (⚠️ deletes database!)
docker compose down -v

# Stop production
docker compose -f docker-compose.yml -f docker-compose.prod.yml down
```

### View Status
```bash
# List running containers
docker compose ps

# View logs
docker compose logs

# View logs for specific service
docker compose logs backend
docker compose logs frontend

# Follow logs (live)
docker compose logs -f
docker compose logs -f backend
```

---

## 🏭 Production Commands (EC2)

### Full Production Deployment
```bash
cd ~/survey-web-app

# Pull latest code
git pull

# Build and start all services
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

# Run migrations
docker compose -f docker-compose.yml -f docker-compose.prod.yml exec backend python manage.py migrate

# Check status
docker compose -f docker-compose.yml -f docker-compose.prod.yml ps
```

### Update After Code Changes
```bash
# Pull latest code
git pull

# Rebuild and restart
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

# Or just restart (if no code changes)
docker compose -f docker-compose.yml -f docker-compose.prod.yml restart
```

### Run Django Commands
```bash
# Migrations
docker compose exec backend python manage.py migrate
docker compose exec backend python manage.py makemigrations

# Create superuser
docker compose exec backend python manage.py createsuperuser

# Collect static files
docker compose exec backend python manage.py collectstatic --noinput

# Django shell
docker compose exec backend python manage.py shell
```

---

## 🔧 Maintenance Commands

### View Logs
```bash
# All services
docker compose logs

# Specific service
docker compose logs backend
docker compose logs frontend
docker compose logs nginx
docker compose logs db

# Last 100 lines
docker compose logs --tail=100

# Follow logs (live updates)
docker compose logs -f backend
```

### Restart Services
```bash
# Restart all
docker compose restart

# Restart specific service
docker compose restart backend
docker compose restart frontend

# Production restart
docker compose -f docker-compose.yml -f docker-compose.prod.yml restart nginx
```

### Execute Commands in Containers
```bash
# Run command in backend
docker compose exec backend <command>

# Examples:
docker compose exec backend python manage.py migrate
docker compose exec backend python manage.py shell
docker compose exec backend ls -la

# Run command in database
docker compose exec db psql -U survey_user -d survey_db

# Get shell access
docker compose exec backend bash
docker compose exec frontend sh
```

### Clean Up
```bash
# Remove stopped containers
docker compose down

# Remove containers and volumes (⚠️ deletes database!)
docker compose down -v

# Remove unused images
docker image prune

# Remove everything (containers, images, volumes)
docker system prune -a --volumes
```

---

## 🐛 Debugging Commands

### Check Container Status
```bash
# List all containers
docker ps -a

# Container resource usage
docker stats

# Inspect container
docker inspect <container-name>

# Container logs
docker logs <container-name>
docker logs -f <container-name>  # follow
```

### Database Access
```bash
# Connect to PostgreSQL
docker compose exec db psql -U survey_user -d survey_db

# Or from outside container
psql -h localhost -p 5432 -U survey_user -d survey_db
```

### Network Debugging
```bash
# List networks
docker network ls

# Inspect network
docker network inspect survey-web-app_survey-network
```

---

## 📦 Image Management

### List Images
```bash
docker images
```

### Remove Images
```bash
# Remove specific image
docker rmi <image-name>

# Remove unused images
docker image prune
```

### Tag and Push (if using registry)
```bash
docker tag survey-web-app-backend:latest your-registry/survey-backend:latest
docker push your-registry/survey-backend:latest
```

---

## 🚨 Common Issues

### Port Already in Use
```bash
# Find what's using port
sudo lsof -i :8000
sudo lsof -i :80
sudo lsof -i :443

# Stop Docker containers
docker compose down
```

### Container Won't Start
```bash
# Check logs
docker compose logs <service-name>

# Check container status
docker ps -a

# Restart specific service
docker compose restart <service-name>
```

### Database Connection Issues
```bash
# Check database is running
docker compose ps db

# Check database logs
docker compose logs db

# Restart database
docker compose restart db
```

---

## 📋 Quick Reference Card

```bash
# Start everything
docker compose up -d

# Stop everything
docker compose down

# View logs
docker compose logs -f

# Rebuild after changes
docker compose up -d --build

# Run migrations
docker compose exec backend python manage.py migrate

# Production deployment
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

---

## 🎯 Most Common Workflow

### Local Development
```bash
# Start services
docker compose up -d

# View logs
docker compose logs -f

# Stop when done
docker compose down
```

### Production Deployment (EC2)
```bash
# Deploy
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

# Migrations
docker compose -f docker-compose.yml -f docker-compose.prod.yml exec backend python manage.py migrate

# Check status
docker compose -f docker-compose.yml -f docker-compose.prod.yml ps
```
