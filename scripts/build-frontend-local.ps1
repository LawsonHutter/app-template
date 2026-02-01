# Build Flutter Frontend Locally
# Builds the Flutter web app on your local machine (faster than building on EC2)
# The built files can then be deployed without needing Flutter on EC2

param(
    [Parameter(Mandatory=$false)]
    [string]$ApiUrl = ""
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Build Frontend Locally" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get project root
$projectRoot = Split-Path -Parent $PSScriptRoot
$frontendPath = Join-Path $projectRoot "frontend"

# Load config for API URL if not provided
if ([string]::IsNullOrWhiteSpace($ApiUrl)) {
    $configPath = Join-Path $projectRoot "security\deployment.config"
    if (Test-Path $configPath) {
        $config = @{}
        Get-Content $configPath | ForEach-Object {
            if ($_ -match '^([^#=]+)=(.*)$') {
                $config[$matches[1].Trim()] = $matches[2].Trim()
            }
        }
        
        # API URL: API_BASE_URL first, else build from domain/IP
        if (-not [string]::IsNullOrWhiteSpace($config["API_BASE_URL"])) {
            $ApiUrl = $config["API_BASE_URL"]
        } else {
            $useHttps = $config["USE_HTTPS"] -eq "true"
            $protocol = if ($useHttps) { "https" } else { "http" }
            if (-not [string]::IsNullOrWhiteSpace($config["DOMAIN"])) {
                $ApiUrl = $protocol + "://" + $config["DOMAIN"] + "/api/counter/"
            } elseif (-not [string]::IsNullOrWhiteSpace($config["EC2_ELASTIC_IP"])) {
                $ApiUrl = "http://" + $config["EC2_ELASTIC_IP"] + "/api/counter/"
            } elseif (-not [string]::IsNullOrWhiteSpace($config["EC2_IP"])) {
                $ApiUrl = "http://" + $config["EC2_IP"] + "/api/counter/"
            } elseif (-not [string]::IsNullOrWhiteSpace($config["LOCAL_WEB_API_URL"])) {
                $ApiUrl = $config["LOCAL_WEB_API_URL"]
            }
        }
    }
}

# Default API URL if still not set
if ([string]::IsNullOrWhiteSpace($ApiUrl)) {
    $ApiUrl = "/api/counter/"
    Write-Host "Using relative API URL: $ApiUrl" -ForegroundColor Yellow
} else {
    Write-Host "API URL: $ApiUrl" -ForegroundColor Green
}

Write-Host ""

# Check Flutter is installed
Write-Host "Checking Flutter installation..." -ForegroundColor Cyan
$flutterVersion = & flutter --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flutter not installed or not in PATH" -ForegroundColor Red
    Write-Host "Install Flutter: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}
Write-Host "Flutter found" -ForegroundColor Green
Write-Host ""

# Navigate to frontend
Set-Location $frontendPath

# Get dependencies
Write-Host "Getting Flutter dependencies..." -ForegroundColor Cyan
& flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to get dependencies" -ForegroundColor Red
    exit 1
}
Write-Host "Dependencies installed" -ForegroundColor Green
Write-Host ""

# Build web
Write-Host "Building Flutter web app..." -ForegroundColor Cyan
Write-Host "  (This may take 2-5 minutes)" -ForegroundColor Gray
& flutter build web --release --dart-define="API_BASE_URL=$ApiUrl"

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Build failed" -ForegroundColor Red
    exit 1
}

$buildPath = Join-Path $frontendPath "build\web"
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Build Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Built files: $buildPath" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Commit the build: git add frontend/build && git commit -m 'Build frontend'" -ForegroundColor Gray
Write-Host "  2. Push to GitHub: git push origin main" -ForegroundColor Gray
Write-Host "  3. Deploy: .\scripts\auto-deploy-ec2.ps1" -ForegroundColor Gray
Write-Host ""

Set-Location $projectRoot
