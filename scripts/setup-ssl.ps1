# Setup SSL (HTTPS) with Let's Encrypt
# Get certificate, add nginx HTTPS config, enable SSL on EC2
# Does NOT build or deploy frontend (run separately, or use -RebuildAndDeploy)
# Reads from security/deployment.config

param(
    [Parameter(Mandatory=$false)]
    [string]$Email = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$RebuildAndDeploy = $false
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SSL Setup (Let's Encrypt)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get project root
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

# Load config
$configPath = Join-Path $projectRoot "security\deployment.config"
$config = @{}
if (Test-Path $configPath) {
    Get-Content $configPath | ForEach-Object {
        if ($_ -match '^([^#=]+)=(.*)$') {
            $config[$matches[1].Trim()] = $matches[2].Trim()
        }
    }
}

# Get values
$EC2IP = $config["EC2_ELASTIC_IP"]
if ([string]::IsNullOrWhiteSpace($EC2IP)) { $EC2IP = $config["EC2_IP"] }
$KeyPath = $config["KEY_PATH"]
$Domain = $config["DOMAIN"]

if ([string]::IsNullOrWhiteSpace($EC2IP)) {
    Write-Host "ERROR: EC2_ELASTIC_IP or EC2_IP required in security\deployment.config" -ForegroundColor Red
    exit 1
}
if ([string]::IsNullOrWhiteSpace($Domain)) {
    Write-Host "ERROR: DOMAIN required in security\deployment.config" -ForegroundColor Red
    exit 1
}
if ([string]::IsNullOrWhiteSpace($KeyPath)) {
    Write-Host "ERROR: KEY_PATH required in security\deployment.config" -ForegroundColor Red
    exit 1
}

# Email for Let's Encrypt
if ([string]::IsNullOrWhiteSpace($Email)) {
    $Email = $config["SSL_EMAIL"]
}
if ([string]::IsNullOrWhiteSpace($Email)) {
    $Email = Read-Host "Enter email for Let's Encrypt certificate (expiry notices)"
}
if ([string]::IsNullOrWhiteSpace($Email)) {
    Write-Host "ERROR: Email required for Let's Encrypt" -ForegroundColor Red
    exit 1
}

$absoluteKeyPath = Join-Path $projectRoot $KeyPath
if (-not (Test-Path $absoluteKeyPath)) {
    Write-Host "ERROR: SSH key not found: $absoluteKeyPath" -ForegroundColor Red
    exit 1
}

# Fix key permissions
icacls $absoluteKeyPath /inheritance:r 2>$null | Out-Null
icacls $absoluteKeyPath /grant:r "${env:USERNAME}:R" 2>$null | Out-Null

$sshTarget = "ubuntu@" + $EC2IP

Write-Host "Domain: $Domain" -ForegroundColor Yellow
Write-Host "EC2: $EC2IP" -ForegroundColor Yellow
Write-Host ""

# Test SSH
Write-Host "Step 0: Testing SSH connection..." -ForegroundColor Cyan
$testResult = & ssh -i $absoluteKeyPath -o ConnectTimeout=5 -o StrictHostKeyChecking=no $sshTarget "echo connected" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Cannot connect to EC2" -ForegroundColor Red
    exit 1
}
Write-Host "  Connected" -ForegroundColor Green
Write-Host ""

# Step 1: Add HTTPS nginx config (locally)
Write-Host "Step 1: Creating nginx HTTPS config..." -ForegroundColor Cyan
$examplePath = Join-Path $projectRoot "infra\nginx\nginx.https.conf.example"
$httpsPath = Join-Path $projectRoot "infra\nginx\nginx.https.conf"

if (-not (Test-Path $examplePath)) {
    Write-Host "ERROR: nginx.https.conf.example not found" -ForegroundColor Red
    exit 1
}

$content = Get-Content $examplePath -Raw
$content = $content -replace 'yourdomain\.com', $Domain
Set-Content -Path $httpsPath -Value $content -NoNewline
Write-Host "  Created infra\nginx\nginx.https.conf for $Domain" -ForegroundColor Green
Write-Host ""

# Step 2: Get certificate on EC2
Write-Host "Step 2: Getting Let's Encrypt certificate on EC2..." -ForegroundColor Cyan
Write-Host "  (Stopping nginx, installing certbot, requesting certificate)" -ForegroundColor Gray

$certCmd = "cd ~/app && docker compose -f docker-compose.yml -f docker-compose.prod.yml stop nginx 2>/dev/null; sudo apt update -qq && sudo apt install -y certbot 2>/dev/null; sudo certbot certonly --standalone --non-interactive --agree-tos -m " + $Email + " -d " + $Domain + " -d www." + $Domain

& ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget $certCmd

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Certificate request failed" -ForegroundColor Red
    Write-Host "Common causes:" -ForegroundColor Yellow
    Write-Host "  - Domain not pointing to EC2 (check DNS)" -ForegroundColor Gray
    Write-Host "  - Port 80 blocked (check security group)" -ForegroundColor Gray
    Write-Host "  - Another process using port 80" -ForegroundColor Gray
    exit 1
}
Write-Host "  Certificate obtained" -ForegroundColor Green
Write-Host ""

