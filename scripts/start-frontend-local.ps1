# Start Flutter Frontend Locally (Windows PowerShell)
# Reads LOCAL_WEB_API_URL from security/deployment.config or -ApiUrl param

param(
    [Parameter(Mandatory=$false)]
    [string]$ApiUrl = ""
)

$projectRoot = Split-Path -Parent $PSScriptRoot

# Load API URL from config if not provided
if ([string]::IsNullOrWhiteSpace($ApiUrl)) {
    $configPath = Join-Path $projectRoot "security\deployment.config"
    if (Test-Path $configPath) {
        Get-Content $configPath | ForEach-Object {
            if ($_ -match '^LOCAL_WEB_API_URL=(.*)$') {
                $ApiUrl = $matches[1].Trim()
            }
        }
    }
}
if ([string]::IsNullOrWhiteSpace($ApiUrl)) {
    $ApiUrl = "http://localhost:8000/api/counter/"
}

Write-Host "Starting Flutter Frontend Locally..." -ForegroundColor Cyan

Set-Location (Join-Path $projectRoot "frontend")

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
if (-not (Test-Path "pubspec.lock")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    flutter pub get
}

Write-Host "Starting Flutter web app..." -ForegroundColor Green
Write-Host "   API URL: $ApiUrl" -ForegroundColor Gray
Write-Host "   Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

flutter run -d chrome --web-port 8080 --dart-define=API_BASE_URL=$ApiUrl
