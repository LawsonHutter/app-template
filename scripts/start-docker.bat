@echo off
REM Start All Services with Docker (Windows Batch)

echo 🐳 Starting All Services with Docker...
echo.

cd /d %~dp0\..

echo 📦 Starting containers...
echo    Backend:  http://localhost:8000
echo    Frontend: http://localhost:3000
echo    Database: localhost:5432
echo.
echo    Press Ctrl+C to stop all services
echo.

docker-compose up
