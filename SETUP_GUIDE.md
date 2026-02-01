# Setup Guide

Step-by-step guide to set up and deploy this Flutter/Django app.

---

## 1. Initialize Project

```powershell
.\scripts\init-project.ps1
```

- Creates Python virtual environment
- Installs Django dependencies
- Runs database migrations
- Installs Flutter dependencies

---

## 2. App Icon (Optional)

Add your app logo at `frontend/assets/app_icon.png` (1024x1024 px), then run:

```powershell
cd frontend
dart run flutter_launcher_icons
```

This generates iOS, Android, and web icons. See `frontend/assets/APP_ICON_README.md`.

---

## 3. Rename Project (Optional)

If you cloned this as a template:

```powershell
.\scripts\rename-project.ps1 -AppName "My New App" -Domain "my-new-app.net" -BundleId "com.mydomain.mynewapp"
```

---

## 4. Run Locally (Web)

**Option A – venv + Flutter** (fast iteration):

```powershell
.\scripts\start-local-web.ps1
```

Launches backend and frontend in separate windows. Uses `LOCAL_WEB_API_URL` from `security/deployment.config`.

**Option B – Docker** (matches production stack):

```powershell
.\scripts\start-docker-local.ps1
```

Full stack in Docker: backend, PostgreSQL, frontend. Stop with `docker compose -f docker-compose.yml -f docker-compose.local.yml down`.

---

## 5. Run Locally (Emulator + Docker Backend)

Backend in Docker (PostgreSQL), Flutter on emulator:

```powershell
# Android (uses 10.0.2.2 to reach host)
.\scripts\start-emulator-docker-backend.ps1 -Platform android

# iOS simulator (uses localhost)
.\scripts\start-emulator-docker-backend.ps1 -Platform ios

# Physical device? Use -Release to avoid "debug mode" error on iOS 14+
.\scripts\start-emulator-docker-backend.ps1 -Platform ios -Release
```

Uses `LOCAL_EMULATOR_API_URL` (Android) and `LOCAL_WEB_API_URL` (iOS) from `security/deployment.config`.

**First time?** Run `flutter doctor --android-licenses` and accept all.

**"Debug mode flutter apps can only be launched from flutter tooling"** – Use `-Release` when running on a physical iOS device.

---

## 6. Setup AWS EC2

1. Follow **`docs/EC2_LAUNCH_SETTINGS.md`**
2. Copy config:
   ```powershell
   Copy-Item security\deployment.config.example security\deployment.config
   ```
3. Fill out `security/deployment.config`
4. Run:
   ```powershell
   .\scripts\setup-ec2.ps1
   ```

---

## 7. Domain Setup (Squarespace)

Follow **`docs/SQUARESPACE_DOMAIN_SETUP.md`**

Push to git so EC2 can pull the latest:

```powershell
git push origin main
```

---

## 8. Build & Deploy to EC2

1. Build frontend:
   ```powershell
   .\scripts\build-frontend-local.ps1
   ```
2. Commit and push
3. Deploy:
   ```powershell
   .\scripts\auto-deploy-ec2.ps1
   ```

Your site will be up at HTTP (HTTPS requires SSL setup below).

---

## 9. Setup SSL (HTTPS)

```powershell
.\scripts\setup-ssl.ps1
```

---

## 10. Connect to EC2

```powershell
.\scripts\connect-ec2.ps1
```

---

## 11. Setup Codemagic (iOS / TestFlight)

1. Follow **`docs/CODEMAGIC_TESTFLIGHT_SETUP.md`**
2. Update `security/deployment.config` with your values
3. Run:
   ```powershell
   .\scripts\update-codemagic-config.ps1
   ```

---

## 12. Deploy to TestFlight

Ensure code signing and App Store Connect are enabled in Codemagic.

Push to `main` to trigger builds.

---

## 13. Google Play Setup

Follow **`docs/GOOGLE_PLAY_SETUP.md`**

---

## 14. Git Commands

```powershell
git add .
git commit -m "Your commit message here"
git push
```

---
