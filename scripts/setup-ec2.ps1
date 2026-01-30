# Setup New EC2 Instance
# This script guides you through setting up a fresh EC2 instance for deployment
# Reads from security/deployment.config if no parameters provided

param(
    [Parameter(Mandatory=$false)]
    [string]$EC2IP = "",
    
    [Parameter(Mandatory=$false)]
    [string]$KeyPath = ""
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  EC2 Instance Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get project root
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

# Use Elastic IP if set, otherwise fall back to EC2_IP
if ([string]::IsNullOrWhiteSpace($EC2IP)) {
    if (-not [string]::IsNullOrWhiteSpace($config["EC2_ELASTIC_IP"])) {
        $EC2IP = $config["EC2_ELASTIC_IP"]
        Write-Host "Using Elastic IP from config: $EC2IP" -ForegroundColor Green
    } elseif (-not [string]::IsNullOrWhiteSpace($config["EC2_IP"])) {
        $EC2IP = $config["EC2_IP"]
        Write-Host "Using EC2 IP from config: $EC2IP" -ForegroundColor Yellow
    } else {
        Write-Host "Enter your EC2 instance IP address:" -ForegroundColor Yellow
        Write-Host "  (Find it in AWS Console -> EC2 -> Instances -> Public IPv4 address)" -ForegroundColor Gray
        $EC2IP = Read-Host "EC2 IP address"
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

# Resolve key path
$absoluteKeyPath = Join-Path $projectRoot $KeyPath
if (-not (Test-Path $absoluteKeyPath)) {
    Write-Host "ERROR: SSH key not found at: $absoluteKeyPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "  1. Download your .pem key from AWS Console" -ForegroundColor Gray
    Write-Host "  2. Save it to: $absoluteKeyPath" -ForegroundColor Gray
    Write-Host "  3. Or set KEY_PATH in security\deployment.config" -ForegroundColor Gray
    exit 1
}

# Fix key file permissions (Windows requires restricted permissions for SSH keys)
Write-Host "Fixing SSH key permissions..." -ForegroundColor Gray
icacls $absoluteKeyPath /inheritance:r 2>$null | Out-Null
icacls $absoluteKeyPath /grant:r "${env:USERNAME}:R" 2>$null | Out-Null

Write-Host ""
Write-Host "EC2 IP: $EC2IP" -ForegroundColor Yellow
Write-Host "SSH Key: $absoluteKeyPath" -ForegroundColor Yellow
Write-Host ""

# Build SSH target (avoid @$ in double quotes which can cause parsing issues)
$sshTarget = "ubuntu@" + $EC2IP

# Test SSH connection
Write-Host "Testing SSH connection..." -ForegroundColor Cyan
$testResult = & ssh -i $absoluteKeyPath -o ConnectTimeout=5 -o StrictHostKeyChecking=no $sshTarget "echo connected" 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Cannot connect to EC2 instance" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please verify:" -ForegroundColor Yellow
    Write-Host "  1. EC2 instance is running" -ForegroundColor Gray
    Write-Host "  2. Security group allows SSH (port 22) from your IP" -ForegroundColor Gray
    Write-Host "  3. IP address is correct" -ForegroundColor Gray
    Write-Host "  4. Key file is correct" -ForegroundColor Gray
    exit 1
}

Write-Host "Connection successful!" -ForegroundColor Green
Write-Host ""

# Path to the bash script that runs on EC2
$setupScriptPath = Join-Path $PSScriptRoot "setup-ec2-remote.sh"
if (-not (Test-Path $setupScriptPath)) {
    Write-Host "ERROR: setup-ec2-remote.sh not found at $setupScriptPath" -ForegroundColor Red
    exit 1
}

Write-Host "Running setup on EC2 instance..." -ForegroundColor Cyan
Write-Host "  (This may take 5-10 minutes)" -ForegroundColor Gray
Write-Host ""

# Convert script to Unix line endings (CRLF -> LF) before copying
$scriptContent = Get-Content $setupScriptPath -Raw
$scriptContent = $scriptContent -replace "`r`n", "`n"
$tempScript = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tempScript, $scriptContent)

# Copy setup script to EC2
$scpDest = $sshTarget + ":/tmp/setup-ec2.sh"
& scp -i $absoluteKeyPath -o StrictHostKeyChecking=no $tempScript $scpDest | Out-Null
Remove-Item $tempScript -ErrorAction SilentlyContinue

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to copy setup script" -ForegroundColor Red
    exit 1
}

# Run setup script on EC2
& ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget 'chmod +x /tmp/setup-ec2.sh && /tmp/setup-ec2.sh && rm /tmp/setup-ec2.sh'

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Setup failed on EC2 instance" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  EC2 Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your EC2 instance is ready for deployment!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host ("  1. Run: .\scripts\auto-deploy-ec2.ps1 -EC2IP " + $EC2IP) -ForegroundColor Gray
Write-Host "     This will copy your code and deploy automatically" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Or manually:" -ForegroundColor Gray
Write-Host ("     - Copy code: .\scripts\copy-backend-frontend-to-ec2.ps1 -EC2IP " + $EC2IP) -ForegroundColor Gray
Write-Host ("     - SSH and configure: ssh -i " + $absoluteKeyPath + " " + $sshTarget) -ForegroundColor Gray
Write-Host ""
