# Build Flutter iOS App for TestFlight
# Requires macOS with Xcode installed

param(
    [Parameter(Mandatory=$false)]
    [string]$ApiUrl = "https://dipoll.net/api/counter/",
    
    [Parameter(Mandatory=$false)]
    [string]$BuildNumber = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$OpenXcode = $false
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Build Flutter iOS App" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running on macOS
if ($PSVersionTable.Platform -ne "Unix" -or $PSVersionTable.OS -notmatch "Darwin") {
    Write-Host "ERROR: iOS builds require macOS with Xcode installed" -ForegroundColor Red
    Write-Host "This script must be run on a Mac" -ForegroundColor Yellow
    exit 1
}

# Get project root
$projectRoot = Split-Path -Parent $PSScriptRoot
$frontendPath = Join-Path $projectRoot "frontend"

# Navigate to frontend
Push-Location $frontendPath

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "Flutter: $flutterVersion" -ForegroundColor Gray
} catch {
    Write-Host "ERROR: Flutter not found. Please install Flutter SDK." -ForegroundColor Red
    Pop-Location
    exit 1
}

# Check if iOS toolchain is available
Write-Host "Checking iOS toolchain..." -ForegroundColor Gray
$iosCheck = flutter doctor 2>&1 | Select-String -Pattern "iOS toolchain"
if (-not $iosCheck) {
    Write-Host "WARNING: iOS toolchain may not be configured" -ForegroundColor Yellow
    Write-Host "Run 'flutter doctor' to check setup" -ForegroundColor Yellow
}

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Gray
flutter pub get | Out-Null

# Build iOS app
Write-Host "Building iOS app..." -ForegroundColor Yellow
Write-Host "  API URL: $ApiUrl" -ForegroundColor Gray
if ($BuildNumber) {
    Write-Host "  Build Number: $BuildNumber" -ForegroundColor Gray
}
Write-Host ""

# Build command
$buildCmd = "flutter build ios --release --dart-define=API_BASE_URL=$ApiUrl"
if ($BuildNumber) {
    $buildCmd += " --build-number=$BuildNumber"
}

$buildResult = Invoke-Expression $buildCmd 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: iOS build failed!" -ForegroundColor Red
    Write-Host $buildResult -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "✓ Build successful!" -ForegroundColor Green
Write-Host ""

# Check if build output exists
$buildPath = Join-Path $frontendPath "build\ios\iphoneos"
if (-not (Test-Path $buildPath)) {
    Write-Host "WARNING: Build output not found at: $buildPath" -ForegroundColor Yellow
}

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Open Xcode: open ios/Runner.xcworkspace" -ForegroundColor Gray
Write-Host "  2. Select 'Any iOS Device' (not simulator)" -ForegroundColor Gray
Write-Host "  3. Product > Archive" -ForegroundColor Gray
Write-Host "  4. Distribute App > App Store Connect" -ForegroundColor Gray
Write-Host ""

if ($OpenXcode) {
    Write-Host "Opening Xcode..." -ForegroundColor Gray
    open ios/Runner.xcworkspace
}

Pop-Location
