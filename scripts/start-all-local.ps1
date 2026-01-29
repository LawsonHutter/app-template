# Start Both Frontend and Backend Locally (Windows PowerShell)
# This script starts both services in separate windows

Write-Host "Starting Full Stack Locally..." -ForegroundColor Cyan
Write-Host ""

# Get the project root directory
$projectRoot = Split-Path -Parent $PSScriptRoot

# Start backend in a new window
Write-Host "Starting Backend..." -ForegroundColor Yellow
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
Write-Host "   Backend: http://localhost:8000" -ForegroundColor Gray
Write-Host "   Frontend: http://localhost:8080" -ForegroundColor Gray
Write-Host ""
Write-Host "   Close the windows to stop the services." -ForegroundColor Gray
