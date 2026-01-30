# Start Both Frontend and Backend Locally with SQLite (Windows PowerShell)
# This script starts both services in separate windows using SQLite

Write-Host "Starting Full Stack Locally with SQLite..." -ForegroundColor Cyan
Write-Host ""

# Check and stop Docker if running
Write-Host "Checking for Docker containers..." -ForegroundColor Yellow
$containers = docker ps --format "{{.Names}}" 2>$null
$ourContainers = $containers | Where-Object { $_ -match "counter-" }

if ($ourContainers) {
    Write-Host "Stopping Docker containers to free up ports..." -ForegroundColor Yellow
    docker-compose down
    Start-Sleep -Seconds 2
}
Write-Host ""

# Get the project root directory
$projectRoot = Split-Path -Parent $PSScriptRoot

# Start backend in a new window (with SQLite)
Write-Host "Starting Backend (SQLite)..." -ForegroundColor Yellow
$backendCommand = "cd '$projectRoot'; .\scripts\start-backend-local.ps1"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $backendCommand

# Wait a moment for backend to start
Start-Sleep -Seconds 3

# Start frontend in a new window
Write-Host "Starting Frontend..." -ForegroundColor Yellow
$frontendCommand = "cd '$projectRoot'; .\scripts\start-frontend-local.ps1"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $frontendCommand

Write-Host ""
Write-Host "Both services starting in separate windows!" -ForegroundColor Green
Write-Host "   Backend: http://localhost:8000 (using SQLite)" -ForegroundColor Gray
Write-Host "   Frontend: http://localhost:8080" -ForegroundColor Gray
Write-Host ""
Write-Host "Database file: backend\db.sqlite3" -ForegroundColor Cyan
Write-Host "   You can watch this file change as you click the button!" -ForegroundColor Gray
Write-Host ""
Write-Host "View database: .\scripts\view-db.ps1" -ForegroundColor Yellow
Write-Host "Close the windows to stop the services." -ForegroundColor Gray
