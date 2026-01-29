# View SQLite Database Contents (Windows PowerShell)
# This script shows the current counter value from the database file

Write-Host "Viewing SQLite Database..." -ForegroundColor Cyan
Write-Host ""

# Navigate to backend directory
$backendDir = Join-Path (Split-Path -Parent $PSScriptRoot) "backend"
Set-Location $backendDir

# Check if database file exists
if (-not (Test-Path "db.sqlite3")) {
    Write-Host "ERROR: db.sqlite3 file not found!" -ForegroundColor Red
    Write-Host "Run migrations first: python manage.py migrate" -ForegroundColor Yellow
    exit 1
}

# Check if SQLite command line tool is available
$sqlitePath = Get-Command sqlite3 -ErrorAction SilentlyContinue

if ($sqlitePath) {
    Write-Host "Counter table contents:" -ForegroundColor Green
    sqlite3 db.sqlite3 "SELECT * FROM click_counter_clickcounter;"
    Write-Host ""
    Write-Host "Database file location: $backendDir\db.sqlite3" -ForegroundColor Gray
} else {
    # Use Python to read the database
    Write-Host "Using Python to read database..." -ForegroundColor Yellow
    Write-Host ""
    
    # Create a simple Python script to read the database
    $pythonScript = @"
import sqlite3
import os

db_path = 'db.sqlite3'
if os.path.exists(db_path):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Get counter data
    cursor.execute('SELECT * FROM click_counter_clickcounter;')
    rows = cursor.fetchall()
    
    if rows:
        print('Counter table contents:')
        for row in rows:
            print(f'  ID: {row[0]}, Count: {row[1]}, Updated: {row[2]}, Created: {row[3]}')
    else:
        print('No counter data found.')
    
    conn.close()
else:
    print(f'Database file {db_path} not found!')
"@
    
    $pythonScript | python
    Write-Host ""
    Write-Host "Database file location: $backendDir\db.sqlite3" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Tip: Watch this file size change as you click the button!" -ForegroundColor Yellow
