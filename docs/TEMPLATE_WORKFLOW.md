# Template Workflow: From Template to Production

This guide walks through the complete workflow from template to production deployment.

---

## Phase 1: Convert Current Project to Template

### Step 1: Prepare Current Project

1. **Ensure everything works**:
   - Test local development
   - Verify deployments work
   - Check all documentation is accurate

2. **Clean up**:
   ```powershell
   # Remove sensitive files
   Remove-Item security\*.pem -ErrorAction SilentlyContinue
   
   # Remove test databases (optional)
   Remove-Item backend\db.sqlite3 -ErrorAction SilentlyContinue
   ```

3. **Review project-specific references**:
   - Search for "dipoll" across codebase
   - Search for domain references
   - Check for hardcoded API keys

### Step 2: Run Conversion Script

```powershell
.\scripts\convert-to-template.ps1
```

**What it replaces:**
- `dipoll.net` → `yourdomain.com`
- `com.dipoll.surveyapp` → `com.yourdomain.yourapp`
- `dipoll` → `your-app-name`
- API keys → placeholders
- Team IDs → placeholders

### Step 3: Review and Commit

```powershell
# Review changes
git diff

# Commit template version
git add .
git commit -m "Convert to template - replace project-specific values"
```

### Step 4: Create Template Repository

1. **Create new GitHub repo**: `flutter-django-template`
2. **Push template**:
   ```powershell
   git remote add template https://github.com/yourusername/flutter-django-template.git
   git push -u template main
   ```
3. **Mark as template** (Settings → Template repository)

---

## Phase 2: Create New Project (dipoll) from Template

### Step 1: Create Repository from Template

**Option A: GitHub Template Button**
1. Go to template repository
2. Click **"Use this template"** → **"Create a new repository"**
3. Name: `dipoll`
4. Create repository

**Option B: Clone**
```powershell
git clone https://github.com/yourusername/flutter-django-template.git dipoll
cd dipoll
Remove-Item -Recurse -Force .git
git init
git branch -M main
```

### Step 2: Run Setup Script

```powershell
.\scripts\setup-from-template.ps1 `
  -ProjectName "dipoll" `
  -Domain "dipoll.net" `
  -BundleId "com.dipoll.surveyapp" `
  -AppName "Dipoll Survey App"
```

### Step 3: Set Up App Store Connect

1. **Create API Key**:
   - App Store Connect → Users and Access → Keys
   - Create new key
   - Save: Issuer ID, Key ID, Private Key

2. **Update `codemagic.yaml`**:
   - Replace `YOUR_ISSUER_ID`
   - Replace `YOUR_KEY_ID`
   - Replace `YOUR_TEAM_ID`

3. **Create App**:
   - App Store Connect → My Apps → New App
   - Bundle ID: `com.dipoll.surveyapp`
   - Name: `dipoll`

### Step 4: Set Up Codemagic

1. **Connect repository**:
   - Codemagic → Add application
   - Connect `dipoll` repository
   - Select Flutter project

2. **Add environment variables**:
   - Group: `app_store_credentials`
   - Variables:
     - `APP_STORE_CONNECT_ISSUER_ID`
     - `APP_STORE_CONNECT_KEY_IDENTIFIER`
     - `APP_STORE_CONNECT_PRIVATE_KEY`

3. **Enable automatic builds**:
   - Settings → Build triggers
   - Enable "Start builds automatically"

### Step 5: Set Up AWS/EC2

1. **Launch EC2 instance**:
   - See `docs/AWS_EC2_LAUNCH_GUIDE.md`
   - Ubuntu 22.04 LTS
   - t2.micro or t3.micro

2. **Configure domain**:
   - Point DNS to EC2 IP
   - See `docs/CUSTOM_DOMAIN_QUICK_START.md`

3. **Deploy**:
   - Follow `docs/DEPLOY_TO_PRODUCTION.md`
   - Or use deployment scripts

### Step 6: Test and Deploy

1. **Test locally**:
   ```powershell
   .\scripts\start-all-local-sqlite.ps1
   ```

2. **Initial commit**:
   ```powershell
   git add .
   git commit -m "Initial dipoll project setup"
   git remote add origin https://github.com/yourusername/dipoll.git
   git push -u origin main
   ```

3. **Trigger first build**:
   - Codemagic should auto-build on push
   - Or trigger manually

4. **Deploy to EC2**:
   - Follow deployment guide
   - Verify domain works

---

## Phase 3: Verify Everything Works

### Checklist

- [ ] Local development works
- [ ] Backend API accessible at `https://dipoll.net/api/`
- [ ] Frontend loads at `https://dipoll.net`
- [ ] Codemagic builds successfully
- [ ] Build uploads to App Store Connect
- [ ] Build appears in TestFlight
- [ ] Can install app on device
- [ ] App connects to backend API

---

## Quick Reference

### Convert to Template
```powershell
.\scripts\convert-to-template.ps1
```

### Create New Project
```powershell
.\scripts\setup-from-template.ps1 `
  -ProjectName "project-name" `
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

1. **Customize**: Backend models, frontend UI
2. **Deploy**: Follow deployment guides
3. **Iterate**: Make changes, push, auto-deploy

---

**You now have a working template and a new project ready to go!** 🚀
