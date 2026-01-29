# Remove Secrets Before Pushing to Template

GitHub's secret scanning will block pushes if it detects secrets in your code. Before pushing to a template repository, remove all secrets.

## Common Secrets to Remove

### 1. GitHub Personal Access Tokens
- Format: `ghp_xxxxxxxxxxxx`
- Found in: `scripts/create-env.ps1`
- Replace with: `YOUR_GITHUB_PERSONAL_ACCESS_TOKEN`

### 2. EC2 IP Addresses
- Format: IP addresses like `52.73.150.104`
- Found in: Scripts, documentation
- Replace with: `YOUR_EC2_IP_ADDRESS` or placeholders

### 3. API Keys
- App Store Connect API keys
- AWS keys
- Other service API keys
- Replace with: `YOUR_API_KEY` or placeholders

### 4. Passwords
- Database passwords
- Service passwords
- Replace with: `YOUR_PASSWORD` or placeholders

### 5. Private Keys
- `.pem` files (SSH keys)
- `.p8` files (App Store Connect keys)
- `.key` files
- Should be in `.gitignore` and not committed

## Files Already Updated

✅ **scripts/create-env.ps1** - GitHub token replaced
✅ **scripts/build-and-deploy-frontend.ps1** - EC2 IP replaced
✅ **scripts/check-deployment.ps1** - EC2 IP replaced
✅ **scripts/copy-to-ec2.ps1** - EC2 IP replaced
✅ **command-notes.txt** - IP and key path replaced
✅ **.gitignore** - Security keys added

## Check for Remaining Secrets

Before pushing, search for:

```powershell
# Search for GitHub tokens
grep -r "ghp_" .

# Search for IP addresses (your specific ones)
grep -r "52.73.150.104" .

# Search for common password patterns
grep -r "password123" .
```

## After Removing Secrets

1. **Commit changes**:
   ```powershell
   git add .
   git commit -m "Remove secrets and replace with placeholders"
   ```

2. **Try pushing again**:
   ```powershell
   git push -u template main
   ```

3. **If still blocked**, GitHub will show which file/line has the secret

## If GitHub Still Blocks

1. **Check the error message** - it will tell you which file and line
2. **Remove the secret** from that file
3. **Amend the commit** if it's in git history:
   ```powershell
   git commit --amend
   # Or use git filter-branch to remove from history
   ```

## Template Best Practices

- ✅ Use placeholders: `YOUR_API_KEY`, `YOUR_PASSWORD`, etc.
- ✅ Add secrets to `.gitignore`
- ✅ Document where to add secrets in README
- ✅ Use environment variables, not hardcoded values
- ✅ Never commit `.pem`, `.p8`, `.key` files

---

**All secrets should be removed before pushing to template repository!**
