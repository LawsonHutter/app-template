# Deploy to Production (Windows PowerShell)
# This script helps prepare your app for production deployment

Write-Host "Production Deployment Helper" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script will help you prepare for deployment." -ForegroundColor Yellow
Write-Host "Choose your deployment method:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. VPS/Server (DigitalOcean, Linode, etc.)" -ForegroundColor White
Write-Host "2. Platform-as-a-Service (Railway, Render)" -ForegroundColor White
Write-Host "3. Just generate production files" -ForegroundColor White
Write-Host ""
$choice = Read-Host "Enter choice (1-3)"

if ($choice -eq "1") {
    Write-Host ""
    Write-Host "VPS Deployment Steps:" -ForegroundColor Green
    Write-Host "1. Create VPS (DigitalOcean, Linode, Hetzner)" -ForegroundColor Gray
    Write-Host "2. Point domain DNS to server IP" -ForegroundColor Gray
    Write-Host "3. SSH to server and install Docker" -ForegroundColor Gray
    Write-Host "4. Copy project files to server" -ForegroundColor Gray
    Write-Host "5. Set up SSL with Let's Encrypt" -ForegroundColor Gray
    Write-Host "6. Run: docker compose -f docker-compose.prod.yml up -d" -ForegroundColor Gray
    Write-Host ""
    Write-Host "See docs/DEPLOY_TO_PRODUCTION.md for detailed guide" -ForegroundColor Yellow
} elseif ($choice -eq "2") {
    Write-Host ""
    Write-Host "PaaS Deployment Steps:" -ForegroundColor Green
    Write-Host "1. Sign up at Railway (railway.app) or Render (render.com)" -ForegroundColor Gray
    Write-Host "2. Connect your GitHub repository" -ForegroundColor Gray
    Write-Host "3. Add environment variables:" -ForegroundColor Gray
    Write-Host "   - SECRET_KEY (generate with Python)" -ForegroundColor Gray
    Write-Host "   - DEBUG=0" -ForegroundColor Gray
    Write-Host "   - ALLOWED_HOSTS=yourdomain.com" -ForegroundColor Gray
    Write-Host "4. Deploy!" -ForegroundColor Gray
    Write-Host ""
    Write-Host "See docs/DEPLOY_TO_PRODUCTION.md for detailed guide" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "Generating production checklist..." -ForegroundColor Green
    Write-Host ""
    Write-Host "Before deploying, ensure:" -ForegroundColor Yellow
    Write-Host "  [ ] DEBUG=0 in environment" -ForegroundColor Gray
    Write-Host "  [ ] SECRET_KEY is a secure random string" -ForegroundColor Gray
    Write-Host "  [ ] ALLOWED_HOSTS includes your domain" -ForegroundColor Gray
    Write-Host "  [ ] Database password is strong" -ForegroundColor Gray
    Write-Host "  [ ] SSL/HTTPS is configured" -ForegroundColor Gray
    Write-Host "  [ ] CORS_ALLOWED_ORIGINS includes your domain" -ForegroundColor Gray
    Write-Host ""
}

Write-Host ""
Write-Host "Generate SECRET_KEY:" -ForegroundColor Cyan
Write-Host "python -c \"from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())\"" -ForegroundColor Gray
Write-Host ""

Write-Host "Full deployment guide: docs/DEPLOY_TO_PRODUCTION.md" -ForegroundColor Yellow
Write-Host ""
