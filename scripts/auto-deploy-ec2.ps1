# Auto Deploy to EC2
# This script automatically deploys your app to EC2 instance
# Uses git pull to sync code (including pre-built frontend from build-frontend-local.ps1)
# Reads from security/deployment.config if no parameters provided

param(
    [Parameter(Mandatory=$false)]
    [string]$EC2IP = "",
    
    [Parameter(Mandatory=$false)]
    [string]$KeyPath = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Domain = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipMigrations = $false
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Auto Deploy to EC2" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get project root
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

# Load from deployment.config if it exists
$configPath = Join-Path $projectRoot "security\deployment.config"
$config = @{}
if (Test-Path $configPath) {
    Get-Content $configPath | ForEach-Object {
        if ($_ -match '^([^#=]+)=(.*)$') {
            $config[$matches[1].Trim()] = $matches[2].Trim()
        }
    }
    Write-Host "Loaded config from: security\deployment.config" -ForegroundColor Gray
}

# Use Elastic IP if set, otherwise fall back to EC2_IP
if ([string]::IsNullOrWhiteSpace($EC2IP)) {
    if (-not [string]::IsNullOrWhiteSpace($config["EC2_ELASTIC_IP"])) {
        $EC2IP = $config["EC2_ELASTIC_IP"]
        Write-Host "Using Elastic IP from config: $EC2IP" -ForegroundColor Green
    } elseif (-not [string]::IsNullOrWhiteSpace($config["EC2_IP"])) {
        $EC2IP = $config["EC2_IP"]
        Write-Host "Using EC2 IP from config: $EC2IP" -ForegroundColor Yellow
    }
}

if ([string]::IsNullOrWhiteSpace($EC2IP)) {
    Write-Host "ERROR: IP address is required" -ForegroundColor Red
    Write-Host "Set EC2_ELASTIC_IP or EC2_IP in security\deployment.config" -ForegroundColor Yellow
    exit 1
}

# Use KeyPath from config if not provided
if ([string]::IsNullOrWhiteSpace($KeyPath)) {
    if (-not [string]::IsNullOrWhiteSpace($config["KEY_PATH"])) {
        $KeyPath = $config["KEY_PATH"]
    } else {
        $KeyPath = "security\app-key.pem"
    }
}

# Use Domain from config if not provided
if ([string]::IsNullOrWhiteSpace($Domain)) {
    if (-not [string]::IsNullOrWhiteSpace($config["DOMAIN"])) {
        $Domain = $config["DOMAIN"]
    }
}

# GitHub URL (required for deployment)
$githubUrl = $config["GITHUB_URL"]
$githubBranch = $config["GITHUB_BRANCH"]
if ([string]::IsNullOrWhiteSpace($githubBranch)) { $githubBranch = "main" }

if ([string]::IsNullOrWhiteSpace($githubUrl)) {
    Write-Host "ERROR: GITHUB_URL is required in security\deployment.config" -ForegroundColor Red
    Write-Host "Example: GITHUB_URL=https://github.com/yourusername/your-repo.git" -ForegroundColor Yellow
    exit 1
}

# SSL: if USE_HTTPS=true, use docker-compose.ssl.yml (see docs/SSL_SETUP.md)
$useHttps = $config["USE_HTTPS"] -eq "true"
$composeArgs = "-f docker-compose.yml -f docker-compose.prod.yml"
if ($useHttps) { $composeArgs = $composeArgs + " -f docker-compose.ssl.yml" }

# Resolve key path
$absoluteKeyPath = Join-Path $projectRoot $KeyPath
if (-not (Test-Path $absoluteKeyPath)) {
    Write-Host "ERROR: SSH key not found at: $absoluteKeyPath" -ForegroundColor Red
    Write-Host "Set KEY_PATH in security\deployment.config" -ForegroundColor Yellow
    exit 1
}

# Fix key file permissions (Windows requires restricted permissions for SSH keys)
Write-Host "Fixing SSH key permissions..." -ForegroundColor Gray
icacls $absoluteKeyPath /inheritance:r 2>$null | Out-Null
icacls $absoluteKeyPath /grant:r "${env:USERNAME}:R" 2>$null | Out-Null

Write-Host "EC2 IP: $EC2IP" -ForegroundColor Yellow
Write-Host "SSH Key: $absoluteKeyPath" -ForegroundColor Yellow
Write-Host "GitHub: $githubUrl (branch: $githubBranch)" -ForegroundColor Green
if ($Domain) { Write-Host "Domain: $Domain" -ForegroundColor Yellow }
if ($useHttps) { Write-Host "SSL: enabled (HTTPS)" -ForegroundColor Green }
Write-Host ""

# Build SSH target (avoid @$ in double quotes)
$sshTarget = "ubuntu@" + $EC2IP

# Test SSH connection
Write-Host "Testing SSH connection..." -ForegroundColor Cyan
$testResult = & ssh -i $absoluteKeyPath -o ConnectTimeout=5 -o StrictHostKeyChecking=no $sshTarget "echo connected" 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Cannot connect to EC2 instance" -ForegroundColor Red
    Write-Host "Please verify EC2 instance is running and accessible" -ForegroundColor Yellow
    exit 1
}

