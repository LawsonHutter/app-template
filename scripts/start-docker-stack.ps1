# Start Full Stack with Docker (Windows PowerShell)
# Supports dev/prod and foreground/background in one place.
#
# Usage examples:
#   .\scripts\start-docker-stack.ps1
#   .\scripts\start-docker-stack.ps1 -Mode prod
#   .\scripts\start-docker-stack.ps1 -Mode prod -Detached

param(
    [ValidateSet("dev", "prod")]
    [string]$Mode = "dev",

    [switch]$Detached,

    # If set, will rebuild images before starting
    [switch]$Build
)

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

Write-Host "Starting Docker stack..." -ForegroundColor Cyan
Write-Host "  Mode: $Mode" -ForegroundColor Gray
Write-Host ("  Detached: {0}" -f ($Detached.IsPresent)) -ForegroundColor Gray
Write-Host ("  Build: {0}" -f ($Build.IsPresent)) -ForegroundColor Gray
Write-Host ""

# Check Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Host "Docker is not running. Start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "docker-compose.yml")) {
    Write-Host "docker-compose.yml not found in project root." -ForegroundColor Red
    exit 1
}

$composeFiles = @("-f", "docker-compose.yml")
if ($Mode -eq "prod") {
    if (-not (Test-Path "docker-compose.prod.yml")) {
        Write-Host "docker-compose.prod.yml not found in project root." -ForegroundColor Red
        exit 1
    }
    $composeFiles += @("-f", "docker-compose.prod.yml")
}

$upArgs = @("compose") + $composeFiles + @("up")
if ($Detached) { $upArgs += "-d" }
if ($Build) { $upArgs += "--build" }

Write-Host "Services:" -ForegroundColor Cyan
Write-Host "  Backend API:  http://localhost:8000" -ForegroundColor Gray
if ($Mode -eq "prod") {
    Write-Host "  Frontend:     https://localhost (via nginx) OR http://localhost" -ForegroundColor Gray
    Write-Host "  Nginx:        http://localhost (80), https://localhost (443)" -ForegroundColor Gray
} else {
    Write-Host "  Frontend:     http://localhost:3000" -ForegroundColor Gray
}
Write-Host "  Database:     localhost:5432" -ForegroundColor Gray
Write-Host ""

Write-Host ("Running: docker {0}" -f ($upArgs -join " ")) -ForegroundColor DarkGray
Write-Host ""

# Important: enforce deploy.resources.* limits when NOT running Swarm.
# Some Compose versions support `--compatibility`, others don't; the env var works broadly.
$env:COMPOSE_COMPATIBILITY = "1"
try {
    & docker @upArgs
} finally {
    Remove-Item Env:COMPOSE_COMPATIBILITY -ErrorAction SilentlyContinue
}

