# Stop Docker stack

param(
    [ValidateSet("dev", "prod")]
    [string]$Mode = "dev"
)

Write-Host "Stopping Docker stack..." -ForegroundColor Cyan
Write-Host "  Mode: $Mode" -ForegroundColor Gray
Write-Host ""

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

$composeFiles = @("-f", "docker-compose.yml")
if ($Mode -eq "prod") {
    $composeFiles += @("-f", "docker-compose.prod.yml")
}

& docker @(@("compose") + $composeFiles + @("down"))

Write-Host ""
Write-Host "All services stopped." -ForegroundColor Green
Write-Host ""
