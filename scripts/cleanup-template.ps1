# Cleanup Template Scripts
# This script helps identify and remove duplicate/unused scripts when using this project as a template

Write-Host "Template Cleanup Script" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = Split-Path -Parent $PSScriptRoot
$scriptsDir = $PSScriptRoot

Write-Host "This script will help you clean up duplicate and unused scripts." -ForegroundColor Yellow
Write-Host ""
Write-Host "Scripts that can be safely removed:" -ForegroundColor Green
Write-Host ""

# List scripts to remove
$scriptsToRemove = @(
    @{
        Name = "start-backend-local.bat"
        Reason = "Duplicate of start-backend-local.ps1 (PowerShell preferred)"
    },
    @{
        Name = "start-frontend-local.bat"
        Reason = "Duplicate of start-frontend-local.ps1 (PowerShell preferred)"
    },
    @{
        Name = "start-docker.bat"
        Reason = "Duplicate of start-docker.ps1 (PowerShell preferred)"
    },
    @{
        Name = "stop-docker.bat"
        Reason = "Duplicate of stop-docker.ps1 (PowerShell preferred)"
    },
    @{
        Name = "start-all-local.ps1"
        Reason = "Use start-all-local-sqlite.ps1 instead (handles Docker conflicts)"
    },
    @{
        Name = "start-local-with-sqlite.ps1"
        Reason = "Duplicate functionality (use start-backend-local.ps1)"
    },
    @{
        Name = "stop-docker-before-local.ps1"
        Reason = "Functionality handled by start-all-local-sqlite.ps1"
    },
    @{
        Name = "generate-secret-key-simple.ps1"
        Reason = "Use generate-secret-key.ps1 instead (more features)"
    }
)

# Display scripts that can be removed
foreach ($script in $scriptsToRemove) {
    $scriptPath = Join-Path $scriptsDir $script.Name
    if (Test-Path $scriptPath) {
        Write-Host "  [ ] $($script.Name)" -ForegroundColor Yellow
        Write-Host "      Reason: $($script.Reason)" -ForegroundColor Gray
    } else {
        Write-Host "  [✓] $($script.Name) - Already removed" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Scripts to review (may be unused depending on your setup):" -ForegroundColor Cyan
Write-Host ""

$scriptsToReview = @(
    @{
        Name = "check-backend.ps1"
        Reason = "May not be needed if not using specific backend checks"
    },
    @{
        Name = "check-deployment.ps1"
        Reason = "Only needed if deploying to EC2/AWS"
    },
    @{
        Name = "build-ios.ps1"
        Reason = "Only needed if building iOS apps"
    },
    @{
        Name = "build-ios.sh"
        Reason = "Only needed if building iOS apps on macOS"
    },
    @{
        Name = "connect-ec2.ps1"
        Reason = "Only needed if deploying to AWS EC2"
    },
    @{
        Name = "copy-to-ec2.ps1"
        Reason = "Only needed if deploying to AWS EC2"
    },
    @{
        Name = "copy-backend-frontend-to-ec2.ps1"
        Reason = "Only needed if deploying to AWS EC2"
    },
    @{
        Name = "deploy-domain.ps1"
        Reason = "Only needed if using custom domain deployment"
    },
    @{
        Name = "fix-ssh-permissions.ps1"
        Reason = "Only needed if having SSH permission issues"
    }
)

foreach ($script in $scriptsToReview) {
    $scriptPath = Join-Path $scriptsDir $script.Name
    if (Test-Path $scriptPath) {
        Write-Host "  [?] $($script.Name)" -ForegroundColor Yellow
        Write-Host "      Reason: $($script.Reason)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "Core scripts to KEEP:" -ForegroundColor Green
Write-Host ""

$coreScripts = @(
    "start-backend-local.ps1",
    "start-frontend-local.ps1",
    "start-all-local-sqlite.ps1",
    "start-docker.ps1",
    "start-docker-detached.ps1",
    "stop-docker.ps1",
    "migrate-docker.ps1",
    "view-db.ps1",
    "generate-secret-key.ps1",
    "create-env.ps1"
)

foreach ($script in $coreScripts) {
    $scriptPath = Join-Path $scriptsDir $script
    if (Test-Path $scriptPath) {
        Write-Host "  [✓] $script" -ForegroundColor Green
    } else {
        Write-Host "  [!] $script - MISSING!" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Optional: Remove duplicate scripts automatically?" -ForegroundColor Yellow
$response = Read-Host "Type 'yes' to remove duplicate .bat files and unused scripts"

if ($response -eq "yes") {
    Write-Host ""
    Write-Host "Removing duplicate scripts..." -ForegroundColor Yellow
    
    $removed = 0
    foreach ($script in $scriptsToRemove) {
        $scriptPath = Join-Path $scriptsDir $script.Name
        if (Test-Path $scriptPath) {
            try {
                Remove-Item $scriptPath -Force
                Write-Host "  [✓] Removed: $($script.Name)" -ForegroundColor Green
                $removed++
            } catch {
                Write-Host "  [✗] Failed to remove: $($script.Name)" -ForegroundColor Red
            }
        }
    }
    
    Write-Host ""
    Write-Host "Removed $removed script(s)." -ForegroundColor Green
    Write-Host ""
    Write-Host "Note: Review scripts marked with [?] above and remove manually if not needed." -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "No scripts removed. Review the list above and remove manually if desired." -ForegroundColor Gray
}

Write-Host ""
Write-Host "Cleanup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Review scripts marked with [?] and remove if not needed" -ForegroundColor Gray
Write-Host "  2. Customize project name, domain, and bundle IDs" -ForegroundColor Gray
Write-Host "  3. See docs/TEMPLATE_INSTRUCTIONS.md for full customization guide" -ForegroundColor Gray
Write-Host ""
