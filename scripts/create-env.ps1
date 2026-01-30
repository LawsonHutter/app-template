# Create .env file from template
# This script creates a .env file with your configuration

$projectRoot = Split-Path -Parent $PSScriptRoot

Write-Host "Creating .env file..." -ForegroundColor Cyan
Write-Host ""

# Check if .env already exists
$envPath = Join-Path $projectRoot ".env"
if (Test-Path $envPath) {
    $overwrite = Read-Host ".env file already exists. Overwrite? (y/n)"
    if ($overwrite -ne 'y') {
        Write-Host "Cancelled." -ForegroundColor Yellow
        exit 0
    }
}

# Create .env file with your values
$envContent = @"
# EC2 Configuration
EC2_IP=YOUR_EC2_IP_ADDRESS
EC2_ELASTIC_IP=YOUR_EC2_IP_ADDRESS

# GitHub Configuration
GITHUB_TOKEN=YOUR_GITHUB_PERSONAL_ACCESS_TOKEN

# Domain Configuration
DOMAIN=yourdomain.com

# Django Backend Configuration (for EC2)
SECRET_KEY=your-secret-key-here
DEBUG=0
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com,YOUR_EC2_IP_ADDRESS
DATABASE_URL=postgresql://counter_user:YOUR_DB_PASSWORD@db:5432/counter_db
CORS_ALLOWED_ORIGINS=http://yourdomain.com,https://www.yourdomain.com
POSTGRES_PASSWORD=YOUR_DB_PASSWORD
"@

$envContent | Out-File -FilePath $envPath -Encoding utf8 -NoNewline

Write-Host "✓ .env file created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Location: $envPath" -ForegroundColor Gray
Write-Host ""
Write-Host 'IMPORTANT: This file contains sensitive information and is NOT committed to git.' -ForegroundColor Yellow
Write-Host ""
