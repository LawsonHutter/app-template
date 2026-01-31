# Update codemagic.yaml from deployment.config
# Syncs APP_ID, API_BASE_URL, and email so you configure once

$projectRoot = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $projectRoot "security\deployment.config"
$codemagicPath = Join-Path $projectRoot "codemagic.yaml"

if (-not (Test-Path $configPath)) {
    Write-Host "ERROR: security\deployment.config not found" -ForegroundColor Red
    Write-Host "Copy from security\deployment.config.example and fill in values" -ForegroundColor Yellow
    exit 1
}

$config = @{}
Get-Content $configPath | ForEach-Object {
    if ($_ -match '^([^#=]+)=(.*)$') {
        $config[$matches[1].Trim()] = $matches[2].Trim()
    }
}

$domain = $config["DOMAIN"]
$useHttps = $config["USE_HTTPS"] -eq "true"
$appId = $config["APP_ID"]
$email = $config["CODEMAGIC_EMAIL"]

if ([string]::IsNullOrWhiteSpace($appId)) {
    Write-Host "ERROR: APP_ID not set in deployment.config" -ForegroundColor Red
    exit 1
}

# Build API URL
$protocol = if ($useHttps) { "https" } else { "http" }
$apiUrl = if ($domain) { "$protocol`://$domain/api/counter/" } else { "https://yourdomain.com/api/counter/" }

if ([string]::IsNullOrWhiteSpace($email)) { $email = "your@email.com" }

$content = Get-Content $codemagicPath -Raw

$content = $content -replace 'API_BASE_URL: "[^"]*"', "API_BASE_URL: `"$apiUrl`""
$content = $content -replace 'APP_ID: "[^"]*"', "APP_ID: `"$appId`""
$content = $content -replace 'CODEMAGIC_EMAIL: "[^"]*"', "CODEMAGIC_EMAIL: `"$email`""
$content = $content -replace 'bundle_identifier: [^\r\n]+', "bundle_identifier: $appId"

Set-Content -Path $codemagicPath -Value $content -NoNewline

# Sync bundle ID to iOS project
$pbxPath = Join-Path $projectRoot "frontend\ios\Runner.xcodeproj\project.pbxproj"
if (Test-Path $pbxPath) {
    $pbx = Get-Content $pbxPath -Raw
    $m = [regex]::Match($pbx, 'PRODUCT_BUNDLE_IDENTIFIER = (com\.[^;]+);')
    if ($m.Success) {
        $oldBase = $m.Groups[1].Value -replace '\.RunnerTests$', ''
        $pbx = $pbx.Replace($oldBase, $appId)
        Set-Content -Path $pbxPath -Value $pbx -NoNewline
    }
}

Write-Host "Synced from security/deployment.config:" -ForegroundColor Green
Write-Host "  API_BASE_URL: $apiUrl"
Write-Host "  APP_ID (bundle_identifier): $appId"
Write-Host "  Email: $email"
Write-Host "  iOS project.pbxproj: updated"
