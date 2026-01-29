# How to Commit to Template Repository

## Current Setup

You have two remotes:
- **origin**: Your original `survey-web-app` repository
- **template**: Your new `app-template` repository

## Step 1: Stage All Changes

```powershell
# Add all changes (including new files and modifications)
git add -A

# Or add specific files
git add scripts/create-env.ps1
git add scripts/build-and-deploy-frontend.ps1
git add scripts/check-deployment.ps1
git add scripts/copy-to-ec2.ps1
git add command-notes.txt
git add .gitignore
git add docs/REMOVE_SECRETS.md
```

## Step 2: Commit Changes

```powershell
git commit -m "Convert to template: Remove secrets and replace with placeholders"
```

## Step 3: Push to Template Repository

```powershell
# Push to template repository
git push -u template main
```

**If GitHub still blocks due to secrets in history:**

You'll need to remove the secret from git history. The secret is in old commits, so you have a few options:

### Option A: Create Fresh Branch (Easiest)

```powershell
# Create a new branch without the problematic commits
git checkout --orphan template-clean
git add -A
git commit -m "Initial template version - all secrets removed"
git push -u template template-clean:main --force
```

### Option B: Use git filter-branch (Remove from History)

```powershell
# Remove the secret from all commits
git filter-branch --force --index-filter `
  "git rm --cached --ignore-unmatch scripts/create-env.ps1" `
  --prune-empty --tag-name-filter cat -- --all

# Force push
git push -u template main --force
```

### Option C: Allow the Secret (Not Recommended)

If it's a token you've already revoked, you can allow it:
- Go to the URL GitHub provided in the error
- Click "Allow secret" (only if token is revoked!)

## Step 4: Verify Push

```powershell
# Check remote branches
git ls-remote template

# Verify template repository on GitHub
# Go to: https://github.com/LawsonHutter/app-template
```

## Quick Commands

**Full workflow:**
```powershell
# 1. Stage all changes
git add -A

# 2. Commit
git commit -m "Convert to template: Remove secrets and replace with placeholders"

# 3. Push to template
git push -u template main
```

**If blocked by secrets:**
```powershell
# Create clean branch
git checkout --orphan template-clean
git add -A
git commit -m "Initial template version"
git push -u template template-clean:main --force
```

---

**Ready to commit?** Run the commands above!
