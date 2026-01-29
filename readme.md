# Flutter + Django Web App Template

A full-stack web application template built with Flutter (frontend) and Django (backend).

**Use this as a template** to quickly create new projects with:
- ✅ AWS/EC2 deployment ready
- ✅ Codemagic iOS build pipeline
- ✅ TestFlight deployment
- ✅ Complete documentation

📚 **Template Setup**: See [`docs/TEMPLATE_SETUP.md`](docs/TEMPLATE_SETUP.md)

## Project Structure

```
survey-web-app/
├── backend/          # Django REST API backend
│   ├── manage.py
│   ├── requirements.txt
│   ├── survey_backend/
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

## Getting Started

### Prerequisites

- Python 3.9+
- Flutter SDK 3.0+
- Git

### Backend Setup

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

### Frontend Setup

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

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

Ready to deploy to your domain?

**Quick start**:
```powershell
.\scripts\deploy-production.ps1  # Deployment helper
```

**Full guide**: See [`docs/DEPLOY_TO_PRODUCTION.md`](docs/DEPLOY_TO_PRODUCTION.md)

**Options**:
- **AWS** (App Runner, EC2) - See [`docs/DEPLOY_AWS.md`](docs/DEPLOY_AWS.md) ⭐
- **VPS/Server** (DigitalOcean, Linode) - Full control, ~$6/month
- **Platform-as-a-Service** (Railway, Render) - Easier, handles SSL/scale

**Development**:
- Local: Use `venv` or `docker-compose`
- Production: Use `docker-compose -f docker-compose.yml -f docker-compose.prod.yml`

## Contributing

Please follow the coding standards and submit PRs for any changes.

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for details.
