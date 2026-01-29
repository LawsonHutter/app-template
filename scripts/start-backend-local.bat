@echo off
REM Start Django Backend Locally (Windows Batch)
REM This script sets up and runs the backend using Python virtual environment

echo 🚀 Starting Django Backend Locally...

REM Navigate to backend directory
cd backend

REM Check if virtual environment exists
if not exist "venv" (
    echo 📦 Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
echo 🔧 Activating virtual environment...
call venv\Scripts\activate.bat

REM Check if Django is installed
pip show django >nul 2>&1
if errorlevel 1 (
    echo 📥 Installing dependencies...
    pip install -r requirements.txt
)

REM Start Django development server
echo ✅ Starting Django server on http://localhost:8000
echo    Press Ctrl+C to stop
echo.

python manage.py runserver
