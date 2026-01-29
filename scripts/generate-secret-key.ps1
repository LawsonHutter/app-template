# Generate Django Secret Key (Windows PowerShell)

Write-Host "Generating Django SECRET_KEY..." -ForegroundColor Cyan
Write-Host ""

python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

Write-Host ""
Write-Host "Copy this key and add it to your production environment variables." -ForegroundColor Yellow
Write-Host "Never commit this key to version control!" -ForegroundColor Red
