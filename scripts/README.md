# Startup Scripts

Scripts to start the frontend and backend in different ways.

## Local Development Scripts (venv + Flutter)

### Start Backend Locally
```powershell
.\scripts\start-backend-local.ps1
```
- Sets up Python virtual environment (if needed)
- Installs dependencies
- Starts Django server on `http://localhost:8000`

### Start Frontend Locally
```powershell
.\scripts\start-frontend-local.ps1
```
- Installs Flutter dependencies (if needed)
- Starts Flutter web app on `http://localhost:8080`
- Hot reload enabled for development

### Start Both Locally
```powershell
.\scripts\start-all-local.ps1
```
- Starts both backend and frontend in separate windows
- Backend: `http://localhost:8000`
- Frontend: `http://localhost:8080`

## iOS Build Scripts

### Build iOS App (macOS only)
```bash
# On macOS
./scripts/build-ios.sh https://dipoll.net/api/counter/

# Or with PowerShell (if on Mac)
.\scripts\build-ios.ps1 -ApiUrl "https://dipoll.net/api/counter/"
```

**Note**: iOS builds require macOS with Xcode. If you don't have a Mac, use GitHub Actions (see `docs/IOS_BUILD_WITHOUT_MAC.md`).

## Docker Scripts (Full Stack)

### Start All Services with Docker
```powershell
.\scripts\start-docker.ps1
```
- Starts backend, database, and frontend using Docker Compose
- Runs in foreground (shows logs)
- Press `Ctrl+C` to stop

### Start Docker in Background
```powershell
.\scripts\start-docker-detached.ps1
```
- Starts all services in detached mode (background)
- Services run until you stop them
- Use `docker-compose logs` to view logs

### Stop Docker Services
```powershell
.\scripts\stop-docker.ps1
```
- Stops all Docker containers
- Keeps data in volumes (database persists)

### Build Frontend Locally and Deploy to EC2
```powershell
.\scripts\build-and-deploy-frontend.ps1
```
- Builds Flutter app on your local machine (more RAM)
- Copies built files to EC2
- Updates frontend container on EC2
- **Useful when EC2 doesn't have enough RAM to build Flutter**

## Service URLs

### Local Development
- **Backend**: `http://localhost:8000`
- **Frontend**: `http://localhost:8080`
- **Database**: SQLite (default) or local PostgreSQL

### Docker
- **Backend**: `http://localhost:8000`
- **Frontend**: `http://localhost:3000` (served by nginx)
- **Database**: `localhost:5432` (PostgreSQL)

## Database Modes

### Local Scripts (SQLite)
- **Database**: SQLite file (`backend/db.sqlite3`)
- **Visible**: Yes, you can see the database file
- **Fast**: Quick startup, no Docker needed
- **Best for**: Daily development

### Docker Scripts (PostgreSQL)
- **Database**: PostgreSQL in Docker container
- **Visible**: No, stored in Docker volume
- **Consistent**: Same environment everywhere
- **Best for**: Production, team collaboration

**Note**: These use **different databases** - data doesn't transfer between modes.

## Notes

- **Local scripts** are faster for development (hot reload)
- **Docker scripts** are better for testing full stack integration and production
- Use **Docker detached** to run services in background
- Frontend connects to backend at the URL specified in `main.dart`
- See `docs/DEPLOYMENT.md` for detailed comparison

## Troubleshooting

### Backend won't start
- Make sure Python is installed
- Check if port 8000 is available
- For Docker: run `docker-compose exec backend python manage.py migrate`

### Frontend won't start
- Make sure Flutter SDK is installed
- Run `flutter doctor` to check setup
- Try `flutter pub get` manually

### Docker won't start
- Make sure Docker Desktop is running
- Check `docker-compose ps` for container status
- View logs: `docker-compose logs [service-name]`

### EC2 Build Hangs
- Use `.\scripts\build-and-deploy-frontend.ps1` to build locally instead
- EC2 t3.micro (1GB RAM) may not have enough memory for Flutter builds
