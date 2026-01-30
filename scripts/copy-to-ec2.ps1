# Copy Project Files to EC2 (Windows PowerShell)
# This copies your project files directly to EC2 without needing Git

param(
    [Parameter(Mandatory=$false)]
    [string]$Ec2Ip = "YOUR_EC2_IP_ADDRESS",
    [Parameter(Mandatory=$false)]
    [string]$KeyFile = "security\app-key.pem"
)

Write-Host "Copying project files to EC2..." -ForegroundColor Cyan
Write-Host ""

# Get project root
$projectRoot = Split-Path -Parent $PSScriptRoot

# Find key file
if (-not (Test-Path $KeyFile)) {
    $KeyFile = "$projectRoot\security\app-key.pem"
    if (-not (Test-Path $KeyFile)) {
        Write-Host "ERROR: Key file not found" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Source: $projectRoot" -ForegroundColor Gray
Write-Host "Destination: ubuntu@${Ec2Ip}:~/app/" -ForegroundColor Gray
Write-Host "Key: $KeyFile" -ForegroundColor Gray
Write-Host ""

# Create .scpignore or exclude common files
Write-Host "Copying files (this may take a minute)..." -ForegroundColor Yellow

# Copy backend directory explicitly
Write-Host "Copying backend directory..." -ForegroundColor Yellow
scp -i $KeyFile -r `
    -o "StrictHostKeyChecking=no" `
    "$projectRoot\backend" "ubuntu@${Ec2Ip}:~/app/"

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to copy backend directory" -ForegroundColor Red
    exit 1
}

# Copy frontend directory explicitly
Write-Host "Copying frontend directory..." -ForegroundColor Yellow
scp -i $KeyFile -r `
    -o "StrictHostKeyChecking=no" `
    "$projectRoot\frontend" "ubuntu@${Ec2Ip}:~/app/"

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to copy frontend directory" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Files copied successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps on EC2:" -ForegroundColor Cyan
Write-Host "  cd ~/app" -ForegroundColor Gray
Write-Host "  # Then continue with deployment steps" -ForegroundColor Gray
