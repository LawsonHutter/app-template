# Run Database Migrations in Docker (Windows PowerShell)

Write-Host "Running database migrations..." -ForegroundColor Cyan
Write-Host ""

# Get the project root directory
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

# Check if Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Host "ERROR: Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

# Check if backend container is running
$backendRunning = docker ps --filter "name=survey-backend" --format "{{.Names}}"
if (-not $backendRunning) {
    Write-Host "ERROR: Backend container is not running." -ForegroundColor Red
    Write-Host "Start it first with: .\scripts\start-docker.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "Creating migration files..." -ForegroundColor Yellow
docker-compose exec backend python manage.py makemigrations

Write-Host ""
Write-Host "Applying migrations..." -ForegroundColor Yellow
docker-compose exec backend python manage.py migrate

Write-Host ""
Write-Host "Migrations completed!" -ForegroundColor Green
