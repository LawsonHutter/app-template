# Deploy to Custom Domain - Helper Script
# This script helps you prepare for domain deployment

param(
    [Parameter(Mandatory=$true)]
    [string]$Domain
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Custom Domain Deployment Helper" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Domain: $Domain" -ForegroundColor Yellow
Write-Host ""

Write-Host "Step 1: Update .env file" -ForegroundColor Green
Write-Host "  Add to ALLOWED_HOSTS: $Domain,www.$Domain" -ForegroundColor Gray
Write-Host "  Update CORS_ALLOWED_ORIGINS: https://$Domain,https://www.$Domain" -ForegroundColor Gray
Write-Host ""

Write-Host "Step 2: Update frontend/lib/main.dart" -ForegroundColor Green
Write-Host "  Change apiBaseUrl to: https://$Domain/api/counter/" -ForegroundColor Gray
Write-Host ""

Write-Host "Step 3: Update infra/nginx/nginx.prod.conf" -ForegroundColor Green
Write-Host "  Replace 'yourdomain.com' with: $Domain" -ForegroundColor Gray
Write-Host ""

Write-Host "Step 4: On EC2 server, run:" -ForegroundColor Green
Write-Host "  sudo certbot certonly --standalone -d $Domain -d www.$Domain" -ForegroundColor Gray
Write-Host ""

Write-Host "Step 5: Deploy with:" -ForegroundColor Green
Write-Host "  docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build" -ForegroundColor Gray
Write-Host ""

Write-Host "Full guide: docs/DEPLOY_CUSTOM_DOMAIN.md" -ForegroundColor Cyan
Write-Host ""
