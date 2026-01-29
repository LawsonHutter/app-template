# Fix SSH Key Permissions (Windows PowerShell)
# This fixes the "bad permissions" error when connecting to EC2

param(
    [Parameter(Mandatory=$false)]
    [string]$KeyFile = "survey-app-key.pem"
)

Write-Host "Fixing SSH key permissions..." -ForegroundColor Cyan
Write-Host ""

# Find the key file if not in current directory
if (-not (Test-Path $KeyFile)) {
    Write-Host "Key file not found in current directory. Searching..." -ForegroundColor Yellow
    $found = Get-ChildItem -Path . -Filter "*.pem" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    
    if ($found) {
        $KeyFile = $found.FullName
        Write-Host "Found key file: $KeyFile" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Key file not found. Please provide the path:" -ForegroundColor Red
        $KeyFile = Read-Host "Key file path"
        
        if (-not (Test-Path $KeyFile)) {
            Write-Host "ERROR: File not found: $KeyFile" -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host "Fixing permissions for: $KeyFile" -ForegroundColor Yellow
Write-Host ""

# Remove inheritance and all permissions
icacls $KeyFile /inheritance:r

# Grant full control only to current user
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
icacls $KeyFile /grant:r "${currentUser}:F"

# Remove all other users/groups
icacls $KeyFile /remove "BUILTIN\Users" 2>$null
icacls $KeyFile /remove "Everyone" 2>$null
icacls $KeyFile /remove "Users" 2>$null

Write-Host ""
Write-Host "Permissions fixed!" -ForegroundColor Green
Write-Host ""
Write-Host "You can now connect using:" -ForegroundColor Cyan
Write-Host "  ssh -i $KeyFile ubuntu@YOUR-EC2-IP" -ForegroundColor Gray
Write-Host ""
