# Environment Setup Guide

This project supports **two approaches** for managing Python environments and deployment:

1. **Local Development** - Python virtual environments (venv)
2. **Containerized Development/Production** - Docker & Docker Compose

## 🎯 Recommended Approach

### For Local Development (Fast iteration, debugging)
✅ **Use Python virtual environment (venv)**
- Faster startup times
- Easier debugging with IDE integration
- Direct file changes without rebuild
- Native Python tools work seamlessly

### For Production & Consistent Environments
✅ **Use Docker**
- Consistent across all machines
- Includes database and all services
- Easy deployment
- Reproducible builds

### Hybrid Approach (Best of Both Worlds)
✅ **Use venv locally + Docker for production**
- Develop locally with venv for speed
- Test with Docker occasionally
- Deploy with Docker for consistency

---

## 📦 Option 1: Python Virtual Environment (Local Development)

### Setup

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate (Windows)
venv\Scripts\activate

# Activate (Linux/Mac)
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Create .env file from example
cp .env.backend.example .env.backend

# Edit .env.backend with your settings
# For local dev, you can use SQLite:
# DATABASE_URL=sqlite:///db.sqlite3

# Run migrations
python manage.py migrate

# Create superuser (optional)
python manage.py createsuperuser

# Run development server
python manage.py runserver
```

### Advantages
- ✅ Fast startup
- ✅ Easy debugging
- ✅ IDE auto-completion works
- ✅ Direct file edits (no rebuild)

### When to Use
- Day-to-day development
- Quick testing
- Running tests frequently

---

## 🐳 Option 2: Docker (Containerized)

### Quick Start with Docker Compose

```bash
# Copy environment file
cp .env.backend.example .env.backend
# Edit .env.backend as needed

# Build and start all services
docker-compose up --build

# Or run in detached mode
docker-compose up -d --build

# View logs
docker-compose logs -f backend

# Stop services
docker-compose down

# Stop and remove volumes (clean slate)
docker-compose down -v
```

### Development Mode

```bash
# Use development compose file
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up --build
```

### Production Mode

```bash
# Use production compose file
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up --build
```

### Individual Service Commands

```bash
# Run only database
docker-compose up db

# Run backend with database
docker-compose up db backend

# Execute commands in container
docker-compose exec backend python manage.py migrate
docker-compose exec backend python manage.py createsuperuser
docker-compose exec backend python manage.py shell
```

### Advantages
- ✅ Consistent environment (works everywhere)
- ✅ Includes PostgreSQL database
- ✅ All services orchestrated together
- ✅ Production-ready setup
- ✅ No Python version conflicts

### When to Use
- Team collaboration (ensures everyone has same setup)
- CI/CD pipelines
- Production deployment
- Testing full stack integration
- New team member onboarding

---

## 🔄 Migrating Between Environments

### From venv to Docker

```bash
# Stop venv server (Ctrl+C)
deactivate  # Exit venv

# Start Docker
docker-compose up --build
```

### From Docker to venv

```bash
# Stop Docker
docker-compose down

# Start venv
cd backend
source venv/bin/activate  # or venv\Scripts\activate on Windows
python manage.py runserver
```

---

## 🗄️ Database Considerations

### Local Development with venv

**Option A: SQLite (Simplest)**
```bash
# In .env.backend
DATABASE_URL=sqlite:///db.sqlite3
```

**Option B: Local PostgreSQL**
```bash
# Install PostgreSQL locally
# In .env.backend
DATABASE_URL=postgresql://user:password@localhost:5432/survey_db
```

### Docker Development

```bash
# Uses PostgreSQL container automatically
# Configured in docker-compose.yml
# Database persists in Docker volume: postgres_data
```

**Access PostgreSQL in Docker:**
```bash
docker-compose exec db psql -U survey_user -d survey_db
```

---

## 📝 Environment Variables

### Location Priority (highest to lowest)

1. `.env.backend` (local file) - **Create this from `.env.backend.example`**
2. `docker-compose.yml` environment section
3. System environment variables

### Required Variables

- `SECRET_KEY` - Django secret key
- `DATABASE_URL` - Database connection string
- `DEBUG` - Set to `0` in production

### Create Environment File

```bash
# Copy example
cp .env.backend.example .env.backend

# Edit with your values
# NEVER commit .env.backend to git!
```

---

## 🚀 Deployment Strategy

### Development
- Use `venv` for local development
- Use `docker-compose` occasionally to test full stack

### Staging/Production
- Use Docker with `docker-compose.prod.yml`
- Set `DEBUG=0`
- Use production database
- Configure proper `ALLOWED_HOSTS`

### CI/CD Pipeline
- Use Docker for consistent testing
- Build Docker images in CI
- Deploy containers to production

---

## 🛠️ Troubleshooting

### Virtual Environment Issues

```bash
# Recreate venv
rm -rf venv  # or rmdir /s venv on Windows
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate
pip install -r requirements.txt
```

### Docker Issues

```bash
# Clean rebuild
docker-compose down -v
docker-compose build --no-cache
docker-compose up --build

# Check logs
docker-compose logs backend
docker-compose logs db

# Remove all containers/images
docker-compose down -v --rmi all
```

### Database Connection Issues

**With venv:**
- Check `DATABASE_URL` in `.env.backend`
- Ensure database is running (if PostgreSQL)
- Check database credentials

**With Docker:**
- Ensure `db` service is running: `docker-compose ps`
- Check network connectivity: services must be on same network
- Verify environment variables in `docker-compose.yml`

---

## 📚 Best Practices

1. **Never commit `.env.backend`** - It's in `.gitignore`
2. **Use `.env.backend.example`** - Commit this as a template
3. **Different environments** - Use different compose files for dev/prod
4. **Keep dependencies updated** - Regularly update `requirements.txt`
5. **Database migrations** - Run migrations in both environments separately

---

## 🎯 Recommendation Summary

**For Your Workflow:**

1. **Local Development**: Use `venv` for daily work
   ```bash
   cd backend
   source venv/bin/activate
   python manage.py runserver
   ```

2. **Integration Testing**: Use Docker occasionally
   ```bash
   docker-compose up --build
   ```

3. **Production Deployment**: Use Docker
   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
   ```

This gives you the speed of local development with the reliability of Docker for production! 🚀
