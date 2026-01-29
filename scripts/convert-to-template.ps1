# Convert Project to Template
# This script converts the current project into a reusable template
# by replacing project-specific values with placeholders

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Converting Project to Template" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration - Update these if needed
$PROJECT_NAME = "survey-web-app"
$TEMPLATE_NAME = "flutter-django-template"
$DOMAIN_PLACEHOLDER = "yourdomain.com"
$BUNDLE_ID_PLACEHOLDER = "com.yourdomain.yourapp"
$APP_NAME_PLACEHOLDER = "Your App Name"

Write-Host "This will replace project-specific values with placeholders:" -ForegroundColor Yellow
Write-Host "  - Domain: dipoll.net -> $DOMAIN_PLACEHOLDER" -ForegroundColor Gray
Write-Host "  - Bundle ID: com.dipoll.surveyapp -> $BUNDLE_ID_PLACEHOLDER" -ForegroundColor Gray
Write-Host "  - App Name: Survey App -> $APP_NAME_PLACEHOLDER" -ForegroundColor Gray
Write-Host ""

$confirm = Read-Host "Continue? (y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Cancelled." -ForegroundColor Red
    exit 0
}

Write-Host ""
Write-Host "Converting files..." -ForegroundColor Green

# Files to update (relative to project root)
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

# Replacements
$replacements = @{
    "dipoll.net" = $DOMAIN_PLACEHOLDER
    "com.dipoll.surveyapp" = $BUNDLE_ID_PLACEHOLDER
    "dipoll" = "your-app-name"
    "Survey App" = $APP_NAME_PLACEHOLDER
    "S67R9DU7BU" = "YOUR_KEY_ID"
    "187efa47-e5eb-4d34-8a00-e50fc4825b69" = "YOUR_ISSUER_ID"
    "SMLSUDFRH5" = "YOUR_TEAM_ID"
}

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
                Write-Host "  Updated: $file" -ForegroundColor Green
                $updatedCount++
            }
        }
        catch {
            Write-Host "  Error updating $file : $_" -ForegroundColor Red
            $errorCount++
        }
    }
    else {
        Write-Host "  Skipped (not found): $file" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Conversion Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Files updated: $updatedCount" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "Errors: $errorCount" -ForegroundColor Red
}
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Review changes: git diff" -ForegroundColor Gray
Write-Host "2. Update .gitignore if needed" -ForegroundColor Gray
Write-Host "3. Remove sensitive files" -ForegroundColor Gray
Write-Host "4. Create template repository on GitHub" -ForegroundColor Gray
Write-Host "5. Push to template repo" -ForegroundColor Gray
Write-Host ""

$templateMsg = "To create a new project from this template:"
Write-Host $templateMsg -ForegroundColor Yellow
Write-Host "  See docs/TEMPLATE_SETUP.md" -ForegroundColor Gray