Write-Host "Connection successful" -ForegroundColor Green
Write-Host ""

# Check if frontend build exists locally
$localBuildPath = Join-Path $projectRoot "frontend\build\web"
if (-not (Test-Path $localBuildPath)) {
    Write-Host "ERROR: Frontend build not found locally" -ForegroundColor Red
    Write-Host ""
    Write-Host "Build the frontend first:" -ForegroundColor Yellow
    Write-Host "  .\scripts\build-frontend-local.ps1" -ForegroundColor Gray
    Write-Host "  git add frontend/build" -ForegroundColor Gray
    Write-Host "  git commit -m 'Build frontend'" -ForegroundColor Gray
    Write-Host "  git push origin main" -ForegroundColor Gray
    exit 1
}

# Check if frontend build is committed to git
$gitStatus = & git status --porcelain frontend/build 2>&1
if ($gitStatus) {
    Write-Host "WARNING: Frontend build has uncommitted changes" -ForegroundColor Yellow
    Write-Host "Commit and push before deploying:" -ForegroundColor Yellow
    Write-Host "  git add frontend/build" -ForegroundColor Gray
    Write-Host "  git commit -m 'Build frontend'" -ForegroundColor Gray
    Write-Host "  git push origin main" -ForegroundColor Gray
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -ne "y") {
        exit 1
    }
}

Write-Host "Frontend build found and committed" -ForegroundColor Green
Write-Host ""

# Step 1: Sync code from GitHub
Write-Host "Step 1: Syncing code from GitHub..." -ForegroundColor Cyan

# Ensure git is installed
Write-Host "  Checking git is installed..." -ForegroundColor Gray
& ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget 'which git || (sudo apt update && sudo apt install -y git)' 2>$null

Write-Host "  Pulling from GitHub ($githubBranch)..." -ForegroundColor Yellow

# Ensure ~/app directory exists
& ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget 'mkdir -p ~/app' 2>$null

# If using SSH URL, add GitHub to known_hosts and check SSH key setup
if ($githubUrl -match '^git@') {
    Write-Host "  Using SSH authentication..." -ForegroundColor Gray
    
    # Add GitHub to known_hosts to avoid "Host key verification failed"
    Write-Host "  Adding GitHub to known_hosts..." -ForegroundColor Gray
    $knownHostsCmd = "mkdir -p ~/.ssh && ssh-keyscan -t rsa,ecdsa,ed25519 github.com >> ~/.ssh/known_hosts 2>/dev/null || true"
    & ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget $knownHostsCmd 2>$null
    
    # Check if SSH key exists, if not provide instructions
    $keyCheck = & ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget 'test -f ~/.ssh/id_rsa -o -f ~/.ssh/id_ed25519 && echo "exists" || echo "missing"' 2>&1
    if ($keyCheck -eq "missing") {
        Write-Host "  WARNING: No SSH key found on EC2" -ForegroundColor Yellow
        Write-Host "  You need to set up SSH authentication:" -ForegroundColor Yellow
        Write-Host ("    1. SSH to EC2: ssh -i " + $absoluteKeyPath + " " + $sshTarget) -ForegroundColor Gray
        Write-Host "    2. Generate key: ssh-keygen -t ed25519 -C 'your_email@example.com' -f ~/.ssh/id_ed25519 -N ''" -ForegroundColor Gray
        Write-Host "    3. Add to GitHub: cat ~/.ssh/id_ed25519.pub" -ForegroundColor Gray
        Write-Host "    4. Copy output and add to GitHub Settings > SSH keys" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  Attempting to continue anyway..." -ForegroundColor Yellow
    }
}

# Test GitHub SSH connection first (if using SSH)
if ($githubUrl -match '^git@') {
    Write-Host "  Testing GitHub SSH connection..." -ForegroundColor Gray
    $githubTest = & ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget 'ssh -T git@github.com 2>&1' 2>&1
    if ($githubTest -match 'Permission denied|Could not resolve hostname') {
        Write-Host "  ERROR: Cannot connect to GitHub via SSH" -ForegroundColor Red
        Write-Host $githubTest -ForegroundColor Red
        Write-Host ""
        Write-Host "You need to set up SSH authentication on EC2:" -ForegroundColor Yellow
        Write-Host "  Run: .\scripts\setup-github-ssh.ps1" -ForegroundColor Cyan
        Write-Host "  Or manually SSH to EC2 and set up SSH keys" -ForegroundColor Gray
        exit 1
    } elseif ($githubTest -match 'successfully authenticated|Hi.*You') {
        Write-Host "  GitHub SSH connection successful" -ForegroundColor Green
    } else {
        Write-Host "  GitHub SSH test output: $githubTest" -ForegroundColor Yellow
    }
}

