# Start Django Backend Locally (Windows PowerShell)
# This script sets up and runs the backend using Python virtual environment

Write-Host "Starting Django Backend Locally..." -ForegroundColor Cyan

# Check if port 8000 is in use (might be Docker)
$portInUse = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "WARNING: Port 8000 is already in use!" -ForegroundColor Yellow
    Write-Host "Stop Docker: docker compose down" -ForegroundColor Yellow
    Write-Host ""
}

# Navigate to backend directory
Set-Location backend

# Check if virtual environment exists
if (-not (Test-Path "venv")) {
    Write-Host "Creating virtual environment..." -ForegroundColor Yellow
    python -m venv venv
}

# Activate virtual environment
Write-Host "Activating virtual environment..." -ForegroundColor Yellow
& .\venv\Scripts\Activate.ps1

# Check if requirements are installed
if (-not (Test-Path "venv\Lib\site-packages\django")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    pip install -r requirements.txt
}

# Ensure we use SQLite (not PostgreSQL from Docker)
# Clear DATABASE_URL environment variable if it exists
$env:DATABASE_URL = ""

Write-Host "Using SQLite database (db.sqlite3 file will be updated)" -ForegroundColor Green

# Check if .env file exists (optional)
if (-not (Test-Path ".env")) {
    Write-Host "Warning: .env file not found. Using defaults (SQLite)." -ForegroundColor Yellow
}

# Run migrations to ensure database is up to date
Write-Host "Running database migrations..." -ForegroundColor Yellow
python manage.py makemigrations
python manage.py migrate

Write-Host ""
Write-Host "Starting Django server on http://localhost:8000" -ForegroundColor Green
Write-Host "   Database file: backend\db.sqlite3" -ForegroundColor Gray
Write-Host "   Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

python manage.py runserver
