# Counter App

A simple counter app with Flutter frontend and Django backend. Press a button to increment a counter stored in the database.

**Features:**
- ✅ Flutter web frontend
- ✅ Django REST API backend
- ✅ EC2 deployment ready
- ✅ TestFlight deployment via Codemagic

📚 **Quick Start**: See [`INIT_SETUP.md`](INIT_SETUP.md) for initialization and deployment guide  

**Cloning to make a new app?** Run `.\scripts\rename-project.ps1 -AppName "Your App" -Domain "yourapp.net" -BundleId "com.yourdomain.yourapp"` once to rebrand the project, then see [`INIT_SETUP.md`](INIT_SETUP.md) Step 0.

## Project Structure

```
app/
├── backend/          # Django REST API backend
│   ├── manage.py
│   ├── requirements.txt
│   ├── counter_backend/
│   │   ├── settings.py
│   │   ├── urls.py
│   │   └── wsgi.py
│   └── apps/         # Django apps
│
├── frontend/         # Flutter web application
│   ├── pubspec.yaml
│   ├── lib/
│   ├── web/
│   └── test/
│
├── infra/            # Infrastructure & deployment configs
│   ├── docker/
│   ├── nginx/
│   └── deployment/
│
├── .gitignore
├── README.md
└── docs/             # Additional documentation
```

## Tech Stack

- **Frontend**: Flutter Web
- **Backend**: Django REST Framework
- **Database**: 
  - **Local Development**: SQLite (file: `backend/db.sqlite3`)
  - **Docker/Production**: PostgreSQL (in Docker container)

## Quick Start

### Initialize Project

Run the initialization script to set up everything:

```powershell
.\scripts\init-project.ps1
```

This will:
- Set up Python virtual environment
- Install Django dependencies
- Run database migrations
- Install Flutter dependencies

### Run Locally

**Web Browser:**
```powershell
.\scripts\start-local-web.ps1
```
Opens two windows: Django at `http://localhost:8000` and Flutter web at `http://localhost:8080`.

**Android Emulator:**
```powershell
.\scripts\start-android.ps1
```
Starts backend, launches Flutter emulator if needed, and runs the app. App connects to backend at `http://10.0.2.2:8000`.

**First time?** See [`docs/ANDROID_EMULATOR_SETUP.md`](docs/ANDROID_EMULATOR_SETUP.md) for emulator setup instructions.

📚 **Full Guide**: See [`INIT_SETUP.md`](INIT_SETUP.md) for detailed instructions

## Development Workflow

1. Create feature branches from `main`
2. Backend changes: `backend/feature-name`
3. Frontend changes: `frontend/feature-name`
4. Submit PRs for review

## Environment Setup

This project supports **two deployment modes** - use either depending on your needs:

### 🔧 Mode 1: Local Development (SQLite)
**Best for**: Daily development, fast iteration, debugging

- **Database**: SQLite file (`backend/db.sqlite3`) - visible on your disk
- **Backend**: Python venv, Django dev server
- **Frontend**: Flutter directly (`flutter run`)
- **No Docker required**

**Quick Start**:
```powershell
# Start both services with SQLite
.\scripts\start-all-local-sqlite.ps1

# Or start individually
.\scripts\start-backend-local.ps1  # Backend (SQLite)
.\scripts\start-frontend-local.ps1 # Frontend
```

**Database**: View with `.\scripts\view-db.ps1`

### 🐳 Mode 2: Docker Deployment (PostgreSQL)
**Best for**: Production, team consistency, full stack testing

- **Database**: PostgreSQL in Docker container
- **Backend**: Docker container with Django
- **Frontend**: Built Flutter web served by nginx
- **All services orchestrated together**

**Quick Start**:
```powershell
# Start all services with Docker
.\scripts\start-docker.ps1

# Or in background
.\scripts\start-docker-detached.ps1

# Stop services
.\scripts\stop-docker.ps1
```

**Database Migrations**: Run with `.\scripts\migrate-docker.ps1`

📚 **Detailed comparison**: See [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md)  
📚 **Environment details**: See [`docs/ENVIRONMENTS.md`](docs/ENVIRONMENTS.md)

## Deployment

### Deploy to EC2 ⭐ **Automated**

**First time setup (new EC2 instance):**
```powershell
# 1. Launch EC2 instance in AWS Console (Ubuntu 22.04 LTS)
# 2. Configure security/deployment.config with EC2_IP, KEY_PATH, GITHUB_URL
# 3. Set up EC2 instance (installs Docker, etc.)
.\scripts\setup-ec2.ps1

# 4. Build frontend locally
.\scripts\build-frontend-local.ps1

# 5. Commit and push
git add frontend/build
git commit -m "Build frontend"
git push origin main

# 6. Deploy everything automatically
.\scripts\auto-deploy-ec2.ps1
```

**Subsequent deployments:**
```powershell
# 1. Build frontend locally
.\scripts\build-frontend-local.ps1

# 2. Commit and push
git add frontend/build
git commit -m "Build frontend"
git push origin main

# 3. Deploy
.\scripts\auto-deploy-ec2.ps1
```

### Deploy to TestFlight

1. **Set up Codemagic** (see `codemagic.yaml`)
2. **Push to main branch:**
   ```powershell
   git push origin main
   ```
   Codemagic automatically builds and uploads to TestFlight.

📚 **Full Deployment Guide**: See [`INIT_SETUP.md`](INIT_SETUP.md)  
📚 **Scripts Reference**: See [`scripts/DEPLOYMENT_SCRIPTS.md`](scripts/DEPLOYMENT_SCRIPTS.md)

## Contributing

Please follow the coding standards and submit PRs for any changes.

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for details.
