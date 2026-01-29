@echo off
REM Stop All Docker Services (Windows Batch)

echo 🛑 Stopping Docker Services...

cd /d %~dp0\..

docker-compose down

echo.
echo ✅ All services stopped!
echo.
