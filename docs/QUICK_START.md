# Quick Start Guide

## 🚀 Choose Your Development Approach

### Option 1: Local Development (Fastest - Recommended for daily work)

```bash
# 1. Set up backend virtual environment
cd backend
python -m venv venv
venv\Scripts\activate  # Windows
# source venv/bin/activate  # Linux/Mac

# 2. Install dependencies
pip install -r requirements.txt

# 3. Create environment file (copy from example)
cp .env.example .env
# Edit .env with your settings (use SQLite for simplicity)
# DATABASE_URL=sqlite:///db.sqlite3

# 4. Run migrations and start server
python manage.py migrate
python manage.py runserver

# Backend running at http://localhost:8000
```

### Option 2: Docker (Most Consistent - Recommended for teams)

```bash
# 1. Create environment file
cp backend/.env.example backend/.env
# Edit backend/.env if needed (defaults work with Docker)

# 2. Start all services (backend + database)
docker-compose up --build

# Backend: http://localhost:8000
# Database: localhost:5432
# Frontend: http://localhost:3000 (if built)
```

### Option 3: Hybrid (Best of Both Worlds)

- Use **venv** for daily development
- Use **Docker** occasionally to test full stack
- Use **Docker** for production deployment

---

## 📝 Environment File Setup

Create `backend/.env` from the example (if it doesn't exist):

```bash
cd backend
cp .env.example .env
```

**Important settings:**
- `SECRET_KEY` - Change this to a random secret
- `DEBUG=1` - For development (set to 0 for production)
- `DATABASE_URL` - Use SQLite for local dev: `sqlite:///db.sqlite3`

---

## 🗄️ Database Setup

### With venv (Local Development)

Use SQLite (simplest):
```bash
# In backend/.env
DATABASE_URL=sqlite:///db.sqlite3
python manage.py migrate
```

Use PostgreSQL locally:
```bash
# Install PostgreSQL locally first
# In backend/.env
DATABASE_URL=postgresql://user:password@localhost:5432/survey_db
python manage.py migrate
```

### With Docker (Automatic)

PostgreSQL runs automatically in Docker:
```bash
docker-compose up db backend
# Database ready, migrations run automatically
```

---

## ✅ Verification

### Backend Health Check

**With venv:**
```bash
curl http://localhost:8000/api/
```

**With Docker:**
```bash
curl http://localhost:8000/api/
# Or check logs
docker-compose logs backend
```

### Database Connection

**With venv:**
```bash
python manage.py dbshell
```

**With Docker:**
```bash
docker-compose exec db psql -U survey_user -d survey_db
```

---

## 🔧 Common Commands

### Virtual Environment
```bash
# Activate
venv\Scripts\activate  # Windows
source venv/bin/activate  # Linux/Mac

# Deactivate
deactivate

# Install new package
pip install package-name
pip freeze > requirements.txt  # Update requirements
```

### Docker
```bash
# Start services
docker-compose up

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f backend

# Stop services
docker-compose down

# Clean rebuild
docker-compose down -v
docker-compose up --build

# Run Django commands
docker-compose exec backend python manage.py migrate
docker-compose exec backend python manage.py createsuperuser
```

---

## 📚 Next Steps

- Read [`docs/ENVIRONMENTS.md`](ENVIRONMENTS.md) for detailed setup
- Read [`CONTRIBUTING.md`](../CONTRIBUTING.md) for development workflow
- Initialize your Django project in `backend/`
- Initialize your Flutter project in `frontend/`
