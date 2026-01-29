# Using This Project as a Template

This guide explains how to use this Flutter + Django project as a template for your own projects.

## ⚡ Quick Reference

**Fastest way to create a new project:**

1. **Copy the template**: Clone or copy this repository
2. **Clean up scripts**: Run `.\scripts\cleanup-template.ps1`
3. **Customize names**: Search/replace project name, domain, bundle IDs
4. **Update backend**: Rename Django project and app folders
5. **Test**: Run `.\scripts\start-all-local-sqlite.ps1`
6. **Commit**: Initialize new git repo and commit

**See full step-by-step guide below.**

## 🎯 Quick Start: Create a New Project from This Template

### Step 1: Copy the Template

```bash
# Clone or copy this repository
git clone <this-repo-url> my-new-project
cd my-new-project

# Or if you have it locally, copy the entire directory
cp -r survey-web-app my-new-project
cd my-new-project
```

### Step 2: Remove Git History (Start Fresh)

```bash
# Remove existing git history
rm -rf .git

# Initialize new git repository
git init
git branch -M main
```

### Step 3: Customize Project Name

**Search and replace** the following throughout the project:

1. **Project name**: `survey-web-app` → `your-project-name`
2. **App name**: `Survey App` → `Your App Name`
3. **Domain references**: `dipoll.net` → `yourdomain.com`
4. **Bundle ID**: `com.dipoll.surveyapp` → `com.yourdomain.yourapp`

**Files to update:**

```bash
# Use find/replace in your editor for:
- readme.md
- codemagic.yaml (APP_ID)
- frontend/pubspec.yaml (name, description)
- frontend/ios/Runner/Info.plist (CFBundleDisplayName, CFBundleName)
- frontend/android/app/build.gradle (applicationId, namespace)
- docker-compose.yml (container names, if custom)
- All documentation files in docs/
```

### Step 4: Update Backend Configuration

**Update Django project name:**

```bash
cd backend
# Rename the Django project folder
mv survey_backend your_project_backend

# Update references in:
# - manage.py
# - wsgi.py
# - asgi.py
# - settings.py (if referenced)
```

**Update Django app name:**

```bash
cd backend
# Rename your Django app
mv click_counter your_app_name

# Update references in:
# - settings.py (INSTALLED_APPS)
# - urls.py (if app-specific)
# - All import statements
```

### Step 5: Update Frontend Configuration

**Update Flutter app:**

```bash
cd frontend

# Update pubspec.yaml
# - name: your_app_name
# - description: Your app description

# Update API URL in lib/main.dart
# Change API_BASE_URL default value
```

**Update iOS Bundle ID:**

1. Open `frontend/ios/Runner.xcodeproj` in Xcode (or edit manually)
2. Change Bundle Identifier to `com.yourdomain.yourapp`
3. Or update in `codemagic.yaml` (APP_ID variable)

**Update Android Package Name:**

1. Edit `frontend/android/app/build.gradle`
2. Change `applicationId` and `namespace` to `com.yourdomain.yourapp`

### Step 6: Clean Up Template-Specific Files

**Remove or update:**

- `command-notes.txt` - Personal notes, remove or customize
- `security/survey-app-key.pem` - Your EC2 key, remove and add your own
- `docs/` - Review and remove/customize documentation you don't need
- `.github/workflows/` - Update for your repository

**Update documentation:**

- Review all files in `docs/` and update domain names, project names
- Remove deployment guides if not using AWS/EC2
- Customize `readme.md` for your project

### Step 7: Initialize Fresh Dependencies

```bash
# Backend
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate

# Frontend
cd frontend
flutter pub get
```

### Step 8: Update Environment Variables

**Create `.env` files if needed:**

```bash
# backend/.env (if using)
SECRET_KEY=your-new-secret-key
DEBUG=1
DATABASE_URL=
ALLOWED_HOSTS=localhost,127.0.0.1
CORS_ALLOWED_ORIGINS=http://localhost:8080
```

**Generate new Django secret key:**

```powershell
.\scripts\generate-secret-key.ps1
```

### Step 9: Test the Template

```powershell
# Test local development
.\scripts\start-all-local-sqlite.ps1

# Or test Docker
.\scripts\start-docker.ps1
```

