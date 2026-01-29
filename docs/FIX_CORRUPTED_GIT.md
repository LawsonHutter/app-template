# Fix Corrupted Git Repository

If you see "object file is empty" errors, your Git repository is corrupted. Here's how to fix it.

## Quick Fix: Remove Corrupted Object and Re-fetch

```bash
# Remove the corrupted object
rm .git/objects/41/12b5aa606de90f386e5f7e44e9b258c7eaf1a3

# Try to recover
git fsck --full

# Fetch from remote
git fetch origin

# Reset to remote
git reset --hard origin/main
```

## Alternative: Re-clone (Safest)

If the above doesn't work, re-clone the repository:

```bash
# Go to parent directory
cd ~

# Backup your .env file if it exists
cp survey-web-app/.env survey-web-app/.env.backup 2>/dev/null || true

# Remove old repository
rm -rf survey-web-app

# Clone fresh
git clone https://github.com/LawsonHutter/survey-web-app.git

# Restore .env file
cp survey-web-app/.env.backup survey-web-app/.env 2>/dev/null || true

# Go back into directory
cd survey-web-app
```

## If Using Personal Access Token

GitHub no longer accepts passwords. Use a Personal Access Token:

```bash
# Clone with token
git clone https://YOUR_TOKEN@github.com/LawsonHutter/survey-web-app.git
```

Or set up SSH keys for easier access.
