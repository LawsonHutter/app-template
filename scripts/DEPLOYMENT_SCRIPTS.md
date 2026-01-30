# Deployment Scripts Reference

Essential scripts for deploying the Counter App to EC2 and TestFlight.

## Local Development

### `start-local-web.ps1`
**Purpose:** Start backend and frontend locally for web development (one script, two windows)

**Usage:**
```powershell
.\scripts\start-local-web.ps1
```

---

### `start-android.ps1`
**Purpose:** Start backend, launch Flutter emulator if needed, and run app on Android (one script)

**Usage:**
```powershell
.\scripts\start-android.ps1
```

**What it does:**
- Starts Django backend in a separate window
- Detects available emulator (e.g. `Flutter_Emulator`) and launches it if not running
- Waits for emulator to be ready
- Runs Flutter app on the emulator
- App connects to backend at `http://10.0.2.2:8000`

**Prerequisites:**
- At least one Android emulator (e.g. `flutter emulators --create --name Flutter_Emulator`)

---

**What it does:**
- Starts Django backend in a new window (http://localhost:8000)
- Starts Flutter web in a new window (http://localhost:8080, Chrome)
- Close the windows to stop

---

## Initialization

### `init-project.ps1`
**Purpose:** Initialize Django backend and Flutter frontend from scratch

**Usage:**
```powershell
.\scripts\init-project.ps1
```

**What it does:**
- Creates Python virtual environment
- Installs Django dependencies
- Runs database migrations
- Installs Flutter dependencies

---

## EC2 Deployment

### `setup-ec2.ps1` ⭐ **NEW - Recommended for first-time setup**
**Purpose:** Set up a fresh EC2 instance with Docker and all prerequisites

**Usage:**
```powershell
.\scripts\setup-ec2.ps1 -EC2IP "YOUR_EC2_IP" -KeyPath "security\app-key.pem"
```

**What it does:**
- Tests SSH connection to EC2
- Updates system packages
- Installs Docker and Docker Compose
- Creates app directory structure
- Creates `.env.template` for configuration
- Prepares instance for deployment

**When to use:**
- **First time setting up a new EC2 instance**
- After launching a fresh Ubuntu EC2 instance
- Before running `auto-deploy-ec2.ps1`

**Prerequisites:**
- EC2 instance running Ubuntu 22.04 LTS (or similar)
- Security group allows SSH (port 22) from your IP
- SSH key (.pem file) downloaded from AWS

---

### `auto-deploy-ec2.ps1` ⭐ **NEW - Complete automated deployment**
**Purpose:** Fully automated deployment to EC2 (copies code, builds, configures, deploys)

**Usage:**
```powershell
.\scripts\auto-deploy-ec2.ps1 -EC2IP "YOUR_EC2_IP" -Domain "yourdomain.com"
```

**Parameters:**
- `-EC2IP` (required): Your EC2 instance IP address
- `-KeyPath` (optional): Path to SSH key (default: `security\app-key.pem`)
- `-Domain` (optional): Your domain name (for nginx config)
- `-SkipBuild` (optional): Skip frontend build step
- `-SkipMigrations` (optional): Skip database migrations

**What it does:**
1. Copies backend and frontend code to EC2
2. Copies Docker configuration files
3. Creates/updates `.env` file with generated values
4. Builds Flutter frontend on EC2 (or skip with `-SkipBuild`)
5. Configures nginx with domain/IP
6. Builds and starts Docker containers
7. Runs database migrations
8. Collects static files
9. Verifies deployment

**When to use:**
- **After running `setup-ec2.ps1`** for initial deployment
- For complete automated deployments
- When you want everything done automatically

**Example:**
```powershell
# First time: Set up EC2
.\scripts\setup-ec2.ps1 -EC2IP "54.123.45.67"

# Then: Deploy everything
.\scripts\auto-deploy-ec2.ps1 -EC2IP "54.123.45.67" -Domain "myapp.net"
```

---

### `connect-ec2.ps1`
**Purpose:** SSH into your EC2 instance

**Usage:**
```powershell
.\scripts\connect-ec2.ps1
# Or with parameters:
ssh -i "security\your-key.pem" ubuntu@YOUR_EC2_IP
```

**What it does:**
- Finds SSH key automatically
- Connects to EC2 instance

---

### `copy-backend-frontend-to-ec2.ps1`
**Purpose:** Copy backend and frontend code to EC2

**Usage:**
```powershell
.\scripts\copy-backend-frontend-to-ec2.ps1 -EC2IP "YOUR_EC2_IP" -KeyPath "security\your-key.pem"
```

**What it does:**
- Copies `backend/` directory to EC2 (excludes venv, cache, etc.)
- Copies `frontend/` directory to EC2 (excludes build artifacts)
- Preserves project structure on EC2

**When to use:**
- Initial deployment
- After making backend changes
- After making frontend code changes (but use `build-and-deploy-frontend.ps1` for frontend updates)

---

### `build-and-deploy-frontend.ps1`
**Purpose:** Build Flutter app locally and deploy to EC2 (faster than building on EC2)

**Usage:**
```powershell
.\scripts\build-and-deploy-frontend.ps1 `
  -EC2IP "YOUR_EC2_IP" `
  -KeyPath "security\your-key.pem" `
  -ApiUrl "https://your-domain.com/api/counter/"
```

**What it does:**
- Builds Flutter web app locally (uses your machine's RAM)
- Copies built files to EC2
- Builds lightweight nginx Docker image on EC2
- Restarts frontend container

**When to use:**
- After making frontend changes
- When EC2 doesn't have enough RAM for Flutter builds
- Faster than building on EC2

---

## iOS/TestFlight Deployment

### `build-ios.ps1` (macOS only)
**Purpose:** Build iOS app locally for TestFlight

**Usage:**
```powershell
.\scripts\build-ios.ps1 -ApiUrl "https://your-domain.com/api/counter/"
```

**What it does:**
- Builds Flutter iOS app
- Creates IPA file
- Opens Xcode for manual upload

**When to use:**
- If you have a Mac
- For local testing before TestFlight
- Alternative to Codemagic

**Note:** Most users should use Codemagic (see `codemagic.yaml`) instead.

---

### `codemagic.yaml`
**Purpose:** CI/CD configuration for automatic TestFlight builds

**Setup:**
1. Connect repository to Codemagic
2. Add environment variables in Codemagic UI:
   - `APP_STORE_CONNECT_ISSUER_ID`
   - `APP_STORE_CONNECT_KEY_IDENTIFIER`
   - `APP_STORE_CONNECT_PRIVATE_KEY`
3. Update `APP_ID` in `codemagic.yaml`
4. Push to `main` branch → automatic build

**What it does:**
- Builds iOS app on Codemagic's Mac servers
- Uploads to App Store Connect
- Submits to TestFlight automatically

---

## Script Summary

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `init-project.ps1` | Initialize project | First time setup |
| `start-local-web.ps1` | Start backend + frontend (web) | Local web development |
| `start-android.ps1` | Start backend + launch emulator + run Android app | Android emulator testing |
| `setup-ec2.ps1` ⭐ | Set up fresh EC2 instance | **First time EC2 setup** |
| `auto-deploy-ec2.ps1` ⭐ | Complete automated deployment | **Full deployment to EC2** |
| `connect-ec2.ps1` | SSH to EC2 | Manual server access |
| `copy-backend-frontend-to-ec2.ps1` | Copy code to EC2 | Manual code updates |
| `build-and-deploy-frontend.ps1` | Deploy frontend | Frontend updates (recommended) |
| `build-ios.ps1` | Build iOS locally | macOS users only |
| `codemagic.yaml` | TestFlight CI/CD | iOS deployment (recommended) |

---

## Typical Workflow

### First Time Setup
1. `.\scripts\init-project.ps1` - Initialize project
2. Test locally
3. Launch EC2 instance in AWS Console (Ubuntu 22.04 LTS)
4. `.\scripts\setup-ec2.ps1 -EC2IP "YOUR_EC2_IP"` - Set up EC2 instance
5. `.\scripts\auto-deploy-ec2.ps1 -EC2IP "YOUR_EC2_IP" -Domain "yourdomain.com"` - Deploy app
6. Configure Codemagic for TestFlight

### Regular Updates

**Backend changes:**
```powershell
.\scripts\copy-backend-frontend-to-ec2.ps1 -EC2IP "YOUR_EC2_IP"
# Then on EC2: docker compose restart backend
```

**Frontend changes:**
```powershell
.\scripts\build-and-deploy-frontend.ps1 -EC2IP "YOUR_EC2_IP" -ApiUrl "https://your-domain.com/api/counter/"
```

**iOS updates:**
```powershell
git add .
git commit -m "iOS update"
git push origin main
# Codemagic automatically builds and uploads
```

---

## File Locations

- **SSH Keys:** `security/your-key.pem` (create this directory)
- **Backend:** `backend/`
- **Frontend:** `frontend/`
- **Docker config:** `docker-compose.yml`, `docker-compose.prod.yml`
- **CI/CD:** `codemagic.yaml`

---

## Troubleshooting

**Script won't run:**
- Check PowerShell execution policy: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Verify you're in the project root directory

**EC2 connection fails:**
- Check SSH key permissions: `chmod 400 security/your-key.pem` (on Mac/Linux)
- Verify EC2 security group allows SSH (port 22)
- Check EC2 IP address is correct

**Build fails:**
- Verify Flutter is installed: `flutter doctor`
- Check Python version: `python --version` (need 3.8+)
- Ensure dependencies are installed

For more help, see `INIT_SETUP.md` in the project root.
