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

### `setup-ec2.ps1` ⭐ **First-time EC2 setup**
**Purpose:** Set up a fresh EC2 instance with Docker and all prerequisites

**Usage:**
```powershell
.\scripts\setup-ec2.ps1
```

**What it does:**
- Reads configuration from `security/deployment.config`
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
- `security/deployment.config` configured with EC2_IP, KEY_PATH

---

### `build-frontend-local.ps1` ⭐ **Build Flutter locally**
**Purpose:** Build Flutter web app on your local machine (faster than building on EC2)

**Usage:**
```powershell
.\scripts\build-frontend-local.ps1
```

**What it does:**
- Reads API URL from `security/deployment.config`
- Checks Flutter is installed locally
- Runs `flutter pub get`
- Builds Flutter web with `flutter build web --release`
- Outputs to `frontend/build/web`

**When to use:**
- **Before every deployment** to EC2
- After making frontend changes
- To prepare production-ready frontend build

**Prerequisites:**
- Flutter SDK installed locally
- `security/deployment.config` configured with DOMAIN or EC2_IP

---

### `setup-ssl.ps1` ⭐ **Set up HTTPS with Let's Encrypt**
**Purpose:** Automate full SSL setup (certificate, nginx config, frontend rebuild)

**Usage:**
```powershell
.\scripts\setup-ssl.ps1
```

**Parameters:**
- `-Email` (optional): Email for Let's Encrypt (or set `SSL_EMAIL` in deployment.config)
- `-RebuildAndDeploy` (optional): Also rebuild frontend for HTTPS and deploy (otherwise SSL-only)

**What it does:**
1. Creates nginx HTTPS config from template (replaces domain)
2. SSHs to EC2, stops nginx, installs Certbot, obtains Let's Encrypt certificate
3. Commits and pushes nginx.https.conf and docker-compose.ssl.yml
4. Enables SSL in Docker on EC2 (pulls code, starts with docker-compose.ssl.yml)
5. If `-RebuildAndDeploy`: sets USE_HTTPS=true, rebuilds frontend, commits, and deploys

**When to use:**
- After HTTP is working and domain points to EC2
- One-time SSL setup

**Prerequisites:**
- Domain pointing to EC2 (A records for @ and www)
- EC2 security group allows port 443
- `security/deployment.config` configured with DOMAIN, EC2_IP, KEY_PATH

---

### `update-codemagic-config.ps1` **Sync codemagic.yaml from deployment.config**
**Purpose:** Update API_BASE_URL, APP_ID, and email in codemagic.yaml from your config

**Usage:**
```powershell
.\scripts\update-codemagic-config.ps1
```

**Prerequisites:** `APP_ID` and optionally `DOMAIN`, `USE_HTTPS`, `CODEMAGIC_EMAIL` in `security/deployment.config`

---

### `auto-deploy-ec2.ps1` ⭐ **Complete automated deployment**
**Purpose:** Fully automated deployment to EC2 (pulls code from GitHub, deploys with Docker)

**Usage:**
```powershell
.\scripts\auto-deploy-ec2.ps1
```

**Parameters:**
- `-SkipMigrations` (optional): Skip database migrations

**What it does:**
1. Reads configuration from `security/deployment.config`
2. Tests SSH connection to EC2
3. Pulls latest code from GitHub (including pre-built frontend)
4. Creates/updates `.env` file with generated values
5. Configures nginx with domain/IP
6. Builds and starts Docker containers
7. Runs database migrations
8. Verifies deployment

**When to use:**
- **After running `setup-ec2.ps1`** for initial deployment
- After building frontend locally with `build-frontend-local.ps1`
- After pushing changes to GitHub
- For complete automated deployments

**Example workflow:**
```powershell
# 1. First time: Set up EC2
.\scripts\setup-ec2.ps1

# 2. Build frontend locally
.\scripts\build-frontend-local.ps1

# 3. Commit and push
git add frontend/build
git commit -m "Build frontend"
git push origin main

# 4. Deploy to EC2
.\scripts\auto-deploy-ec2.ps1
```

**Prerequisites:**
- `security/deployment.config` configured with:
  - `EC2_ELASTIC_IP` or `EC2_IP`
  - `KEY_PATH`
  - `GITHUB_URL` (required)
  - `GITHUB_BRANCH` (optional, defaults to main)
  - `DOMAIN` (optional)

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
