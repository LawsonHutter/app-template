# Counter App - Initialization & Deployment Guide

This is a simple counter app with a Flutter frontend and Django backend. This guide shows you how to initialize the project and deploy it to EC2 and TestFlight.

## Prerequisites

### Required Software
- **Python 3.8+** - [Download](https://www.python.org/downloads/)
- **Flutter SDK** - [Download](https://flutter.dev/docs/get-started/install)
- **Git** - [Download](https://git-scm.com/downloads)

### For Deployment
- **AWS Account** (for EC2)
- **Apple Developer Account** (for TestFlight)
- **Codemagic Account** (for iOS builds without Mac)

---

## Step 0: Rename project (if you cloned this as a template)

If you cloned this repo to start a **new app** (not "Counter App"), run the rename script once to rebrand the project:

```powershell
.\scripts\rename-project.ps1 -AppName "My New App" -Domain "my-new-app.net" -BundleId "com.mydomain.mynewapp"
```

| Parameter   | Meaning |
|------------|---------|
| **AppName** | Display name (e.g. window title, docs). |
| **Domain**  | Your app’s domain (e.g. `myapp.net`). Used in docs and deployment URLs. |
| **BundleId** | iOS/Android bundle ID (e.g. `com.yourcompany.yourapp`). Must match App Store Connect. |
| **ProjectName** | Optional. Defaults to domain without TLD (e.g. `myapp` from `myapp.net`). Used in paths/scripts. |

The script will:
- Replace **"Counter App"** with your app name in readme, docs, and Flutter (`main.dart`, `counter_screen.dart`).
- Replace **your-app-name.net** / **your-app-name** with your domain and project name in scripts and docs.
- Replace **com.your-app-name.counterapp** / **com.yourdomain.yourapp** with your bundle ID in `codemagic.yaml`, scripts, and the iOS Xcode project (`project.pbxproj`).

It asks for confirmation, then updates the listed files. After running:

1. Review changes: `git diff`
2. Set Codemagic `APP_ID` / `API_BASE_URL` if you use CI.
3. In App Store Connect, create the app with the same Bundle ID.
4. EC2 scripts use remote dir `~/app`; change to `~/<ProjectName>` in scripts if you prefer.

Then continue with **Step 1** below.

---

## Step 1: Initialize the Project

Run the initialization script to set up Django and Flutter:

```powershell
.\scripts\init-project.ps1
```

This script will:
- ✅ Create Python virtual environment
- ✅ Install Django dependencies
- ✅ Run database migrations
- ✅ Install Flutter dependencies

### Manual Setup (Alternative)

If you prefer to set up manually:

**Backend:**
```powershell
cd backend
python -m venv venv
.\venv\Scripts\Activate.ps1  # Windows
# or: source venv/bin/activate  # Mac/Linux
pip install -r requirements.txt
python manage.py migrate
```

**Frontend:**
```powershell
cd frontend
flutter pub get
```

---

## Step 2: Run Locally

### Option A: Web Browser

One script starts both backend and frontend:

```powershell
.\scripts\start-local-web.ps1
```

- Opens two windows: backend (Django) and frontend (Flutter web).
- Backend: `http://localhost:8000`
- Frontend: `http://localhost:8080` (Chrome).
- Close the windows to stop.

### Option B: Android Emulator

One script starts backend, launches emulator, and runs the app:

```powershell
.\scripts\start-android.ps1
```

- Starts backend in a separate window
- Launches your Flutter emulator if not running (e.g. `Flutter_Emulator`)
- Runs Flutter app on the emulator
- App connects to backend at `http://10.0.2.2:8000` (Android emulator's localhost)

**Prerequisites:**
- At least one Android emulator (e.g. create with `flutter emulators --create --name Flutter_Emulator` or in Android Studio)

### Manual Setup

To run in separate terminals instead:
- **Backend:** `cd backend` → `.\venv\Scripts\Activate.ps1` → `python manage.py runserver`
- **Frontend (Web):** `cd frontend` → `flutter run -d chrome --web-port 8080 --dart-define=API_BASE_URL=http://localhost:8000/api/counter/`
- **Frontend (Android):** `cd frontend` → `flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/counter/`

---

## Step 3: Deploy to EC2

### Prerequisites
- EC2 instance running Ubuntu 22.04 or 24.04 LTS
- SSH key (.pem file) in `security/` directory
- Domain name pointing to EC2 IP (optional)

### Launch EC2 Instance

**📚 Complete Guide**: See [`docs/EC2_LAUNCH_SETTINGS.md`](docs/EC2_LAUNCH_SETTINGS.md) for detailed launch settings

**Quick Summary:**
1. **AMI**: Ubuntu Server 24.04 LTS (or 22.04 LTS)
2. **Instance type**: t3.micro (free tier eligible)
3. **Key pair**: Create new key pair and download `.pem` file
4. **Security group**: 
   - SSH (22) from **"My IP"** (not "Anywhere" - security!)
   - HTTP (80) from **"Anywhere"** (0.0.0.0/0)
   - HTTPS (443) from **"Anywhere"** (0.0.0.0/0)
5. **Storage**: Increase to **20-30 GiB** (not 8 GiB - too small!)
6. **Auto-assign public IP**: Enable

**After launch**: Save your `.pem` key file to `security/` directory

### Initial EC2 Setup

1. **Connect to EC2:**
   ```powershell
   .\scripts\connect-ec2.ps1 -EC2IP "YOUR_EC2_IP" -KeyPath "security\your-key.pem"
   ```

2. **On EC2, install Docker:**
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker ubuntu
   ```

3. **Clone and set up project on EC2:**
   ```bash
   git clone YOUR_REPO_URL app
   cd app
   ```

4. **Copy backend and frontend to EC2:**
   ```powershell
   .\scripts\copy-backend-frontend-to-ec2.ps1 -EC2IP "YOUR_EC2_IP" -KeyPath "security\your-key.pem"
   ```

5. **On EC2, start services:**
   ```bash
   cd ~/app
   docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
   ```

### Update Frontend (After Code Changes)

**Option A: Build locally and deploy (Recommended - faster):**
```powershell
.\scripts\build-and-deploy-frontend.ps1 `
  -EC2IP "YOUR_EC2_IP" `
  -KeyPath "security\your-key.pem" `
  -ApiUrl "https://your-domain.com/api/counter/"
```

**Option B: Build on EC2:**
```powershell
# SSH to EC2 and run:
cd ~/app
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build frontend
```

---

## Step 4: Deploy to TestFlight (iOS)

### Prerequisites
- Apple Developer Account ($99/year)
- App created in App Store Connect
- Codemagic account (free tier available)

### Setup Codemagic

1. **Connect Repository:**
   - Go to [Codemagic](https://codemagic.io)
   - Add application → Connect your GitHub repository
   - Select Flutter project

2. **Add Environment Variables:**
   - Go to Settings → Environment variables
   - Create group: `app_store_credentials`
   - Add variables:
     - `APP_STORE_CONNECT_ISSUER_ID` - From App Store Connect → Users and Access → Keys
     - `APP_STORE_CONNECT_KEY_IDENTIFIER` - Key ID from App Store Connect
     - `APP_STORE_CONNECT_PRIVATE_KEY` - Private key (.p8 file content)

3. **Update `codemagic.yaml`:**
   - Update `APP_ID` with your Bundle ID (e.g., `com.yourname.counterapp`)
   - Update `API_BASE_URL` with your backend URL
   - Update email in `publishing.email.recipients`

4. **Enable Auto-Builds:**
   - Settings → Build triggers
   - Enable "Start builds automatically" for iOS workflow

### Deploy

**Automatic (Recommended):**
```powershell
git add .
git commit -m "Ready for TestFlight"
git push origin main
```
Codemagic will automatically build and upload to TestFlight.

**Manual:**
- Go to Codemagic → Your app → Start new build
- Select iOS workflow → main branch

### Build Locally (macOS only)

If you have a Mac:
```powershell
.\scripts\build-ios.ps1 -ApiUrl "https://your-domain.com/api/counter/"
```

Then upload via Xcode:
1. Open `frontend/ios/Runner.xcworkspace` in Xcode
2. Product → Archive
3. Distribute App → App Store Connect

---

## Essential Scripts

### Local Development
- `scripts/init-project.ps1` - Initialize Django and Flutter
- `scripts/start-local-web.ps1` - Start backend + frontend locally (one script)
- `scripts/start-backend-local.ps1` - Start Django server only
- `scripts/start-frontend-local.ps1` - Start Flutter web only

### EC2 Deployment
- `scripts/setup-ec2.ps1` - **NEW**: Set up a fresh EC2 instance (install Docker, etc.)
- `scripts/auto-deploy-ec2.ps1` - **NEW**: Complete automated deployment to EC2
- `scripts/connect-ec2.ps1` - SSH to EC2 instance
- `scripts/copy-backend-frontend-to-ec2.ps1` - Copy code to EC2
- `scripts/build-and-deploy-frontend.ps1` - Build Flutter locally and deploy to EC2

### iOS/TestFlight
- `scripts/build-ios.ps1` - Build iOS app (macOS only)
- `codemagic.yaml` - CI/CD configuration for TestFlight

---

## Project Structure

```
.
├── backend/              # Django backend
│   ├── click_counter/   # Counter app
│   ├── manage.py
│   └── requirements.txt
├── frontend/            # Flutter frontend
│   ├── lib/
│   │   ├── main.dart
│   │   └── counter_screen.dart
│   └── pubspec.yaml
├── scripts/             # Deployment scripts
├── docker-compose.yml   # Docker configuration
└── codemagic.yaml       # TestFlight CI/CD
```

---

## Troubleshooting

### Backend won't start
- Check Python version: `python --version` (need 3.8+)
- Activate virtual environment
- Check port 8000 is available

### Frontend won't start
- Check Flutter: `flutter doctor`
- Install dependencies: `flutter pub get`
- Check API URL matches backend

### EC2 deployment fails
- Verify SSH key permissions: `chmod 400 security/your-key.pem`
- Check EC2 security group allows SSH (port 22)
- Verify Docker is installed on EC2

### TestFlight upload fails
- Verify App exists in App Store Connect
- Check Bundle ID matches in `codemagic.yaml`
- Verify API credentials in Codemagic environment variables

---

## Quick Reference

**Backend API:**
- GET `/api/counter/` - Get current count
- POST `/api/counter/` - Increment count

**Local URLs:**
- Backend: `http://localhost:8000`
- Frontend: `http://localhost:8080`

**Production URLs:**
- Backend: `https://your-domain.com/api/counter/`
- Frontend: `https://your-domain.com`

---

## Next Steps

1. ✅ Initialize project: `.\scripts\init-project.ps1`
2. ✅ Test locally
3. ✅ Deploy to EC2
4. ✅ Set up TestFlight via Codemagic
5. ✅ Share TestFlight link with testers

For detailed guides, see the `docs/` directory.
