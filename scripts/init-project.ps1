# Initialize Counter App Project
# Sets up Django backend and Flutter frontend from scratch

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectName = "counter-app"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Initialize Counter App Project" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = Split-Path -Parent $PSScriptRoot

# Check if we're in the right directory
if (-not (Test-Path (Join-Path $projectRoot "backend"))) {
    Write-Host "ERROR: backend/ directory not found!" -ForegroundColor Red
    Write-Host "Please run this script from the project root directory" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path (Join-Path $projectRoot "frontend"))) {
    Write-Host "ERROR: frontend/ directory not found!" -ForegroundColor Red
    Write-Host "Please run this script from the project root directory" -ForegroundColor Yellow
    exit 1
}

Write-Host "Step 1: Setting up Django Backend..." -ForegroundColor Yellow
Write-Host ""

# Navigate to backend
Push-Location (Join-Path $projectRoot "backend")

# Check Python
try {
    $pythonVersion = python --version 2>&1
    Write-Host "Python: $pythonVersion" -ForegroundColor Gray
} catch {
    Write-Host "ERROR: Python not found. Please install Python 3.8+" -ForegroundColor Red
    Pop-Location
    exit 1
}

# Create virtual environment if it doesn't exist
if (-not (Test-Path "venv")) {
    Write-Host "Creating Python virtual environment..." -ForegroundColor Gray
    python -m venv venv
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to create virtual environment" -ForegroundColor Red
        Pop-Location
        exit 1
    }
}

# Activate virtual environment
Write-Host "Activating virtual environment..." -ForegroundColor Gray
if ($IsWindows -or $env:OS -match "Windows") {
    & ".\venv\Scripts\Activate.ps1"
} else {
    & "source venv/bin/activate"
}

# Upgrade pip
Write-Host "Upgrading pip..." -ForegroundColor Gray
python -m pip install --upgrade pip | Out-Null

# Install dependencies
Write-Host "Installing Django dependencies..." -ForegroundColor Gray
pip install -r requirements.txt
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to install dependencies" -ForegroundColor Red
    Pop-Location
    exit 1
}

# Run migrations
Write-Host "Running database migrations..." -ForegroundColor Gray
python manage.py migrate
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to run migrations" -ForegroundColor Red
    Pop-Location
    exit 1
}

# Create superuser (optional)
Write-Host ""
Write-Host "✓ Django backend initialized!" -ForegroundColor Green
Write-Host ""
Write-Host "To create a Django admin user, run:" -ForegroundColor Yellow
Write-Host "  python manage.py createsuperuser" -ForegroundColor Gray
Write-Host ""

Pop-Location

Write-Host "Step 2: Setting up Flutter Frontend..." -ForegroundColor Yellow
Write-Host ""

# Navigate to frontend
Push-Location (Join-Path $projectRoot "frontend")

# Check Flutter
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "Flutter: $flutterVersion" -ForegroundColor Gray
} catch {
    Write-Host "ERROR: Flutter not found. Please install Flutter SDK" -ForegroundColor Red
    Write-Host "Download from: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    Pop-Location
    exit 1
}

# Check Flutter doctor
Write-Host "Checking Flutter setup..." -ForegroundColor Gray
$doctorOutput = flutter doctor 2>&1
$hasIssues = $doctorOutput | Select-String -Pattern "✗" -Quiet
if ($hasIssues) {
    Write-Host "WARNING: Flutter setup has issues. Run 'flutter doctor' for details" -ForegroundColor Yellow
}

# Install dependencies
Write-Host "Installing Flutter dependencies..." -ForegroundColor Gray
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to install Flutter dependencies" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "✓ Flutter frontend initialized!" -ForegroundColor Green
Write-Host ""

Pop-Location

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Initialization Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  Run locally (web): .\scripts\start-local-web.ps1" -ForegroundColor Gray
Write-Host "  For deployment: see SETUP_GUIDE.md" -ForegroundColor Gray
Write-Host ""
