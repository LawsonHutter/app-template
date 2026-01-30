# Start Counter App on Android Emulator (Single Script)
# Starts backend, launches Flutter emulator if needed, runs the app

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Counter App - Android Emulator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = Split-Path -Parent $PSScriptRoot
$frontendPath = Join-Path $projectRoot "frontend"

# ---- 1. Start backend in a new window ----
Write-Host "Starting backend (Django)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot'; .\scripts\start-backend-local.ps1"

Write-Host "Waiting for backend to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
Write-Host ""

# ---- 2. Check Flutter ----
Push-Location $frontendPath

try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "Flutter: $flutterVersion" -ForegroundColor Gray
} catch {
    Write-Host "ERROR: Flutter not found. Please install Flutter SDK." -ForegroundColor Red
    Pop-Location
    exit 1
}

# ---- 3. Get available emulator ID ----
Write-Host "Checking for Android emulator..." -ForegroundColor Yellow
$emulatorOutput = flutter emulators 2>&1 | Out-String

if ($emulatorOutput -notmatch "available emulator") {
    Write-Host "ERROR: No Android emulator found." -ForegroundColor Red
    Write-Host "Create one with: flutter emulators --create --name Flutter_Emulator" -ForegroundColor Yellow
    Write-Host "Or in Android Studio: Tools > Device Manager > Create Device" -ForegroundColor Yellow
    Pop-Location
    exit 1
}

# Parse emulator ID: first word of the line containing "android" (not "Platform")
$emulatorId = $null
foreach ($line in ($emulatorOutput -split "`n")) {
    $trimmed = $line.Trim()
    if ($trimmed -match "android" -and $trimmed -notmatch "Platform") {
        $emulatorId = ($trimmed -split '\s+')[0]
        break
    }
}
if (-not $emulatorId) {
    $emulatorId = "Flutter_Emulator"  # fallback
}

Write-Host "Emulator: $emulatorId" -ForegroundColor Gray

# ---- 4. Launch emulator if not already running ----
# Check for Android device (emulator or physical) - "android" in platform column
$devicesOutput = flutter devices 2>&1 | Out-String
$androidDeviceRunning = $devicesOutput -match "android-arm|android-x64|emulator-\d+"
if (-not $androidDeviceRunning) {
    Write-Host "No emulator running. Launching $emulatorId..." -ForegroundColor Yellow
    Start-Process -FilePath "flutter" -ArgumentList "emulators", "--launch", $emulatorId -NoNewWindow -Wait:$false
    
    Write-Host "Waiting for emulator to start (this may take a minute)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15
    
    $maxWait = 60
    $waited = 0
    while ($waited -lt $maxWait) {
        $check = flutter devices 2>&1 | Out-String
        if ($check -match "android-arm|android-x64|emulator-\d+") {
            Write-Host "Emulator is ready!" -ForegroundColor Green
            break
        }
        Write-Host "  Waiting... ($waited/$maxWait s)" -ForegroundColor Gray
        Start-Sleep -Seconds 5
        $waited += 5
    }
    if ($waited -ge $maxWait) {
        Write-Host "WARNING: Emulator may not be ready. Continuing anyway..." -ForegroundColor Yellow
    }
} else {
    Write-Host "Android device/emulator is already running." -ForegroundColor Green
}

# Give the emulator a moment to fully register with Flutter
Start-Sleep -Seconds 3

Write-Host ""

# ---- 5. Install deps if needed ----
if (-not (Test-Path ".dart_tool")) { flutter pub get | Out-Null }
if (-not (Test-Path "pubspec.lock")) { flutter pub get | Out-Null }

# ---- 6. Get Android device ID for flutter run ----
# Emulator can take a few seconds to appear in "flutter devices"; retry a few times
$androidDeviceId = $null
$getDeviceId = {
    $out = flutter devices 2>&1 | Out-String
    $id = $null
    if ($out -match "(emulator-\d+)") { $id = $Matches[1] }
    if (-not $id -and $out -match "emulator-(\d+)") { $id = "emulator-" + $Matches[1] }
    if (-not $id) {
        foreach ($line in ($out -split "`n")) {
            if ($line -match "android-arm|android-x64" -and $line -match "(emulator-\d+)") {
                $id = $Matches[1]
                break
            }
        }
    }
    return $id
}

foreach ($attempt in 1..5) {
    $androidDeviceId = & $getDeviceId
    if ($androidDeviceId) { break }
    Write-Host "Waiting for Android device to appear in Flutter... ($attempt/5)" -ForegroundColor Yellow
    Start-Sleep -Seconds 5
}

if (-not $androidDeviceId) {
    Write-Host "ERROR: No Android device found. Start the emulator and run again." -ForegroundColor Red
    Write-Host "  flutter emulators --launch $emulatorId" -ForegroundColor Gray
    Write-Host "Then run: .\scripts\start-android.ps1" -ForegroundColor Gray
    Pop-Location
    exit 1
}

# ---- 7. Run app on Android ----
$androidApiUrl = "http://10.0.2.2:8000/api/counter/"
Write-Host "Starting app on Android ($androidDeviceId)..." -ForegroundColor Green
Write-Host "  Backend: http://localhost:8000" -ForegroundColor Gray
Write-Host "  App API: $androidApiUrl" -ForegroundColor Gray
Write-Host "  Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

flutter run -d $androidDeviceId --dart-define=API_BASE_URL=$androidApiUrl

Pop-Location
