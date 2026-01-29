# Template Setup Guide

This guide explains how to convert this project into a template and create new projects from it.

---

## 🎯 Overview

**Goal**: Create a reusable template that can be used to quickly spin up new Flutter + Django projects with:
- ✅ AWS/EC2 deployment ready
- ✅ Codemagic iOS build pipeline
- ✅ TestFlight deployment
- ✅ Complete documentation

---

## Part 1: Convert Current Project to Template

### Step 1: Clean Up Current Project

Before converting to template, clean up project-specific items:

1. **Remove sensitive files**:
   ```powershell
   # Remove security keys (if any)
   Remove-Item security\*.pem -ErrorAction SilentlyContinue
   ```

2. **Remove git history** (optional, for fresh template):
   ```powershell
   Remove-Item -Recurse -Force .git
   git init
   git branch -M main
   ```

3. **Review and clean**:
   - Remove any project-specific data
   - Remove test databases
   - Clean up any temporary files

### Step 2: Run Template Conversion Script

```powershell
.\scripts\convert-to-template.ps1
```

**What it does:**
- Replaces `dipoll.net` → `yourdomain.com`
- Replaces `com.dipoll.surveyapp` → `com.yourdomain.yourapp`
- Replaces `dipoll` → `your-app-name`
- Replaces API keys with placeholders
- Updates all relevant files

### Step 3: Review Changes

```powershell
git diff
```

Review all changes to ensure placeholders are correct.

### Step 4: Create Template Repository

1. **Create new GitHub repository**:
   - Name: `flutter-django-template` (or your preferred name)
   - Description: "Template for Flutter + Django web apps with AWS deployment and iOS TestFlight"
   - Make it **Public** (for template) or **Private** (if you prefer)

2. **Push to template repo**:
   ```powershell
   git remote add template https://github.com/yourusername/flutter-django-template.git
   git add .
   git commit -m "Initial template setup"
   git push -u template main
   ```

3. **Mark as template** (optional):
   - Go to repository **Settings** → **Template repository**
   - Check "Template repository"
   - This allows others to use "Use this template" button

---

## Part 2: Create New Project from Template

### Option A: Use GitHub Template Feature

1. **Go to template repository** on GitHub
2. Click **"Use this template"** → **"Create a new repository"**
3. Fill in:
   - **Repository name**: `dipoll` (or your project name)
   - **Description**: Your project description
   - **Visibility**: Private or Public
4. Click **"Create repository from template"**

### Option B: Clone and Customize

```powershell
# Clone template
git clone https://github.com/yourusername/flutter-django-template.git dipoll
cd dipoll

# Remove template git history
Remove-Item -Recurse -Force .git
git init
git branch -M main
```

### Step 1: Run Setup Script

```powershell
.\scripts\setup-from-template.ps1 `
  -ProjectName "dipoll" `
  -Domain "dipoll.net" `
  -BundleId "com.dipoll.surveyapp" `
  -AppName "Dipoll Survey App"
```

**Parameters:**
- `-ProjectName`: Your project name (e.g., "dipoll")
- `-Domain`: Your domain (e.g., "dipoll.net")
- `-BundleId`: iOS Bundle ID (e.g., "com.dipoll.surveyapp")
- `-AppName`: Display name for your app (optional)

### Step 2: Update App Store Connect Credentials

1. **Create API Key** in App Store Connect:
   - Go to https://appstoreconnect.apple.com → **Users and Access** → **Keys**
   - Create new key
   - Save: Issuer ID, Key ID, Private Key

2. **Update `codemagic.yaml`**:
   - Replace `YOUR_ISSUER_ID` with your Issuer ID
   - Replace `YOUR_KEY_ID` with your Key ID
   - Replace `YOUR_TEAM_ID` with your Team ID

3. **Add to Codemagic**:
   - Go to Codemagic → Your app → **Settings** → **Environment variables**
   - Add group `app_store_credentials` with:
     - `APP_STORE_CONNECT_ISSUER_ID`
     - `APP_STORE_CONNECT_KEY_IDENTIFIER`
     - `APP_STORE_CONNECT_PRIVATE_KEY`

### Step 3: Create App in App Store Connect

