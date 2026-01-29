# Connect to EC2 Instance (Windows PowerShell)
# This script helps you connect to your EC2 instance

Write-Host "EC2 Connection Helper" -ForegroundColor Cyan
Write-Host ""

# Get project root directory
$projectRoot = Split-Path -Parent $PSScriptRoot

# Check if key file exists - try common locations
$keyFile = $null
$possiblePaths = @(
    "$projectRoot\security\survey-app-key.pem",
    "$projectRoot\survey-app-key.pem",
    "security\survey-app-key.pem",
    ".\security\survey-app-key.pem",
    "$env:USERPROFILE\.ssh\survey-app-key.pem"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $keyFile = $path
        break
    }
}

if (-not $keyFile) {
    Write-Host "Key file not found in common locations." -ForegroundColor Yellow
    Write-Host "Please provide the path to your .pem key file:" -ForegroundColor Yellow
    $keyFile = Read-Host "Key file path"
    
    if (-not (Test-Path $keyFile)) {
        Write-Host "ERROR: File not found: $keyFile" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Key file found: $keyFile" -ForegroundColor Green
Write-Host ""

# Get EC2 IP address
Write-Host "Enter your EC2 instance IP address:" -ForegroundColor Yellow
Write-Host "  (Find it in AWS Console -> EC2 -> Instances -> Public IPv4 address)" -ForegroundColor Gray
$ec2Ip = Read-Host "EC2 IP address"

if ([string]::IsNullOrWhiteSpace($ec2Ip)) {
    Write-Host "ERROR: IP address is required" -ForegroundColor Red
    exit 1
}

# Validate IP format (basic check)
if ($ec2Ip -notmatch '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') {
    Write-Host "WARNING: IP address format looks incorrect: $ec2Ip" -ForegroundColor Yellow
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne 'y') {
        exit 1
    }
}

Write-Host ""
Write-Host "Connecting to EC2 instance..." -ForegroundColor Cyan
Write-Host "  IP: $ec2Ip" -ForegroundColor Gray
Write-Host "  User: ubuntu" -ForegroundColor Gray
Write-Host "  Key: $keyFile" -ForegroundColor Gray
Write-Host ""
Write-Host "If this is your first time connecting, type 'yes' when prompted." -ForegroundColor Yellow
Write-Host ""

# Convert to absolute path
if (Test-Path $keyFile) {
    $keyPath = (Resolve-Path $keyFile).Path
} else {
    Write-Host "ERROR: Key file not found: $keyFile" -ForegroundColor Red
    exit 1
}

# Connect via SSH
ssh -i $keyPath ubuntu@$ec2Ip
