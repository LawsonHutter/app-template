# Setup New Project from Template
# Run this script when creating a new project from the template

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$true)]
    [string]$Domain,
    
    [Parameter(Mandatory=$true)]
    [string]$BundleId,
    
    [Parameter(Mandatory=$false)]
    [string]$AppName = $ProjectName
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Setting Up New Project from Template" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Project Configuration:" -ForegroundColor Yellow
Write-Host "  Project Name: $ProjectName" -ForegroundColor Gray
Write-Host "  Domain: $Domain" -ForegroundColor Gray
Write-Host "  Bundle ID: $BundleId" -ForegroundColor Gray
Write-Host "  App Name: $AppName" -ForegroundColor Gray
Write-Host ""

$confirm = Read-Host "Continue? (y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Cancelled." -ForegroundColor Red
    exit 0
}

Write-Host ""
Write-Host "Updating files..." -ForegroundColor Green

# Replacements
$replacements = @{
    "yourdomain.com" = $Domain
    "com.yourdomain.yourapp" = $BundleId
    "your-app-name" = $ProjectName
    "Your App Name" = $AppName
    "YOUR_KEY_ID" = "REPLACE_WITH_YOUR_KEY_ID"
    "YOUR_ISSUER_ID" = "REPLACE_WITH_YOUR_ISSUER_ID"
    "YOUR_TEAM_ID" = "REPLACE_WITH_YOUR_TEAM_ID"
}

# Files to update
$filesToUpdate = @(
    "codemagic.yaml",
    "frontend/lib/survey_screen.dart",
    "frontend/lib/main.dart",
    "readme.md",
    "docs/DEPLOYMENT_STEPS.md",
    "docs/TESTFLIGHT_DEPLOYMENT.md",
    "docs/BUNDLE_ID_SETUP.md",
    "docs/VERIFY_API_CREDENTIALS.md",
    "docs/CHECK_APP_EXISTS.md",
    "docs/FIX_API_CONNECTION.md",
    "docs/LAUNCH_APP_TESTFLIGHT.md",
    "scripts/create-env.ps1",
    "scripts/check-deployment.ps1",
    "scripts/build-and-deploy-frontend.ps1",
    "infra/nginx/nginx.prod.conf",
    "docker-compose.prod.yml"
)

$updatedCount = 0
$errorCount = 0

foreach ($file in $filesToUpdate) {
    if (Test-Path $file) {
        try {
            $content = Get-Content $file -Raw
            $originalContent = $content
            
            foreach ($key in $replacements.Keys) {
                $content = $content -replace [regex]::Escape($key), $replacements[$key]
            }
            
            if ($content -ne $originalContent) {
                Set-Content $file -Value $content -NoNewline
                Write-Host "  ✓ Updated: $file" -ForegroundColor Green
                $updatedCount++
            }
        }
        catch {
            Write-Host "  ✗ Error updating $file : $_" -ForegroundColor Red
            $errorCount++
        }
    }
}

# Update iOS Bundle ID in Xcode project
Write-Host ""
Write-Host "Updating iOS Bundle ID..." -ForegroundColor Green
$iosProjectFile = "frontend/ios/Runner.xcodeproj/project.pbxproj"
if (Test-Path $iosProjectFile) {
    try {
        $content = Get-Content $iosProjectFile -Raw
        $content = $content -replace "com\.yourdomain\.yourapp", $BundleId
        Set-Content $iosProjectFile -Value $content -NoNewline
        Write-Host "  ✓ Updated iOS Bundle ID" -ForegroundColor Green
    }
    catch {
        Write-Host "  ✗ Error updating iOS project: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Files updated: $updatedCount" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "Errors: $errorCount" -ForegroundColor Red
}
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Review changes: git diff" -ForegroundColor Gray
Write-Host "2. Update App Store Connect API credentials in codemagic.yaml" -ForegroundColor Gray
Write-Host "3. Create app in App Store Connect with Bundle ID: $BundleId" -ForegroundColor Gray
Write-Host "4. Set up Codemagic with your credentials" -ForegroundColor Gray
Write-Host "5. Configure AWS/EC2 deployment" -ForegroundColor Gray
Write-Host "6. Test locally: .\scripts\start-all-local-sqlite.ps1" -ForegroundColor Gray
Write-Host ""

Write-Host "See docs/TEMPLATE_SETUP.md for detailed setup instructions" -ForegroundColor Cyan
