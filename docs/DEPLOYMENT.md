# Deployment Guide

This project supports **two deployment modes**:

1. **Local Development** - SQLite database, Python venv, Flutter directly
2. **Docker Deployment** - PostgreSQL database, containerized services

Both modes use the same codebase - the difference is in how services are started.

---

## 🔧 Local Development Mode (SQLite)

**Best for**: Daily development, fast iteration, debugging

### How It Works

- **Database**: SQLite (file: `backend/db.sqlite3`)
- **Backend**: Python venv, Django development server
- **Frontend**: Flutter directly (`flutter run`)
- **No Docker required**

### Starting Locally

```powershell
# Start both services
.\scripts\start-all-local-sqlite.ps1

# Or start individually
.\scripts\start-backend-local.ps1  # Backend (uses SQLite)
.\scripts\start-frontend-local.ps1 # Frontend
```

### Database

- **File**: `backend/db.sqlite3`
- **Visible**: Yes, you can see and inspect the file
- **Migrations**: Run automatically when starting backend
- **View data**: `.\scripts\view-db.ps1`

### Environment

- **DATABASE_URL**: Empty or not set → Uses SQLite
- **Ports**: 
  - Backend: `http://localhost:8000`
  - Frontend: `http://localhost:8080`

---

## 🐳 Docker Deployment Mode (PostgreSQL)

**Best for**: Production, team consistency, full stack testing

### How It Works

- **Database**: PostgreSQL in Docker container
- **Backend**: Docker container with Django
- **Frontend**: Built Flutter web app served by nginx
- **All services orchestrated together**

### Starting with Docker

```powershell
# Start all services
.\scripts\start-docker.ps1

# Or start in background
.\scripts\start-docker-detached.ps1

# Stop services
.\scripts\stop-docker.ps1
```

### Database

- **Location**: Docker volume (`postgres_data`)
- **Visible**: No, stored inside Docker volume
- **Migrations**: Run manually: `.\scripts\migrate-docker.ps1`
- **Access**: `docker-compose exec db psql -U survey_user -d survey_db`

### Environment

- **DATABASE_URL**: `postgresql://survey_user:survey_pass@db:5432/survey_db` (set in docker-compose.yml)
- **Ports**:
  - Backend: `http://localhost:8000`
  - Frontend: `http://localhost:3000`
  - Database: `localhost:5432`

---

## 📊 Comparison

| Feature | Local (SQLite) | Docker (PostgreSQL) |
|---------|---------------|---------------------|
| **Database** | SQLite file | PostgreSQL in container |
| **Database File** | `backend/db.sqlite3` | Docker volume (invisible) |
| **Setup Speed** | Fast (venv only) | Slower (builds images) |
| **Development Speed** | Very fast (hot reload) | Fast (volume mounts) |
| **Consistency** | Depends on local Python | Same everywhere |
| **Production Ready** | No | Yes |
| **Dependencies** | Python + Flutter | Docker only |

---

## 🔄 Switching Between Modes

### From Docker to Local

```powershell
# Stop Docker
docker-compose down

# Start local
.\scripts\start-all-local-sqlite.ps1
```

### From Local to Docker

```powershell
# Stop local services (Ctrl+C in their windows)

# Start Docker
.\scripts\start-docker.ps1
```

**Note**: These use **different databases**:
- Local uses SQLite (`backend/db.sqlite3`)
- Docker uses PostgreSQL (in Docker volume)

Data doesn't transfer between them automatically.

---

## 🚀 Production Deployment

For production, use **Docker mode**:

1. **Build images**:
   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.prod.yml build
   ```

2. **Set environment variables**:
   - Create `.env` files or set in `docker-compose.prod.yml`
   - Set `DEBUG=0`
   - Set proper `ALLOWED_HOSTS`
   - Set `SECRET_KEY`

3. **Start services**:
   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
   ```

4. **Run migrations**:
   ```bash
   docker-compose exec backend python manage.py migrate
   ```

---

## 📝 Database Configuration

The database is automatically selected based on `DATABASE_URL`:

**Local (SQLite)**:
```python
# No DATABASE_URL set (or empty)
DATABASE_URL = ""  # or not set
# → Uses: backend/db.sqlite3
```

**Docker (PostgreSQL)**:
```python
# DATABASE_URL from docker-compose.yml
DATABASE_URL = "postgresql://survey_user:survey_pass@db:5432/survey_db"
# → Uses: PostgreSQL container
```

The logic in `backend/survey_backend/settings.py`:
```python
if DATABASE_URL.startswith('postgresql://'):
    # Use PostgreSQL
else:
    # Use SQLite (default)
```

---

## ✅ Recommended Workflow

1. **Daily Development**: Use **Local (SQLite)**
   - Fast startup
   - Easy debugging
   - Visible database file

2. **Testing Full Stack**: Use **Docker (PostgreSQL)**
   - Test integration
   - Verify deployment works
   - Ensure PostgreSQL compatibility

3. **Production**: Use **Docker (PostgreSQL)**
   - Consistent environment
   - Production-ready database
   - Easy deployment

---

## 🛠️ Troubleshooting

### Local mode not using SQLite

- **Issue**: Backend uses PostgreSQL even locally
- **Fix**: Ensure `DATABASE_URL` environment variable is not set:
  ```powershell
  $env:DATABASE_URL = ""  # Clear it
  ```

### Docker mode using SQLite

- **Issue**: Backend uses SQLite in Docker
- **Fix**: Check `docker-compose.yml` has `DATABASE_URL` set correctly

### Want to see database in Docker

- **View data**:
  ```bash
  docker-compose exec db psql -U survey_user -d survey_db -c "SELECT * FROM click_counter_clickcounter;"
  ```

- **Export data**:
  ```bash
  docker-compose exec db pg_dump -U survey_user survey_db > backup.sql
  ```

---

Both modes are fully supported and use the same codebase! 🎉