# Git clone/pull command - capture both stdout and stderr
Write-Host "  Cloning/pulling repository..." -ForegroundColor Gray
$gitCmd = "set -e; if [ -d ~/app/.git ]; then cd ~/app && git fetch origin && git reset --hard origin/" + $githubBranch + " && git pull origin " + $githubBranch + "; else (cp ~/app/.env /tmp/app.env.bak 2>/dev/null || true; rm -rf ~/app; git clone -b " + $githubBranch + " '" + $githubUrl + "' ~/app || exit 1; mv /tmp/app.env.bak ~/app/.env 2>/dev/null || true); fi"
$gitOutput = & ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget $gitCmd 2>&1
$gitExitCode = $LASTEXITCODE

# Display git output for debugging
if ($gitOutput) {
    Write-Host $gitOutput -ForegroundColor Gray
}

# Check if git command succeeded
if ($gitExitCode -ne 0) {
    Write-Host "ERROR: Git pull/clone failed (exit code: $gitExitCode)" -ForegroundColor Red
    Write-Host "Possible causes:" -ForegroundColor Yellow
    if ($githubUrl -match '^git@') {
        Write-Host "  - GitHub SSH key not set up on EC2" -ForegroundColor Gray
        Write-Host "  - Add your SSH public key to GitHub and EC2 ~/.ssh/authorized_keys" -ForegroundColor Gray
    } else {
        Write-Host "  - Repository is private (use SSH format: git@github.com:user/repo.git)" -ForegroundColor Gray
    }
    Write-Host "  - GITHUB_URL is incorrect" -ForegroundColor Gray
    Write-Host "  - Network issue on EC2" -ForegroundColor Gray
    Write-Host "" -ForegroundColor Gray
    Write-Host "To fix SSH authentication:" -ForegroundColor Yellow
    Write-Host ("  1. SSH to EC2: ssh -i " + $absoluteKeyPath + " " + $sshTarget) -ForegroundColor Gray
    Write-Host "  2. Generate SSH key: ssh-keygen -t ed25519 -C 'your_email@example.com'" -ForegroundColor Gray
    Write-Host "  3. Add to GitHub: cat ~/.ssh/id_ed25519.pub (then add to GitHub Settings > SSH keys)" -ForegroundColor Gray
    Write-Host ("  4. Test: ssh -T git@github.com") -ForegroundColor Gray
    exit 1
}

# Verify repository was cloned successfully
Write-Host "  Verifying repository..." -ForegroundColor Gray
$repoCheck = & ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget 'if [ -f ~/app/docker-compose.yml ]; then echo "exists"; else echo "missing"; fi' 2>&1
if ($repoCheck -ne "exists") {
    Write-Host "ERROR: Repository clone failed - docker-compose.yml not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Debugging information:" -ForegroundColor Yellow
    $dirCheck = & ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget 'ls -la ~/app 2>&1 | head -20' 2>&1
    Write-Host "Contents of ~/app:" -ForegroundColor Gray
    Write-Host $dirCheck -ForegroundColor Gray
    Write-Host ""
    Write-Host "The git clone likely failed. Common causes:" -ForegroundColor Yellow
    Write-Host "  - GitHub SSH key not set up (run: .\scripts\setup-github-ssh.ps1)" -ForegroundColor Gray
    Write-Host "  - Repository is private and authentication failed" -ForegroundColor Gray
    Write-Host "  - Network issue on EC2" -ForegroundColor Gray
    exit 1
}

Write-Host "  Code synced from GitHub" -ForegroundColor Green
Write-Host ""

# Step 2: Check/create .env file
Write-Host "Step 2: Checking environment configuration..." -ForegroundColor Cyan

$envExists = & ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget 'test -f ~/app/.env && echo exists || echo missing'

