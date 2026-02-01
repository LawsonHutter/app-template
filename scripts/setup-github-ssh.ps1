# Setup GitHub SSH Authentication on EC2
# This script helps set up SSH keys on your EC2 instance for GitHub access
# Reads from security/deployment.config if no parameters provided

param(
    [Parameter(Mandatory=$false)]
    [string]$EC2IP = "",
    
    [Parameter(Mandatory=$false)]
    [string]$KeyPath = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Email = ""
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup GitHub SSH on EC2" -ForegroundColor Cyan
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
}

# Use Elastic IP if set, otherwise fall back to EC2_IP
if ([string]::IsNullOrWhiteSpace($EC2IP)) {
    if (-not [string]::IsNullOrWhiteSpace($config["EC2_ELASTIC_IP"])) {
        $EC2IP = $config["EC2_ELASTIC_IP"]
    } elseif (-not [string]::IsNullOrWhiteSpace($config["EC2_IP"])) {
        $EC2IP = $config["EC2_IP"]
    } else {
        Write-Host "Enter your EC2 instance IP address:" -ForegroundColor Yellow
        $EC2IP = Read-Host "EC2 IP address"
    }
}

# Use KeyPath from config if not provided
if ([string]::IsNullOrWhiteSpace($KeyPath)) {
    if (-not [string]::IsNullOrWhiteSpace($config["KEY_PATH"])) {
        $KeyPath = $config["KEY_PATH"]
    } else {
        $KeyPath = "security\app-key.pem"
    }
}

# Get email for SSH key
if ([string]::IsNullOrWhiteSpace($Email)) {
    $Email = Read-Host "Enter your email for SSH key (or press Enter to skip)"
}

# Resolve key path
$absoluteKeyPath = Join-Path $projectRoot $KeyPath
if (-not (Test-Path $absoluteKeyPath)) {
    Write-Host "ERROR: SSH key not found at: $absoluteKeyPath" -ForegroundColor Red
    exit 1
}

# Build SSH target
$sshTarget = "ubuntu@" + $EC2IP

Write-Host "EC2 IP: $EC2IP" -ForegroundColor Yellow
Write-Host "SSH Key: $absoluteKeyPath" -ForegroundColor Yellow
Write-Host ""

# Test SSH connection
Write-Host "Testing SSH connection..." -ForegroundColor Cyan
$testResult = & ssh -i $absoluteKeyPath -o ConnectTimeout=5 -o StrictHostKeyChecking=no $sshTarget "echo connected" 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Cannot connect to EC2 instance" -ForegroundColor Red
    exit 1
}

Write-Host "Connection successful!" -ForegroundColor Green
Write-Host ""

# Check if SSH key already exists
Write-Host "Checking for existing SSH keys..." -ForegroundColor Cyan
$keyExists = & ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget 'test -f ~/.ssh/id_ed25519 -o -f ~/.ssh/id_rsa && echo "exists" || echo "missing"' 2>&1

if ($keyExists -eq "exists") {
    Write-Host "SSH key already exists on EC2" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Your public key:" -ForegroundColor Cyan
    & ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget 'cat ~/.ssh/id_ed25519.pub 2>/dev/null || cat ~/.ssh/id_rsa.pub 2>/dev/null' 2>&1
    Write-Host ""
    Write-Host "If this key is already added to GitHub, you're all set!" -ForegroundColor Green
    Write-Host "If not, copy the key above and add it to:" -ForegroundColor Yellow
    Write-Host "  https://github.com/settings/ssh/new" -ForegroundColor Cyan
    exit 0
}

# Generate SSH key
Write-Host "Generating new SSH key..." -ForegroundColor Cyan
if ($Email) {
    $keygenCmd = "ssh-keygen -t ed25519 -C '$Email' -f ~/.ssh/id_ed25519 -N '' -q"
} else {
    $keygenCmd = "ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N '' -q"
}

& ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget $keygenCmd 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to generate SSH key" -ForegroundColor Red
    exit 1
}

# Add GitHub to known_hosts
Write-Host "Adding GitHub to known_hosts..." -ForegroundColor Cyan
& ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget 'mkdir -p ~/.ssh && ssh-keyscan -t rsa,ecdsa,ed25519 github.com >> ~/.ssh/known_hosts 2>/dev/null' 2>&1

# Display public key
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  SSH Key Generated!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your public key:" -ForegroundColor Cyan
$publicKey = & ssh -i $absoluteKeyPath -o StrictHostKeyChecking=no $sshTarget 'cat ~/.ssh/id_ed25519.pub' 2>&1
Write-Host $publicKey -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Copy the key above (entire line starting with ssh-ed25519)" -ForegroundColor Gray
Write-Host "  2. Go to: https://github.com/settings/ssh/new" -ForegroundColor Gray
Write-Host "  3. Paste the key and click 'Add SSH key'" -ForegroundColor Gray
Write-Host "  4. Test the connection:" -ForegroundColor Gray
Write-Host ("     ssh -i " + $absoluteKeyPath + " " + $sshTarget + " 'ssh -T git@github.com'") -ForegroundColor Cyan
Write-Host ""
Write-Host "After adding the key to GitHub, you can run:" -ForegroundColor Yellow
Write-Host "  .\scripts\auto-deploy-ec2.ps1" -ForegroundColor Cyan
Write-Host ""
