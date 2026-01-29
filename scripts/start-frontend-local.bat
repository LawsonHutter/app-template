@echo off
REM Start Flutter Frontend Locally (Windows Batch)
REM This script runs the Flutter web app in development mode

echo 🚀 Starting Flutter Frontend Locally...

REM Navigate to frontend directory
cd frontend

REM Install dependencies if needed
if not exist "pubspec.lock" (
    echo 📥 Installing Flutter dependencies...
    flutter pub get
)

echo ✅ Starting Flutter web app...
echo    Frontend will connect to backend at http://localhost:8000
echo    Press Ctrl+C to stop
echo.

REM Run Flutter web app
flutter run -d chrome --web-port 8080
