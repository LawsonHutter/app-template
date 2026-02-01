# Rename Project (run after cloning the template)
# Rapidly replace app name, domain, and bundle ID across the repo

param(
    [Parameter(Mandatory=$true)]
    [string]$AppName,
    
    [Parameter(Mandatory=$true)]
    [string]$Domain,
    
    [Parameter(Mandatory=$true)]
    [string]$BundleId,
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectName = ""
)

# If ProjectName not set, derive from domain (e.g. myapp.net -> myapp)
if (-not $ProjectName) {
    $ProjectName = $Domain -replace "\.(net|com|io|app)$", ""
}

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Rename Project" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "New values:" -ForegroundColor Yellow
Write-Host "  App Name (display): $AppName" -ForegroundColor Gray
Write-Host "  Domain:            $Domain" -ForegroundColor Gray
Write-Host "  Bundle ID:         $BundleId" -ForegroundColor Gray
Write-Host "  Project name:      $ProjectName (used in paths/scripts)" -ForegroundColor Gray
Write-Host ""
$confirm = Read-Host "Replace across repo? (y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Cancelled." -ForegroundColor Red
    exit 0
}

# Replacement map: search string -> replacement
$baseUrl = "https://$Domain/api/counter/"
$replacements = @(
    @{ Old = "Counter App"; New = $AppName },
    @{ Old = "your-app-name.net"; New = $Domain },
    @{ Old = "your-app-name"; New = $ProjectName },
    @{ Old = "https://yourdomain.com/api/counter/"; New = $baseUrl },
    @{ Old = "com.your-app-name.counterapp"; New = $BundleId },
    @{ Old = "com.yourdomain.yourapp"; New = $BundleId }
)

# Files to update (relative to project root)
$files = @(
    "readme.md",
    "SETUP_GUIDE.md",
    "frontend/lib/main.dart",
    "frontend/lib/counter_screen.dart",
    "frontend/ios/Runner/Info.plist",
    "codemagic.yaml"
)

$updated = 0
foreach ($path in $files) {
    if (-not (Test-Path $path)) { continue }
    try {
        $content = Get-Content $path -Raw -ErrorAction Stop
        $orig = $content
        foreach ($r in $replacements) {
            $content = $content -replace [regex]::Escape($r.Old), $r.New
        }
        if ($content -ne $orig) {
            Set-Content $path -Value $content -NoNewline
            Write-Host "  Updated: $path" -ForegroundColor Green
            $updated++
        }
    } catch {
        Write-Host "  Error: $path - $_" -ForegroundColor Red
    }
}

# iOS Bundle ID (Xcode project)
$pbx = "frontend/ios/Runner.xcodeproj/project.pbxproj"
if (Test-Path $pbx) {
    try {
        $c = Get-Content $pbx -Raw
        $c = $c -replace "com\.yourdomain\.yourapp", $BundleId
        $c = $c -replace "com\.your-app-name\.counterapp", $BundleId
        $c = $c -replace "com\.your-app-name\.\w+", $BundleId
        Set-Content $pbx -Value $c -NoNewline
        Write-Host "  Updated: $pbx" -ForegroundColor Green
        $updated++
    } catch {
        Write-Host "  Error updating iOS project: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Done. Files updated: $updated" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next:" -ForegroundColor Yellow
Write-Host "  1. Review: git diff" -ForegroundColor Gray
Write-Host "  2. Set Codemagic APP_ID / API_BASE_URL if needed" -ForegroundColor Gray
Write-Host "  3. In App Store Connect, create app with Bundle ID: $BundleId" -ForegroundColor Gray
Write-Host "  4. EC2: scripts use 'app' as remote dir; rename to '~/app' or change scripts to '~/$ProjectName'" -ForegroundColor Gray
Write-Host ""
