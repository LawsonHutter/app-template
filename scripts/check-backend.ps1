# Check Backend Status (Windows PowerShell)
# This script checks if the backend is running and accessible

Write-Host "Checking Backend Status..." -ForegroundColor Cyan
Write-Host ""

# Check if backend is responding
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/api/" -Method GET -TimeoutSec 5
    Write-Host "✓ Backend is running!" -ForegroundColor Green
    Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Gray
    Write-Host "  Response: $($response.Content)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Backend is NOT responding" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure backend is running:" -ForegroundColor Yellow
    Write-Host "  .\scripts\start-backend-local.ps1" -ForegroundColor Gray
    exit 1
}

Write-Host ""

# Check counter endpoint
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/api/counter/" -Method GET -TimeoutSec 5
    Write-Host "✓ Counter API is accessible!" -ForegroundColor Green
    Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Gray
    Write-Host "  Response: $($response.Content)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Counter API is NOT accessible" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible issues:" -ForegroundColor Yellow
    Write-Host "  1. Migrations not run - run: python manage.py migrate" -ForegroundColor Gray
    Write-Host "  2. Backend error - check backend logs" -ForegroundColor Gray
}

Write-Host ""