if ($envExists -eq "missing") {
    Write-Host "  .env file not found. Creating from template..." -ForegroundColor Yellow
    
    # Generate secret key
    Write-Host "  Generating SECRET_KEY..." -ForegroundColor Gray
    $secretKey = & python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())" 2>$null
    
    if (-not $secretKey) {
        Write-Host "  WARNING: Could not generate SECRET_KEY. Please set it manually." -ForegroundColor Yellow
        $secretKey = "CHANGE_ME_GENERATE_SECRET_KEY"
    }
    
    # Get domain or use IP
    if ($Domain) {
        $allowedHosts = "$Domain,www.$Domain,$EC2IP"
        $corsOrigins = "http://$Domain,https://$Domain,https://www.$Domain"
    } else {
        $allowedHosts = $EC2IP
        $corsOrigins = "http://" + $EC2IP
    }
    
    # Generate DB password
    $dbPassword = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})
    
    # Build env content line by line
    $envLines = @(
        "SECRET_KEY=$secretKey",
        "DEBUG=0",
        "ALLOWED_HOSTS=$allowedHosts",
        "DATABASE_URL=postgresql://counter_user:${dbPassword}@db:5432/counter_db",
        "POSTGRES_PASSWORD=$dbPassword",
        "CORS_ALLOWED_ORIGINS=$corsOrigins",
        "EC2_IP=$EC2IP"
    )
    $envContent = $envLines -join "`n"
    
    # Create .env on EC2 (ensure directory exists first)
    $envContent | & ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget 'mkdir -p ~/app && cat > ~/app/.env'
    
    Write-Host "  .env file created with generated values" -ForegroundColor Green
    Write-Host "  IMPORTANT: Save your database password: $dbPassword" -ForegroundColor Yellow
} else {
    Write-Host "  .env file exists (using existing configuration)" -ForegroundColor Green
}

Write-Host ""

# Step 3: Update nginx config with domain/IP
Write-Host "Step 3: Configuring nginx..." -ForegroundColor Cyan

if ($Domain) {
    $serverName = "$Domain www.$Domain"
} else {
    $serverName = $EC2IP
}

$nginxCmd = "cd ~/app && if [ -f infra/nginx/nginx.http.conf ]; then sed -i 's/server_name.*;/server_name $serverName;/' infra/nginx/nginx.http.conf; fi"
& ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget $nginxCmd 2>$null
Write-Host "  Nginx configured" -ForegroundColor Green
Write-Host ""

# Step 4: Deploy with Docker (uses pre-built frontend from git)
Write-Host "Step 4: Deploying with Docker..." -ForegroundColor Cyan
Write-Host "  (Using pre-built frontend from repository)" -ForegroundColor Gray

$deployCmd = "cd ~/app && docker compose " + $composeArgs + " down 2>/dev/null; docker compose " + $composeArgs + " up -d --build && sleep 10 && docker compose " + $composeArgs + " ps"
& ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget $deployCmd

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker deployment failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "If frontend build is missing, run locally:" -ForegroundColor Yellow
    Write-Host "  .\scripts\build-frontend-local.ps1" -ForegroundColor Gray
    Write-Host "  git add frontend/build && git commit -m 'Build frontend' && git push" -ForegroundColor Gray
    exit 1
}

Write-Host "  Docker services started" -ForegroundColor Green
Write-Host ""

# Step 5: Run migrations (if not skipped)
if (-not $SkipMigrations) {
    Write-Host "Step 5: Running database migrations..." -ForegroundColor Cyan
    
    $migrateCmd = "cd ~/app && docker compose " + $composeArgs + " exec -T backend python manage.py migrate --noinput && docker compose " + $composeArgs + " exec -T backend python manage.py collectstatic --noinput"
& ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget $migrateCmd
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARNING: Migrations may have failed. Check logs manually." -ForegroundColor Yellow
    } else {
        Write-Host "  Migrations completed" -ForegroundColor Green
    }
    Write-Host ""
} else {
    Write-Host "Step 5: Skipping migrations (-SkipMigrations)" -ForegroundColor Yellow
    Write-Host ""
}

# Step 6: Verify deployment
Write-Host "Step 6: Verifying deployment..." -ForegroundColor Cyan

$verifyCmd = "cd ~/app && docker compose " + $composeArgs + " ps"
& ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget $verifyCmd

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

if ($Domain) {
    $appUrl = "http://$Domain"
} else {
    $appUrl = "http://" + $EC2IP
}

Write-Host "Your app is now live at:" -ForegroundColor Yellow
Write-Host "  $appUrl" -ForegroundColor Cyan
Write-Host ""

Write-Host "Useful commands:" -ForegroundColor Yellow
Write-Host ("  View logs: ssh -i " + $absoluteKeyPath + " " + $sshTarget + " 'cd ~/app && docker compose logs -f'") -ForegroundColor Gray
Write-Host ("  Stop: ssh -i " + $absoluteKeyPath + " " + $sshTarget + " 'cd ~/app && docker compose down'") -ForegroundColor Gray
Write-Host ("  Restart: ssh -i " + $absoluteKeyPath + " " + $sshTarget + " 'cd ~/app && docker compose restart'") -ForegroundColor Gray
Write-Host ""
