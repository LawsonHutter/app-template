# Generate Django Secret Key (Simple Method - No Django Required)
# This generates a random secret key compatible with Django

Write-Host "Generating Django SECRET_KEY..." -ForegroundColor Cyan
Write-Host ""

# Generate a random 50-character string (Django secret key format)
$chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*(-_=+)"
$secretKey = ""
for ($i = 0; $i -lt 50; $i++) {
    $secretKey += $chars[(Get-Random -Maximum $chars.Length)]
}

Write-Host $secretKey -ForegroundColor Green
Write-Host ""
Write-Host "Copy this key and add it to your .env file on EC2 as SECRET_KEY" -ForegroundColor Yellow
Write-Host ""
