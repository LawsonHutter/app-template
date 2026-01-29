# Fix: Builds Not Triggering on Git Push

## Problem

You push code to GitHub, but Codemagic doesn't automatically start a build.

## Common Causes & Fixes

### 1. Workflow Not Enabled in Codemagic UI ⭐ Most Common

Even if `codemagic.yaml` has `triggering` configured, you need to enable it in Codemagic UI.

**Fix:**

1. Go to https://codemagic.io → Your app
2. Click **Settings** → **Build triggers** (or **Workflows**)
3. Find **"iOS Workflow"** (or your workflow name)
4. **Enable automatic builds**:
   - Toggle **"Start builds automatically"** to ON
   - Or check **"Enable automatic builds"** checkbox
5. Save settings

**Alternative path:**
- Go to **Workflows** tab
- Click on **"iOS Workflow"**
- Enable **"Automatic builds"** toggle

---

### 2. Repository Not Connected

Codemagic needs access to your GitHub repository.

**Check:**

1. Go to Codemagic → Your app → **Settings** → **Repository**
2. Verify repository is connected
3. Check if GitHub integration is authorized

**Fix:**

1. Go to **Settings** → **Repository**
2. If not connected, click **"Connect repository"**
3. Authorize Codemagic to access GitHub
4. Select your repository: `survey-web-app`
5. Save

---

### 3. Wrong Branch Name

The workflow triggers on `main` branch. If you're pushing to a different branch, it won't trigger.

**Check:**

```powershell
# Check current branch
git branch

# Check what branch you're pushing to
git push origin <branch-name>
```

**Fix:**

- Push to `main` branch:
  ```powershell
  git push origin main
  ```

- Or update `codemagic.yaml` to trigger on your branch:
  ```yaml
  branch_patterns:
    - pattern: your-branch-name
      include: true
      source: true
  ```

---

### 4. Path Filters Too Restrictive

The workflow only triggers when `frontend/**` or `codemagic.yaml` changes. If you only changed other files, it won't trigger.

**Check `codemagic.yaml`:**
```yaml
paths:
  - frontend/**
  - codemagic.yaml
```

**Fix:**

- Make a change to `frontend/` or `codemagic.yaml`:
  ```powershell
  # Touch a file in frontend to trigger build
  git commit --allow-empty -m "Trigger build"
  git push origin main
  ```

- Or remove path filters (triggers on any change):
  ```yaml
  triggering:
    events:
      - push
    branch_patterns:
      - pattern: main
        include: true
        source: true
    # Remove or comment out paths section
    # paths:
    #   - frontend/**
    #   - codemagic.yaml
  ```

---

### 5. Workflow Not Selected/Active

Codemagic might have multiple workflows, and the iOS workflow might not be the active one.

**Check:**

1. Go to Codemagic → Your app
2. Check **Workflows** tab
3. Verify **"iOS Workflow"** exists and is enabled

**Fix:**

1. If workflow doesn't exist, Codemagic should auto-detect `codemagic.yaml`
2. If it exists but is disabled, enable it
3. Make sure it's the **active** workflow

---

### 6. GitHub Webhook Not Set Up

Codemagic needs a webhook from GitHub to know when you push.

**Check:**

1. Go to GitHub → Your repository → **Settings** → **Webhooks**
2. Look for Codemagic webhook
3. Check if it's active and recent deliveries

**Fix:**

- Usually Codemagic sets this up automatically when you connect the repository
- If missing, reconnect repository in Codemagic
- Or manually add webhook (not recommended, let Codemagic handle it)

---

### 7. Codemagic YAML Not in Root

The `codemagic.yaml` file must be in the repository root.

**Check:**

```powershell
# Verify codemagic.yaml is in root
ls codemagic.yaml
```

**Fix:**

- Move `codemagic.yaml` to repository root if it's elsewhere
- Commit and push:
  ```powershell
  git add codemagic.yaml
  git commit -m "Move codemagic.yaml to root"
  git push origin main
  ```

---

## Step-by-Step Diagnostic

### Step 1: Verify Workflow is Enabled

1. Go to https://codemagic.io → Your app
2. **Settings** → **Build triggers** (or **Workflows**)
3. ✅ **Enable automatic builds** for iOS Workflow
4. Save

### Step 2: Verify Repository Connection

1. **Settings** → **Repository**
2. ✅ Verify repository is connected
3. ✅ Verify GitHub integration is authorized

### Step 3: Test with Empty Commit

```powershell
# Make an empty commit to test
git commit --allow-empty -m "Test build trigger"
git push origin main
```

### Step 4: Check Codemagic

1. Go to Codemagic → Your app
2. Check if build appears in build list
3. If not, check **Settings** → **Build triggers** again

### Step 5: Check Branch

```powershell
# Verify you're on main branch
git branch

# If not, switch to main
git checkout main
git push origin main
```

---

## Quick Fix Checklist

- [ ] Workflow enabled in Codemagic UI (Settings → Build triggers)
- [ ] Repository connected in Codemagic
- [ ] Pushing to `main` branch (or branch configured in YAML)
- [ ] `codemagic.yaml` is in repository root
- [ ] Changed files match path filters (or removed path filters)
- [ ] GitHub webhook is active (usually automatic)
- [ ] Codemagic has access to your GitHub account

---

## Manual Build (Workaround)

If automatic builds still don't work, trigger manually:

1. Go to Codemagic → Your app
2. Click **Start new build**
3. Select **iOS Workflow**
4. Select `main` branch
5. Click **Start new build**

**Note**: This is a workaround. Automatic builds should work once configured correctly.

---

## Verify Configuration

Your `codemagic.yaml` should have:

```yaml
triggering:
  events:
    - push
  branch_patterns:
    - pattern: main
      include: true
      source: true
  paths:
    - frontend/**
    - codemagic.yaml
```

**If you want to trigger on ANY file change**, remove the `paths` section:

```yaml
triggering:
  events:
    - push
  branch_patterns:
    - pattern: main
      include: true
      source: true
  # No paths = triggers on any change
```

---

## Most Common Fix

**90% of the time**, the issue is:

1. ✅ Go to Codemagic → Your app → **Settings** → **Build triggers**
2. ✅ Enable **"Start builds automatically"** for iOS Workflow
3. ✅ Save
4. ✅ Push again

The `codemagic.yaml` configuration is correct, but Codemagic UI also needs the workflow enabled!

---

## Still Not Working?

1. **Check Codemagic Status**: https://status.codemagic.io
2. **Check Build Logs**: Look for any error messages
3. **Contact Codemagic Support**: With your app name and repository URL
4. **Verify GitHub Integration**: Reconnect repository if needed

---

**Quick Test:**

```powershell
# Make a test commit
git commit --allow-empty -m "Test Codemagic build trigger"
git push origin main

# Then check Codemagic immediately
# Build should appear within 1-2 minutes
```
