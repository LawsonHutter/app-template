# Auto Deploy to EC2
# This script automatically deploys your app to EC2 instance
# It copies code, builds frontend, sets up environment, and starts services
# Reads from security/deployment.config if no parameters provided

param(
    [Parameter(Mandatory=$false)]
    [string]$EC2IP = "",
    
    [Parameter(Mandatory=$false)]
    [string]$KeyPath = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Domain = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipBuild = $false,
    
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

# GitHub URL for git-based deploy (faster than SCP)
$githubUrl = $config["GITHUB_URL"]
$githubBranch = $config["GITHUB_BRANCH"]
if ([string]::IsNullOrWhiteSpace($githubBranch)) { $githubBranch = "main" }

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
if ($Domain) { Write-Host "Domain: $Domain" -ForegroundColor Yellow }
if ($githubUrl) { Write-Host "Deploy mode: git ($githubUrl)" -ForegroundColor Green } else { Write-Host "Deploy mode: SCP (copy files)" -ForegroundColor Yellow }
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

# Step 1: Sync code to EC2 (git pull or SCP)
Write-Host "Step 1: Syncing code to EC2..." -ForegroundColor Cyan
Write-Host ""

if (-not [string]::IsNullOrWhiteSpace($githubUrl)) {
    # Git-based deploy: clone or pull from GitHub (faster)
    $gitCmd = "if [ -d ~/app/.git ]; then cd ~/app && git fetch origin && git reset --hard origin/" + $githubBranch + " && git pull origin " + $githubBranch + "; else (cp ~/app/.env /tmp/app.env.bak 2>/dev/null; rm -rf ~/app; git clone -b " + $githubBranch + " '" + $githubUrl + "' ~/app; mv /tmp/app.env.bak ~/app/.env 2>/dev/null); fi"
    Write-Host "  Pulling from GitHub ($githubBranch)..." -ForegroundColor Yellow
    & ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget $gitCmd

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Git pull/clone failed" -ForegroundColor Red
        Write-Host "Check GITHUB_URL in security\deployment.config" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "  Code synced from GitHub" -ForegroundColor Green
} else {
    # SCP deploy: copy files
    $scpBackendDest = $sshTarget + ":~/app/"
    Write-Host "  Copying backend..." -ForegroundColor Yellow
    & scp -i $absoluteKeyPath -r -o StrictHostKeyChecking=no "$projectRoot\backend" $scpBackendDest 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to copy backend" -ForegroundColor Red
        exit 1
    }
    Write-Host "  Backend copied" -ForegroundColor Green

    Write-Host "  Copying frontend..." -ForegroundColor Yellow
    & scp -i $absoluteKeyPath -r -o StrictHostKeyChecking=no "$projectRoot\frontend" $scpBackendDest 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to copy frontend" -ForegroundColor Red
        exit 1
    }
    Write-Host "  Frontend copied" -ForegroundColor Green

    Write-Host "  Copying Docker configuration..." -ForegroundColor Yellow
    & scp -i $absoluteKeyPath -o StrictHostKeyChecking=no "$projectRoot\docker-compose.yml" $scpBackendDest 2>$null
    & scp -i $absoluteKeyPath -o StrictHostKeyChecking=no "$projectRoot\docker-compose.prod.yml" $scpBackendDest 2>$null

    $nginxConfPath = "$projectRoot\infra\nginx\nginx.http.conf"
    if (Test-Path $nginxConfPath) {
        & ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget 'mkdir -p ~/app/infra/nginx' 2>$null
        $scpNginxDest = $sshTarget + ":~/app/infra/nginx/"
        & scp -i $absoluteKeyPath -o StrictHostKeyChecking=no $nginxConfPath $scpNginxDest 2>$null
    }
    Write-Host "  Configuration files copied" -ForegroundColor Green
}

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
    
    # Create .env on EC2
    $envContent | & ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget 'cat > ~/app/.env'
    
    Write-Host "  .env file created with generated values" -ForegroundColor Green
    Write-Host "  IMPORTANT: Save your database password: $dbPassword" -ForegroundColor Yellow
} else {
    Write-Host "  .env file exists (using existing configuration)" -ForegroundColor Green
}

Write-Host ""

# Step 3: Build frontend (if not skipped)
if (-not $SkipBuild) {
    Write-Host "Step 3: Building frontend on EC2..." -ForegroundColor Cyan
    Write-Host "  (This may take 5-10 minutes)" -ForegroundColor Gray
    
    & ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget 'cd ~/app/frontend && flutter pub get && flutter build web --release'
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Frontend build failed" -ForegroundColor Red
        Write-Host "You can skip this step with -SkipBuild and build manually" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "  Frontend built successfully" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "Step 3: Skipping frontend build (-SkipBuild)" -ForegroundColor Yellow
    Write-Host ""
}

# Step 4: Update nginx config with domain/IP
Write-Host "Step 4: Configuring nginx..." -ForegroundColor Cyan

if ($Domain) {
    $serverName = "$Domain www.$Domain"
} else {
    $serverName = $EC2IP
}

$nginxCmd = "cd ~/app && if [ -f infra/nginx/nginx.http.conf ]; then sed -i 's/server_name.*;/server_name $serverName;/' infra/nginx/nginx.http.conf; fi"
& ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget $nginxCmd 2>$null
Write-Host "  Nginx configured" -ForegroundColor Green
Write-Host ""

# Step 5: Deploy with Docker
Write-Host "Step 5: Deploying with Docker..." -ForegroundColor Cyan

& ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget 'cd ~/app && docker compose -f docker-compose.yml -f docker-compose.prod.yml down 2>/dev/null; docker compose -f docker-compose.yml -f docker-compose.prod.yml build --no-cache && docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d && sleep 10 && docker compose -f docker-compose.yml -f docker-compose.prod.yml ps'

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker deployment failed" -ForegroundColor Red
    exit 1
}

Write-Host "  Docker services started" -ForegroundColor Green
Write-Host ""

# Step 6: Run migrations (if not skipped)
if (-not $SkipMigrations) {
    Write-Host "Step 6: Running database migrations..." -ForegroundColor Cyan
    
    & ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget 'cd ~/app && docker compose -f docker-compose.yml -f docker-compose.prod.yml exec -T backend python manage.py migrate --noinput && docker compose -f docker-compose.yml -f docker-compose.prod.yml exec -T backend python manage.py collectstatic --noinput'
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARNING: Migrations may have failed. Check logs manually." -ForegroundColor Yellow
    } else {
        Write-Host "  Migrations completed" -ForegroundColor Green
    }
    Write-Host ""
} else {
    Write-Host "Step 6: Skipping migrations (-SkipMigrations)" -ForegroundColor Yellow
    Write-Host ""
}

# Step 7: Verify deployment
Write-Host "Step 7: Verifying deployment..." -ForegroundColor Cyan

& ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget 'cd ~/app && docker compose -f docker-compose.yml -f docker-compose.prod.yml ps'

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
