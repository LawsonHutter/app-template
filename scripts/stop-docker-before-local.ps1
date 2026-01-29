# Stop Docker Before Starting Local (Windows PowerShell)
# This ensures Docker containers aren't blocking ports 8000, 3000, 5432

Write-Host "Checking for running Docker containers..." -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Host "Docker is not running. You're good to go!" -ForegroundColor Green
    exit 0
}

# Check if containers are running
$containers = docker ps --format "{{.Names}}" 2>$null
$ourContainers = $containers | Where-Object { $_ -match "survey-" }

if ($ourContainers) {
    Write-Host "Found running Docker containers detected:" -ForegroundColor Yellow
    $ourContainers | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
    Write-Host ""
    Write-Host "Stopping Docker containers to free up ports..." -ForegroundColor Yellow
    
    # Get project root
    $projectRoot = Split-Path -Parent $PSScriptRoot
    Set-Location $projectRoot
    
    docker-compose down
    
    Write-Host ""
    Write-Host "Docker containers stopped!" -ForegroundColor Green
    Write-Host "Ports 8000, 3000, and 5432 are now free for local development." -ForegroundColor Gray
} else {
    Write-Host "No Docker containers running. You're good to go!" -ForegroundColor Green
}

Write-Host ""
