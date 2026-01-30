# Build Flutter Frontend Locally and Deploy to EC2
# Builds Flutter on your local machine (fast) and deploys pre-built files to EC2,
# then builds a tiny nginx image on EC2 (no Flutter compilation on the server).

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$EC2IP = 'YOUR_EC2_IP_ADDRESS',

    [Parameter(Mandatory = $false)]
    [string]$KeyPath = 'security\app-key.pem',

    [Parameter(Mandatory = $false)]
    [string]$ApiUrl = 'http://your-app-name.net/api/counter/'
)

Write-Host '========================================' -ForegroundColor Cyan
Write-Host '  Build & Deploy Frontend to EC2' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''

$projectRoot = Split-Path -Parent $PSScriptRoot
$frontendPath = Join-Path $projectRoot 'frontend'
$buildWebPath = Join-Path $frontendPath 'build\web'
$dockerfileSimplePath = Join-Path $frontendPath 'Dockerfile.simple'
$dockerignorePath = Join-Path $frontendPath '.dockerignore'

$absoluteKeyPath = Join-Path $projectRoot $KeyPath
if (-not (Test-Path $absoluteKeyPath)) {
    Write-Host ('ERROR: SSH key not found at: ' + $absoluteKeyPath) -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $dockerfileSimplePath)) {
    Write-Host ('ERROR: Missing ' + $dockerfileSimplePath) -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $dockerignorePath)) {
    Write-Host ('ERROR: Missing ' + $dockerignorePath) -ForegroundColor Red
    exit 1
}

Write-Host 'Step 1: Build Flutter locally...' -ForegroundColor Yellow
Write-Host ''

Push-Location $frontendPath
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host ('Flutter: ' + $flutterVersion) -ForegroundColor Gray
} catch {
    Write-Host 'ERROR: Flutter not found. Install Flutter SDK and re-run.' -ForegroundColor Red
    Pop-Location
    exit 1
}

flutter pub get | Out-Null
flutter build web --release ("--dart-define=API_BASE_URL=$ApiUrl")
if ($LASTEXITCODE -ne 0) {
    Write-Host 'ERROR: flutter build web failed.' -ForegroundColor Red
    Pop-Location
    exit 1
}
Pop-Location

if (-not (Test-Path $buildWebPath)) {
    Write-Host ('ERROR: Build output not found at: ' + $buildWebPath) -ForegroundColor Red
    exit 1
}

Write-Host 'Step 2: Copy build/web to EC2...' -ForegroundColor Yellow
Write-Host ''

$tempDir = '/tmp/frontend-build-' + (Get-Date -Format 'yyyyMMdd-HHmmss')

ssh -i $absoluteKeyPath ('ubuntu@' + $EC2IP) ('mkdir -p ' + $tempDir + '/web') | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host 'ERROR: Failed to create temp directory on EC2.' -ForegroundColor Red
    exit 1
}

# Copy local build/web directory to EC2 tempDir/web
scp -i $absoluteKeyPath -r $buildWebPath ('ubuntu@' + $EC2IP + ':' + $tempDir + '/web') | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host 'ERROR: Failed to copy build/web to EC2.' -ForegroundColor Red
    exit 1
}

# Copy Dockerfile.simple to EC2 so the server can build the nginx image
scp -i $absoluteKeyPath $dockerfileSimplePath ('ubuntu@' + $EC2IP + ':~/app/frontend/Dockerfile.simple') | Out-Null
scp -i $absoluteKeyPath $dockerignorePath ('ubuntu@' + $EC2IP + ':~/app/frontend/.dockerignore') | Out-Null

Write-Host 'Step 3: Build nginx image on EC2 (no Flutter build) and restart frontend...' -ForegroundColor Yellow
Write-Host ''

$remoteScript = @'
set -euo pipefail

cd ~/app

echo 'Stopping frontend...'
docker compose -f docker-compose.yml -f docker-compose.prod.yml stop frontend || true
docker compose -f docker-compose.yml -f docker-compose.prod.yml rm -f frontend || true

echo 'Installing pre-built web files...'
rm -rf frontend/build/web
mkdir -p frontend/build/web
SRC_DIR="TEMP_DIR/web"
if [ -d "TEMP_DIR/web/web" ]; then
  SRC_DIR="TEMP_DIR/web/web"
fi
cp -r "$SRC_DIR"/* frontend/build/web/

echo 'Sanity check (first few files):'
ls -la frontend/build/web | head -20

echo 'Building frontend image (nginx only, no Flutter compilation)...'
DOCKER_BUILDKIT=0 docker build -f frontend/Dockerfile.simple -t app-frontend:latest frontend/

echo 'Starting frontend (no-build)...'
COMPOSE_COMPATIBILITY=1 docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --no-build frontend

echo 'Cleanup temp dir'
rm -rf TEMP_DIR

echo 'Frontend updated!'
'@

$remoteScript = $remoteScript.Replace('TEMP_DIR', $tempDir)

# Write the remote script to a temporary local file, then SCP it to EC2 and run it.
$localTmpScript = Join-Path $env:TEMP ('deploy-frontend-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.sh')
$remoteScriptLf = $remoteScript.Replace("`r`n", "`n").Replace("`r", "`n")
[System.IO.File]::WriteAllText($localTmpScript, $remoteScriptLf, [System.Text.Encoding]::ASCII)

$remoteTmpScript = '/tmp/deploy-frontend.sh'

scp -i $absoluteKeyPath $localTmpScript ('ubuntu@' + $EC2IP + ':' + $remoteTmpScript) | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host 'ERROR: Failed to copy deploy script to EC2.' -ForegroundColor Red
    exit 1
}

ssh -i $absoluteKeyPath ('ubuntu@' + $EC2IP) ('bash ' + $remoteTmpScript)
$sshExit = $LASTEXITCODE

Remove-Item -Force $localTmpScript -ErrorAction SilentlyContinue

if ($sshExit -ne 0) {
    Write-Host ''
    Write-Host 'ERROR: Deployment failed on EC2 (see output above).' -ForegroundColor Red
    exit 1
}

Write-Host ''
Write-Host '========================================' -ForegroundColor Cyan
Write-Host '  Deployment Complete!' -ForegroundColor Green
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''
Write-Host 'Now check: https://your-app-name.net' -ForegroundColor Gray
