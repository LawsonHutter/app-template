# Copy Backend and Frontend directories to EC2
# This script copies the essential application code to your EC2 instance

param(
    [Parameter(Mandatory=$true)]
    [string]$EC2IP,
    
    [Parameter(Mandatory=$false)]
    [string]$KeyPath = "security\app-key.pem"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Copy Backend & Frontend to EC2" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Resolve key path
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$absoluteKeyPath = Join-Path $projectRoot $KeyPath

if (-not (Test-Path $absoluteKeyPath)) {
    Write-Host "ERROR: SSH key not found at: $absoluteKeyPath" -ForegroundColor Red
    Write-Host "Please provide the correct path to your .pem file" -ForegroundColor Yellow
    exit 1
}

Write-Host "EC2 IP: $EC2IP" -ForegroundColor Yellow
Write-Host "SSH Key: $absoluteKeyPath" -ForegroundColor Yellow
Write-Host ""

# Check if directories exist locally
$backendPath = Join-Path $projectRoot "backend"
$frontendPath = Join-Path $projectRoot "frontend"

if (-not (Test-Path $backendPath)) {
    Write-Host "ERROR: backend/ directory not found locally!" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $frontendPath)) {
    Write-Host "ERROR: frontend/ directory not found locally!" -ForegroundColor Red
    exit 1
}

Write-Host "Copying backend/ directory..." -ForegroundColor Green
$backendExclude = "--exclude='backend/venv' --exclude='backend/__pycache__' --exclude='backend/*.pyc' --exclude='backend/db.sqlite3' --exclude='backend/.pytest_cache' --exclude='backend/.coverage' --exclude='backend/htmlcov' --exclude='backend/dist' --exclude='backend/build' --exclude='backend/*.egg-info' --exclude='backend/media' --exclude='backend/staticfiles'"

$backendCommand = "scp -i `"$absoluteKeyPath`" -r $backendExclude `"$backendPath`" ubuntu@${EC2IP}:~/app/"
Write-Host "Command: $backendCommand" -ForegroundColor Gray
Invoke-Expression $backendCommand

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to copy backend directory" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Backend copied successfully" -ForegroundColor Green
Write-Host ""

Write-Host "Copying frontend/ directory..." -ForegroundColor Green
$frontendExclude = "--exclude='frontend/.dart_tool' --exclude='frontend/.flutter-plugins' --exclude='frontend/.flutter-plugins-dependencies' --exclude='frontend/.packages' --exclude='frontend/.pub-cache' --exclude='frontend/.pub' --exclude='frontend/build' --exclude='frontend/web/main.dart.js' --exclude='frontend/web/main.dart.js.map'"

$frontendCommand = "scp -i `"$absoluteKeyPath`" -r $frontendExclude `"$frontendPath`" ubuntu@${EC2IP}:~/app/"
Write-Host "Command: $frontendCommand" -ForegroundColor Gray
Invoke-Expression $frontendCommand

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to copy frontend directory" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Frontend copied successfully" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Copy Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps on EC2:" -ForegroundColor Yellow
Write-Host "  1. Verify: ls -la ~/app/backend" -ForegroundColor Gray
Write-Host "  2. Verify: ls -la ~/app/frontend" -ForegroundColor Gray
Write-Host "  3. Continue with deployment" -ForegroundColor Gray
Write-Host ""
