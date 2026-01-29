# Check Deployment Status on EC2
# Verifies that all services are running correctly

param(
    [Parameter(Mandatory=$false)]
    [string]$EC2IP = "YOUR_EC2_IP_ADDRESS",
    
    [Parameter(Mandatory=$false)]
    [string]$KeyPath = "security\survey-app-key.pem"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Checking Deployment Status" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get project root
$projectRoot = Split-Path -Parent $PSScriptRoot
$absoluteKeyPath = Join-Path $projectRoot $KeyPath

if (-not (Test-Path $absoluteKeyPath)) {
    Write-Host "ERROR: SSH key not found at: $absoluteKeyPath" -ForegroundColor Red
    exit 1
}

Write-Host "Connecting to EC2..." -ForegroundColor Yellow
Write-Host ""

# Check Docker containers
$checkCommand = "cd ~/survey-web-app && " +
                "echo '=== Docker Containers ===' && " +
                "docker compose -f docker-compose.yml -f docker-compose.prod.yml ps && " +
                "echo '' && " +
                "echo '=== Frontend Container Logs (last 20 lines) ===' && " +
                "docker compose -f docker-compose.yml -f docker-compose.prod.yml logs --tail=20 frontend && " +
                "echo '' && " +
                "echo '=== Backend Container Logs (last 20 lines) ===' && " +
                "docker compose -f docker-compose.yml -f docker-compose.prod.yml logs --tail=20 backend && " +
                "echo '' && " +
                "echo '=== Nginx Container Logs (last 20 lines) ===' && " +
                "docker compose -f docker-compose.yml -f docker-compose.prod.yml logs --tail=20 nginx 2>/dev/null || echo 'Nginx not running'"

ssh -i $absoluteKeyPath ubuntu@${EC2IP} $checkCommand

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Status Check Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Check if all containers are 'Up' and healthy" -ForegroundColor Gray
Write-Host "  2. Visit http://your-app-name.net in your browser" -ForegroundColor Gray
Write-Host "  3. Test the counter button" -ForegroundColor Gray
Write-Host ""
