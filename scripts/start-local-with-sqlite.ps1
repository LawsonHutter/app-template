# Start Backend Locally with SQLite (Windows PowerShell)
# This ensures SQLite is used (not PostgreSQL) so you can see db.sqlite3 file update

Write-Host "Starting Django Backend Locally with SQLite..." -ForegroundColor Cyan

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

# Set environment to use SQLite (not PostgreSQL from Docker)
$env:DATABASE_URL = ""

Write-Host ""
Write-Host "Using SQLite database (db.sqlite3 file will be updated)" -ForegroundColor Green
Write-Host ""

# Run migrations to create/update database
Write-Host "Running database migrations..." -ForegroundColor Yellow
python manage.py makemigrations
python manage.py migrate

Write-Host ""
Write-Host "Starting Django server on http://localhost:8000" -ForegroundColor Green
Write-Host "   Database file: backend\db.sqlite3" -ForegroundColor Gray
Write-Host "   Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

python manage.py runserver
