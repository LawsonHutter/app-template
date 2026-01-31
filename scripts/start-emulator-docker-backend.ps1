# Start backend + DB in Docker, then run Flutter on emulator
# Reads URLs from security/deployment.config
# Android emulator uses 10.0.2.2 to reach host's localhost

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("android", "ios")]
    [string]$Platform = "android"
)

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

$configPath = Join-Path $projectRoot "security\deployment.config"
$config = @{}
if (Test-Path $configPath) {
    Get-Content $configPath | ForEach-Object {
        if ($_ -match '^([^#=]+)=(.*)$') {
            $config[$matches[1].Trim()] = $matches[2].Trim()
        }
    }
}

# Android emulator needs 10.0.2.2; iOS simulator uses localhost
$apiUrl = if ($Platform -eq "android") {
    $config["LOCAL_EMULATOR_API_URL"]
} else {
    $config["LOCAL_WEB_API_URL"]
}
if ([string]::IsNullOrWhiteSpace($apiUrl)) {
    $apiUrl = if ($Platform -eq "android") { "http://10.0.2.2:8000/api/counter/" } else { "http://localhost:8000/api/counter/" }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Counter App - Emulator + Docker Backend" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Platform: $Platform" -ForegroundColor Yellow
Write-Host "API URL:  $apiUrl" -ForegroundColor Gray
Write-Host ""

# Start only backend and db
Write-Host "Starting backend and database in Docker..." -ForegroundColor Yellow
docker compose up -d db backend

# Wait for backend to be ready
Write-Host "Waiting for backend to start..." -ForegroundColor Gray
$maxAttempts = 30
$attempt = 0
do {
    Start-Sleep -Seconds 2
    $attempt++
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8000/api/" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) { break }
    } catch {}
} while ($attempt -lt $maxAttempts)

if ($attempt -ge $maxAttempts) {
    Write-Host "WARNING: Backend may not be ready. Continuing anyway." -ForegroundColor Yellow
} else {
    Write-Host "Backend is ready." -ForegroundColor Green
}

Write-Host ""
Write-Host "Starting Flutter on $Platform emulator..." -ForegroundColor Yellow
Write-Host ""

Set-Location (Join-Path $projectRoot "frontend")
flutter run -d $Platform --dart-define=API_BASE_URL=$apiUrl
