# Start Counter App Locally (Web)
# One script to run both backend and frontend for local web development

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Counter App - Local Web" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = Split-Path -Parent $PSScriptRoot

# Start backend in a new window
Write-Host "Starting backend (Django)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot'; .\scripts\start-backend-local.ps1"

# Wait for backend to be ready
Start-Sleep -Seconds 4

# Start frontend in a new window
Write-Host "Starting frontend (Flutter web)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot'; .\scripts\start-frontend-local.ps1"

Write-Host ""
Write-Host "Both services are starting in separate windows." -ForegroundColor Green
Write-Host ""
Write-Host "  Backend:  http://localhost:8000" -ForegroundColor Gray
Write-Host "  Frontend: http://localhost:8080  (opens in Chrome)" -ForegroundColor Gray
Write-Host ""
Write-Host "Close the backend/frontend windows to stop the services." -ForegroundColor Gray
Write-Host ""