### Step 10: Commit Your New Project

```bash
git add .
git commit -m "Initial commit: Created from template"
git remote add origin <your-new-repo-url>
git push -u origin main
```

---

## 📋 Customization Checklist

Use this checklist to ensure you've customized everything:

### Project Identity
- [ ] Project name changed throughout codebase
- [ ] App display name updated
- [ ] Domain names updated (if deploying)
- [ ] Bundle ID/Package name updated (iOS/Android)

### Backend
- [ ] Django project folder renamed
- [ ] Django app(s) renamed
- [ ] Database models customized
- [ ] API endpoints updated
- [ ] Secret key regenerated
- [ ] CORS settings updated

### Frontend
- [ ] Flutter app name updated
- [ ] API URL updated in code
- [ ] App icons replaced (iOS/Android)
- [ ] App display name updated
- [ ] Bundle ID updated (iOS)
- [ ] Package name updated (Android)

### Deployment
- [ ] Codemagic configuration updated (if using)
- [ ] Docker compose files updated
- [ ] EC2/deployment scripts updated
- [ ] Environment variables configured
- [ ] SSL certificates configured (if using custom domain)

### Documentation
- [ ] README.md customized
- [ ] Documentation files reviewed/updated
- [ ] Template-specific content removed
- [ ] Deployment guides updated

### Git & CI/CD
- [ ] Git history cleared (if starting fresh)
- [ ] GitHub Actions workflows updated
- [ ] Repository secrets configured
- [ ] CI/CD pipelines tested

---

## 🧹 Script Cleanup Guide

This template includes many scripts. Here's what to keep vs. remove:

### ✅ Keep These Core Scripts

**Local Development:**
- `start-backend-local.ps1` - Start Django backend
- `start-frontend-local.ps1` - Start Flutter frontend
- `start-all-local-sqlite.ps1` - Start both with SQLite
- `view-db.ps1` - View SQLite database

**Docker:**
- `start-docker.ps1` - Start all services
- `start-docker-detached.ps1` - Start in background
- `stop-docker.ps1` - Stop services
- `migrate-docker.ps1` - Run migrations

**Utilities:**
- `generate-secret-key.ps1` - Generate Django secret key
- `create-env.ps1` - Create environment file

### ⚠️ Keep If Using These Features

**iOS Development:**
- `build-ios.ps1` / `build-ios.sh` - Build iOS app (if deploying to iOS)

**AWS/EC2 Deployment:**
- `deploy-production.ps1` - Production deployment helper
- `build-and-deploy-frontend.ps1` - Build and deploy frontend
- `connect-ec2.ps1` - Connect to EC2 instance
- `copy-to-ec2.ps1` - Copy files to EC2
- `copy-backend-frontend-to-ec2.ps1` - Copy both to EC2
- `deploy-domain.ps1` - Deploy with custom domain
- `check-deployment.ps1` - Check deployment status
- `fix-ssh-permissions.ps1` - Fix SSH permissions

### ❌ Remove These (Duplicates/Unused)

**Duplicate .bat files** (PowerShell versions are preferred):
- `start-backend-local.bat` → Use `.ps1` version
- `start-frontend-local.bat` → Use `.ps1` version
- `start-docker.bat` → Use `.ps1` version
- `stop-docker.bat` → Use `.ps1` version

**Potentially Unused:**
- `start-all-local.ps1` → Use `start-all-local-sqlite.ps1` instead
- `start-local-with-sqlite.ps1` → Duplicate functionality
- `stop-docker-before-local.ps1` → Handled by `start-all-local-sqlite.ps1`
- `check-backend.ps1` → May not be needed
- `generate-secret-key-simple.ps1` → Use full version instead

### 🗑️ Cleanup Commands

**Option 1: Use the cleanup script (Recommended)**

```powershell
# Run the interactive cleanup script
.\scripts\cleanup-template.ps1
```

This script will:
- Show you which scripts can be safely removed
- List scripts to review (deployment-specific)
- Optionally remove duplicate scripts automatically
- Show which core scripts to keep

**Option 2: Manual cleanup**