# Step 3: Commit nginx config and docker-compose.ssl.yml, then push
Write-Host "Step 3: Committing SSL config..." -ForegroundColor Cyan
$hasChanges = $false
if (& git status --porcelain infra/nginx/nginx.https.conf 2>&1) { & git add infra/nginx/nginx.https.conf; $hasChanges = $true }
if (& git status --porcelain docker-compose.ssl.yml 2>&1) { & git add docker-compose.ssl.yml; $hasChanges = $true }
if ($hasChanges) {
    & git commit -m "Add HTTPS nginx config and docker-compose.ssl.yml for $Domain"
    & git push origin main 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARNING: Git push failed. Push manually and run Step 4 on EC2." -ForegroundColor Yellow
    } else {
        Write-Host "  Pushed to GitHub" -ForegroundColor Green
    }
} else {
    Write-Host "  No changes to commit" -ForegroundColor Gray
}
Write-Host ""

# Step 4: Enable SSL on EC2
Write-Host "Step 4: Enabling SSL on EC2..." -ForegroundColor Cyan
$deployCmd = "cd ~/app && git pull origin main && docker compose -f docker-compose.yml -f docker-compose.prod.yml -f docker-compose.ssl.yml up -d"
& ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget $deployCmd

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to start Docker with SSL" -ForegroundColor Red
    exit 1
}
Write-Host "  SSL enabled" -ForegroundColor Green
Write-Host ""

# Optional: Rebuild frontend for HTTPS and deploy
if ($RebuildAndDeploy) {
    Write-Host "Step 5: Rebuilding frontend for HTTPS and deploying..." -ForegroundColor Cyan
    $configContent = Get-Content $configPath -Raw
    if ($configContent -match 'USE_HTTPS=(.+)') {
        $configContent = $configContent -replace 'USE_HTTPS=.+', 'USE_HTTPS=true'
    } else {
        $configContent = $configContent.TrimEnd() + "`nUSE_HTTPS=true`n"
    }
    Set-Content -Path $configPath -Value $configContent -NoNewline
    & "$PSScriptRoot\build-frontend-local.ps1"
    if ($LASTEXITCODE -eq 0) {
        & git add frontend/build 2>$null
        if (& git status --porcelain frontend/build 2>&1) {
            & git commit -m "Build frontend for HTTPS"
            & git push origin main 2>&1
            & "$PSScriptRoot\auto-deploy-ec2.ps1"
        }
    }
    Write-Host ""
} else {
    Write-Host "Next: Rebuild frontend for HTTPS and deploy when ready:" -ForegroundColor Cyan
    Write-Host "  Set USE_HTTPS=true in security\deployment.config" -ForegroundColor Gray
    Write-Host "  .\scripts\build-frontend-local.ps1" -ForegroundColor Gray
    Write-Host "  git add frontend/build; git commit -m 'Build frontend for HTTPS'; git push" -ForegroundColor Gray
    Write-Host "  .\scripts\auto-deploy-ec2.ps1" -ForegroundColor Gray
    Write-Host ""
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  SSL Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your site should now be available at: https://$Domain" -ForegroundColor Cyan
Write-Host ""
Write-Host "Renew certificates before they expire (every 90 days):" -ForegroundColor Yellow
Write-Host "  ssh to EC2, then:" -ForegroundColor Gray
Write-Host "  docker compose -f docker-compose.yml -f docker-compose.prod.yml -f docker-compose.ssl.yml stop nginx" -ForegroundColor Gray
Write-Host "  sudo certbot renew" -ForegroundColor Gray
Write-Host "  docker compose -f docker-compose.yml -f docker-compose.prod.yml -f docker-compose.ssl.yml start nginx" -ForegroundColor Gray
Write-Host ""
