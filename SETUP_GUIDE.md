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

## 2. Rename Project (Optional)

If you cloned this as a template:

```powershell
.\scripts\rename-project.ps1 -AppName "My New App" -Domain "my-new-app.net" -BundleId "com.mydomain.mynewapp"
```

---

## 3. Run Locally (Web)

```powershell
.\scripts\start-local-web.ps1
```

Launches backend and frontend in separate windows.

**Manual:** Launch backend and frontend separately if preferred.

---

## 4. Run Locally (Android Emulator)

If not working, run:

```powershell
flutter doctor --android-licenses
```

Accept all licenses.

---

## 5. Setup AWS EC2

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

## 6. Domain Setup (Squarespace)

Follow **`docs/SQUARESPACE_DOMAIN_SETUP.md`**

Push to git so EC2 can pull the latest:

```powershell
git push origin main
```

---

## 7. Build & Deploy to EC2

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

## 8. Setup SSL (HTTPS)

```powershell
.\scripts\setup-ssl.ps1
```

---

## 9. Connect to EC2

```powershell
.\scripts\connect-ec2.ps1
```

---

## 10. Setup Codemagic (iOS / TestFlight)

1. Follow **`docs/CODEMAGIC_TESTFLIGHT_SETUP.md`**
2. Update `security/deployment.config` with your values
3. Run:
   ```powershell
   .\scripts\update-codemagic-config.ps1
   ```

---

## 11. Deploy to TestFlight

Ensure code signing and App Store Connect are enabled in Codemagic.

Push to `main` to trigger builds.

---

## 12. Google Play Setup

Follow **`docs/GOOGLE_PLAY_SETUP.md`**

---

## 13. Git Commands

```powershell
git add .
git commit -m "Your commit message here"
git push
```

---