```powershell
# Remove duplicate .bat files
Remove-Item scripts\start-backend-local.bat
Remove-Item scripts\start-frontend-local.bat
Remove-Item scripts\start-docker.bat
Remove-Item scripts\stop-docker.bat

# Remove unused scripts (review first!)
Remove-Item scripts\start-all-local.ps1  # Use start-all-local-sqlite.ps1
Remove-Item scripts\start-local-with-sqlite.ps1  # Duplicate
Remove-Item scripts\stop-docker-before-local.ps1  # Handled elsewhere
Remove-Item scripts\check-backend.ps1  # If not using
Remove-Item scripts\generate-secret-key-simple.ps1  # Use full version
```

---

## 📁 Project Structure Overview

```
your-project/
├── backend/              # Django REST API
│   ├── your_project_backend/  # Django project (rename from survey_backend)
│   ├── your_app/         # Django app (rename from click_counter)
│   ├── manage.py
│   └── requirements.txt
│
├── frontend/             # Flutter web app
│   ├── lib/             # Dart source code
│   ├── ios/             # iOS project
│   ├── android/         # Android project
│   └── pubspec.yaml
│
├── scripts/             # Automation scripts
│   ├── start-*.ps1      # Local development
│   ├── *-docker.ps1     # Docker management
│   └── deploy-*.ps1     # Deployment (if using)
│
├── infra/               # Infrastructure configs
│   └── nginx/           # Nginx configs
│
├── docs/                # Documentation
│   ├── TEMPLATE_INSTRUCTIONS.md  # This file
│   └── ...              # Other guides
│
├── docker-compose.yml   # Docker development
├── docker-compose.prod.yml  # Docker production
├── codemagic.yaml       # iOS build config (if using)
└── readme.md            # Project README
```

---

## 🔧 Common Customizations

### Change API Endpoint

**Frontend (`frontend/lib/main.dart`):**
```dart
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://yourdomain.com/api/your-endpoint/',
);
```

**Backend (`backend/your_app/urls.py`):**
```python
urlpatterns = [
    path('api/your-endpoint/', views.your_view, name='your-endpoint'),
]
```

### Change Database Models

**Edit `backend/your_app/models.py`:**
```python
class YourModel(models.Model):
    # Your fields here
    pass
```

Then run:
```bash
python manage.py makemigrations
python manage.py migrate
```

### Change Flutter App Theme

**Edit `frontend/lib/main.dart`:**
```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // Change color
  useMaterial3: true,
),
```

### Update Docker Configuration

**Edit `docker-compose.yml`** for development settings
**Edit `docker-compose.prod.yml`** for production settings

---

## 🚀 Next Steps After Customization

1. **Test locally**: `.\scripts\start-all-local-sqlite.ps1`
2. **Test Docker**: `.\scripts\start-docker.ps1`
3. **Set up CI/CD**: Update GitHub Actions workflows
4. **Configure deployment**: Set up your hosting (AWS, VPS, etc.)
5. **Set up iOS/Android**: Configure Codemagic or GitHub Actions for mobile builds

---

## 📚 Additional Resources

- **Local Development**: See `docs/QUICK_START.md`
- **Deployment**: See `docs/DEPLOY_TO_PRODUCTION.md`
- **Docker**: See `docs/DOCKER_EXPLAINED.md`
- **iOS Builds**: See `docs/CODEMAGIC_SETUP.md`
- **Scripts**: See `scripts/README.md`

---

## ❓ Troubleshooting

### "Module not found" errors
- Make sure you renamed all imports after renaming Django project/app
- Check `INSTALLED_APPS` in `settings.py`

### "Bundle ID already exists" (iOS)
- Change Bundle ID in `codemagic.yaml` and Xcode project
- Use a unique identifier like `com.yourdomain.yourapp`

### Scripts not working
- Ensure you're using PowerShell (not Command Prompt)
- Check file paths are correct after renaming
- Review script contents for hardcoded paths

### Docker issues
- Update container names in `docker-compose.yml`
- Check port conflicts
- Review environment variables

---

## 💡 Tips

1. **Start simple**: Get local development working first, then customize
2. **Version control**: Commit frequently as you customize
3. **Documentation**: Update docs as you make changes
4. **Test incrementally**: Test after each major change
5. **Keep it clean**: Remove unused scripts and files

---

**Happy coding! 🎉**
