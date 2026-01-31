# Start full stack locally via Docker (backend + DB + frontend web)
# Reads local URLs from security/deployment.config

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

$apiUrl = $config["LOCAL_WEB_API_URL"]
if ([string]::IsNullOrWhiteSpace($apiUrl)) {
    $apiUrl = "http://localhost:8000/api/counter/"
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Counter App - Local Docker (Web)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "API URL for frontend: $apiUrl" -ForegroundColor Gray
Write-Host ""

# Set env var for docker-compose (frontend build arg)
$env:LOCAL_WEB_API_URL = $apiUrl

Write-Host "Starting backend, database, and frontend..." -ForegroundColor Yellow
docker compose -f docker-compose.yml -f docker-compose.local.yml up --build

Write-Host ""
Write-Host "Stop with: docker compose -f docker-compose.yml -f docker-compose.local.yml down" -ForegroundColor Gray