1. Go to https://appstoreconnect.apple.com → **My Apps**
2. Click **+** → **New App**
3. Fill in:
   - **Platform**: iOS
   - **Name**: Your app name
   - **Bundle ID**: Your Bundle ID (e.g., `com.dipoll.surveyapp`)
   - **SKU**: Unique identifier
4. Click **Create**

### Step 4: Set Up Codemagic

1. **Connect repository**:
   - Go to https://codemagic.io
   - Click **Add application**
   - Connect your GitHub repository
   - Select **Flutter** project type

2. **Enable automatic builds**:
   - Go to **Settings** → **Build triggers**
   - Enable **"Start builds automatically"** for iOS Workflow

3. **Verify configuration**:
   - Check `codemagic.yaml` is detected
   - Verify environment variables are set

### Step 5: Set Up AWS/EC2 Deployment

1. **Launch EC2 instance**:
   - See `docs/AWS_EC2_LAUNCH_GUIDE.md`
   - Or `docs/DEPLOY_TO_PRODUCTION.md`

2. **Update domain DNS**:
   - Point your domain to EC2 IP
   - See `docs/CUSTOM_DOMAIN_QUICK_START.md`

3. **Deploy**:
   - Follow `docs/DEPLOY_TO_PRODUCTION.md`
   - Or use deployment scripts

### Step 6: Test Locally

```powershell
# Test backend and frontend locally
.\scripts\start-all-local-sqlite.ps1
```

Verify everything works before deploying.

### Step 7: Initial Commit

```powershell
git add .
git commit -m "Initial project setup from template"
git remote add origin https://github.com/yourusername/dipoll.git
git push -u origin main
```

---

## Template Checklist

### Before Converting to Template

- [ ] Remove sensitive files (API keys, certificates, etc.)
- [ ] Remove project-specific data
- [ ] Clean up git history (optional)
- [ ] Review all files for project-specific references
- [ ] Run `convert-to-template.ps1`
- [ ] Review changes with `git diff`
- [ ] Test that template still works
- [ ] Create template repository on GitHub
- [ ] Push to template repository

### When Creating New Project

- [ ] Clone or use template
- [ ] Run `setup-from-template.ps1` with your values
- [ ] Update App Store Connect credentials
- [ ] Create app in App Store Connect
- [ ] Set up Codemagic
- [ ] Configure AWS/EC2
- [ ] Update domain DNS
- [ ] Test locally
- [ ] Deploy to production
- [ ] Test on device via TestFlight

---

## Template Structure

The template includes:

```
template/
├── backend/              # Django backend
├── frontend/             # Flutter frontend
├── infra/                # Infrastructure configs (nginx, etc.)
├── scripts/              # Helper scripts
├── docs/                 # Complete documentation
├── codemagic.yaml        # iOS build configuration
├── docker-compose.yml    # Local development
└── docker-compose.prod.yml  # Production deployment
```

---

## Customization Points

When creating a new project, you'll need to customize:

1. **Project Name**: Throughout codebase
2. **Domain**: API URLs, nginx configs, CORS settings
3. **Bundle ID**: iOS project, Codemagic, App Store Connect
4. **App Name**: Flutter app display name
5. **API Credentials**: App Store Connect, AWS, etc.
6. **Backend Models**: Django models for your use case
7. **Frontend UI**: Flutter screens and widgets

---

## Quick Reference

### Convert to Template
```powershell
.\scripts\convert-to-template.ps1
```

### Create New Project
```powershell
.\scripts\setup-from-template.ps1 `
  -ProjectName "your-project" `
  -Domain "yourdomain.com" `
  -BundleId "com.yourdomain.yourapp"
```

### Test Locally
```powershell
.\scripts\start-all-local-sqlite.ps1
```

---

## Next Steps

After setting up your new project:

1. **Read**: `docs/QUICK_START.md` for local development
2. **Read**: `docs/DEPLOYMENT_STEPS.md` for TestFlight deployment
3. **Read**: `docs/DEPLOY_TO_PRODUCTION.md` for AWS deployment
4. **Customize**: Backend models and frontend UI for your use case

---

**You're ready to create new projects quickly from this template!** 🚀
