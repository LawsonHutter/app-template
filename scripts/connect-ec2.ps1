# Connect to EC2 Instance (Windows PowerShell)
# This script helps you connect to your EC2 instance
# Reads from security/deployment.config if available

Write-Host "EC2 Connection Helper" -ForegroundColor Cyan
Write-Host ""

# Get project root directory
$projectRoot = Split-Path -Parent $PSScriptRoot

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

# Get EC2 IP (prefer Elastic IP)
$ec2Ip = $null
if (-not [string]::IsNullOrWhiteSpace($config["EC2_ELASTIC_IP"])) {
    $ec2Ip = $config["EC2_ELASTIC_IP"]
    Write-Host "Using Elastic IP from config: $ec2Ip" -ForegroundColor Green
} elseif (-not [string]::IsNullOrWhiteSpace($config["EC2_IP"])) {
    $ec2Ip = $config["EC2_IP"]
    Write-Host "Using EC2 IP from config: $ec2Ip" -ForegroundColor Yellow
} else {
    Write-Host "Enter your EC2 instance IP address:" -ForegroundColor Yellow
    Write-Host "  (Find it in AWS Console -> EC2 -> Instances -> Public IPv4 address)" -ForegroundColor Gray
    $ec2Ip = Read-Host "EC2 IP address"
}

if ([string]::IsNullOrWhiteSpace($ec2Ip)) {
    Write-Host "ERROR: IP address is required" -ForegroundColor Red
    Write-Host "Set EC2_ELASTIC_IP or EC2_IP in security\deployment.config" -ForegroundColor Yellow
    exit 1
}

# Get key path from config or search common locations
$keyFile = $null
if (-not [string]::IsNullOrWhiteSpace($config["KEY_PATH"])) {
    $keyFile = Join-Path $projectRoot $config["KEY_PATH"]
}

if (-not $keyFile -or -not (Test-Path $keyFile)) {
    $possiblePaths = @(
        "$projectRoot\security\counter-app-key.pem",
        "$projectRoot\security\app-key.pem",
        "$projectRoot\app-key.pem"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $keyFile = $path
            break
        }
    }
}

if (-not $keyFile -or -not (Test-Path $keyFile)) {
    Write-Host "ERROR: SSH key not found" -ForegroundColor Red
    Write-Host "Set KEY_PATH in security\deployment.config" -ForegroundColor Yellow
    exit 1
}

# Fix key file permissions (Windows requires restricted permissions for SSH keys)
Write-Host "Fixing SSH key permissions..." -ForegroundColor Gray
icacls $keyFile /inheritance:r 2>$null | Out-Null
icacls $keyFile /grant:r "${env:USERNAME}:R" 2>$null | Out-Null

Write-Host ""
Write-Host "Connecting to EC2 instance..." -ForegroundColor Cyan
Write-Host "  IP: $ec2Ip" -ForegroundColor Gray
Write-Host "  User: ubuntu" -ForegroundColor Gray
Write-Host "  Key: $keyFile" -ForegroundColor Gray
Write-Host ""
Write-Host "If this is your first time connecting, type 'yes' when prompted." -ForegroundColor Yellow
Write-Host ""

# Build SSH target (avoid @$ in double quotes)
$sshTarget = "ubuntu@" + $ec2Ip

# Connect via SSH
& ssh -i $keyFile $sshTarget
