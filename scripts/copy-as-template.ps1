# Copy this project as a template to a new folder and prepare for a new repo
# Usage: .\scripts\copy-as-template.ps1 -RepoUrl "https://github.com/LawsonHutter/dipoll-app.git" [-TargetDir "C:\path\to\parent"]
# If TargetDir omitted, creates sibling folder next to app-template

param(
    [Parameter(Mandatory=$true)]
    [string]$RepoUrl,
    [Parameter(Mandatory=$false)]
    [string]$TargetDir = ""
)

$projectRoot = Split-Path -Parent $PSScriptRoot
$repoName = if ($RepoUrl -match '/([^/]+?)\.git$') { $matches[1] } else { "new-project" }

if ([string]::IsNullOrWhiteSpace($TargetDir)) {
    $parentDir = Split-Path -Parent $projectRoot
    $TargetDir = Join-Path $parentDir $repoName
}

if (Test-Path $TargetDir) {
    Write-Host "ERROR: Target folder already exists: $TargetDir" -ForegroundColor Red
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Copy Project as Template" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Source:  $projectRoot" -ForegroundColor Gray
Write-Host "Target:  $TargetDir" -ForegroundColor Gray
Write-Host "Repo:    $RepoUrl" -ForegroundColor Gray
Write-Host ""

Write-Host "Copying files (excluding .git, venv, build, etc.)..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null

$robocopyResult = robocopy $projectRoot $TargetDir /E /XD .git node_modules __pycache__ .dart_tool venv .venv backend\venv backend\staticfiles /XF deployment.config db.sqlite3 /NFL /NDL /NJH /NJS /NC /NS
# Robocopy: 0-7 = OK, 8+ = error
if ($LASTEXITCODE -ge 8) { Write-Host "Copy failed" -ForegroundColor Red; exit 1 }

# Create fresh deployment.config from example
$configExample = Join-Path $TargetDir "security\deployment.config.example"
$configPath = Join-Path $TargetDir "security\deployment.config"
if (Test-Path $configExample) {
    Copy-Item $configExample $configPath -Force
    Write-Host "Created security/deployment.config from example" -ForegroundColor Green
}

# Initialize git
Write-Host ""
Write-Host "Initializing git..." -ForegroundColor Yellow
Push-Location $TargetDir
try {
    git init
    git add .
    git commit -m "Initial commit from template"
    git branch -M main
    git remote add origin $RepoUrl
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Done!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Create the repo on GitHub: https://github.com/new" -ForegroundColor Gray
    Write-Host "     Name: $repoName" -ForegroundColor Gray
    Write-Host "     (Do NOT add README, .gitignore, or license - we have them)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. Push:" -ForegroundColor Gray
    Write-Host "     cd `"$TargetDir`"" -ForegroundColor Gray
    Write-Host "     git push -u origin main" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  3. Configure:" -ForegroundColor Gray
    Write-Host "     Edit security/deployment.config with your values" -ForegroundColor Gray
    Write-Host "     .\scripts\rename-project.ps1 -AppName `"Dipoll`" -Domain `"dipoll.net`" -BundleId `"com.yourdomain.dipoll`"" -ForegroundColor Gray
    Write-Host "     .\scripts\update-codemagic-config.ps1" -ForegroundColor Gray
    Write-Host ""
} finally {
    Pop-Location
}
