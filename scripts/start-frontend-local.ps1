# Start Flutter Frontend Locally (Windows PowerShell)
# This script runs the Flutter web app in development mode

Write-Host "Starting Flutter Frontend Locally..." -ForegroundColor Cyan

# Navigate to frontend directory
Set-Location frontend

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "Flutter detected: $flutterVersion" -ForegroundColor Gray
} catch {
    Write-Host "ERROR: Flutter not found. Please install Flutter SDK." -ForegroundColor Red
    exit 1
}

# Install dependencies if needed
if (-not (Test-Path ".dart_tool")) {
    Write-Host "Installing Flutter dependencies..." -ForegroundColor Yellow
    flutter pub get
}

# Check if pubspec.lock exists (indicates dependencies installed)
if (-not (Test-Path "pubspec.lock")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    flutter pub get
}

Write-Host "Starting Flutter web app..." -ForegroundColor Green
Write-Host "   Frontend will connect to backend at http://localhost:8000" -ForegroundColor Gray
Write-Host "   Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

# Run Flutter web app (will open in default browser)
flutter run -d chrome --web-port 8080 --dart-define=API_BASE_URL=http://localhost:8000/api/counter/
