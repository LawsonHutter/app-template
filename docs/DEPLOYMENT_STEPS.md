# TestFlight Deployment Steps - Quick Guide (Windows)

> **Note**: This guide is adapted for Windows users. All steps can be completed from Windows - you don't need a Mac!

## 🚀 Quick Start Checklist

Follow these steps in order:

**Prerequisites:**
- ✅ Windows PC (you're on Windows!)
- ✅ Git installed (for pushing code)
- ✅ PowerShell or Git Bash (comes with Git)
- ✅ Text editor (Notepad, VS Code, or any editor)
- ✅ Apple Developer Account ($99/year)

**Windows-Specific Notes:**
- All web-based steps (App Store Connect, Codemagic) work the same on Windows
- Git commands work in PowerShell or Git Bash
- Use Notepad or VS Code to open `.p8` files
- You'll need an iPhone/iPad to test the app (iOS apps don't run on Windows)

---

## Step 1: Create App Store Connect API Key (5 min)

1. Go to https://appstoreconnect.apple.com → **Users and Access** → **Keys** tab
2. Click **+** → Name: `Codemagic CI/CD` → **Generate**
3. **Download `.p8` file immediately** (only available once!)
   - **Windows**: File will download to your `Downloads` folder
   - Save it somewhere safe (e.g., `C:\Users\YourName\Documents\codemagic-key.p8`)
4. **Save these 3 values:**
   - **Issuer ID**: (shown at top of Keys page)
   - **Key ID**: (shown on key page)
   - **Private Key**: (contents of `.p8` file - see Step 4.1 for how to open it on Windows)

---

## Step 2: Register Bundle ID (5 min)

1. Go to https://developer.apple.com/account/resources/identifiers/list
2. Click **+** → **App IDs** → **Continue** → **App** → **Continue**
3. Fill in:
   - **Description**: `Your App Name`
   - **Bundle ID**: **Explicit** → `com.your-app-name.surveyapp`
4. Click **Continue** → **Register**

✅ **Your Bundle ID**: `com.your-app-name.surveyapp` (already configured in your code)

---

## Step 3: Create App in App Store Connect (3 min)

1. Go to https://appstoreconnect.apple.com → **My Apps** → **+** → **New App**
2. Fill in:
   - **Platform**: iOS
   - **Name**: `Your App Name` (or your name)
   - **Primary Language**: English
   - **Bundle ID**: Select `com.your-app-name.surveyapp` (from dropdown)
   - **SKU**: `survey-app-001`
   - **User Access**: Full Access
3. Click **Create**

---

## Step 4: Configure Codemagic (10 min)

### 4.1 Add Environment Variables

1. Go to https://codemagic.io → Your app → **Settings** → **Environment variables**
2. Add these 3 variables (all in group `app_store_credentials`):

   **Variable 1:**
   - Name: `APP_STORE_CONNECT_ISSUER_ID`
   - Value: Your Issuer ID (from Step 1)
   - Group: `app_store_credentials`

   **Variable 2:**
   - Name: `APP_STORE_CONNECT_KEY_IDENTIFIER`
   - Value: Your Key ID (from Step 1)
   - Group: `app_store_credentials`

   **Variable 3:**
   - Name: `APP_STORE_CONNECT_PRIVATE_KEY`
   - Value: Open `.p8` file on Windows:
     - **Option 1**: Right-click `.p8` file → **Open with** → **Notepad**
     - **Option 2**: Open in VS Code or any text editor
     - Copy **entire contents** (including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`)
     - Paste into Codemagic variable value
   - Group: `app_store_credentials`

### 4.2 Configure Code Signing

**Important**: For TestFlight, you need **App Store Distribution** profiles (not Development).

1. Go to **Settings** → **Code signing**
2. Click **Add certificate**
3. Select **Automatic code signing**
4. Enter Bundle ID: `com.your-app-name.surveyapp`
5. **Profile Type**: Select **App Store** (for TestFlight distribution)
6. Codemagic handles the rest automatically

**Note**: The `codemagic.yaml` file is already configured to use `IOS_APP_STORE` profile type for TestFlight distribution.

### 4.3 Update Email (Optional)

Edit `codemagic.yaml` in your project root:

**Windows (PowerShell or VS Code):**
1. Open `codemagic.yaml` in VS Code or Notepad
2. Find the `publishing` section
3. Update the email:
   ```yaml
   publishing:
     email:
       recipients:
         - your-email@example.com  # Your actual email
   ```
4. Save the file

---

## Step 5: Build and Deploy (Automatic!)

### Option A: Automatic Build (Recommended)

**⚠️ Important**: Enable automatic builds in Codemagic UI first!
1. Go to Codemagic → Your app → **Settings** → **Build triggers**
2. Enable **"Start builds automatically"** for iOS Workflow
3. Save

**Windows (PowerShell or Command Prompt):**

Open PowerShell or Git Bash in your project folder:
```powershell
# Navigate to project (if not already there)
cd C:\Users\Lawson\Desktop\Github\survey-web-app

# Stage all changes
git add .

# Commit changes
git commit -m "Ready for TestFlight"

# Push to main branch
git push origin main
```

**Or use Git Bash:**
```bash
git add .
git commit -m "Ready for TestFlight"
git push origin main
```

Codemagic automatically:
- ✅ Detects the push
- ✅ Starts building
- ✅ Uploads to TestFlight

**If build doesn't trigger**: See `docs/FIX_BUILD_TRIGGERS.md` for troubleshooting

### Option B: Manual Build

1. Go to https://codemagic.io → Your app
2. Click **Start new build**
3. Select **iOS Workflow** → `main` branch
4. Click **Start new build**

**Build time**: 10-20 minutes

**After build completes:**
- ✅ Check build status in Codemagic (should show green checkmark)
- ✅ **Check build logs** - Look for "Successfully uploaded to App Store Connect" or "Uploading to App Store Connect" in the **Publishing** section
  - ✅ **If you see upload message**: Upload worked, wait 5-10 minutes
  - ❌ **If no upload message**: Upload failed - check API credentials (see `docs/FIX_TESTFLIGHT_UPLOAD.md`)
- ✅ Wait 5-10 minutes for upload to App Store Connect
- ✅ Go to App Store Connect → TestFlight tab → Check **Builds** section (top of page)
- ✅ Build will show as "Processing" → Wait for "Ready to Test"

---

## Step 6: Add Build to TestFlight (5 min)

### 6.1 Check if Build Was Uploaded

**First, verify a build exists:**

1. Go to https://appstoreconnect.apple.com → **My Apps** → Your app → **TestFlight** tab
2. Look at the **Builds** section (top of page, not in Internal Testing group)
3. You should see:
   - **If build exists**: Build number (e.g., "1.0.0 (1)") with status
   - **If no build**: "No Builds" message

**If you see "No Builds":**
- ✅ Check Codemagic - did the build complete successfully?
- ✅ Go to Codemagic → Your app → Check latest build status
- ✅ If build failed, check logs for errors
- ✅ If build succeeded, wait 5-10 minutes for upload to complete
- ✅ Refresh App Store Connect page

### 6.2 Wait for Processing

Once a build appears in the **Builds** section:

1. Build status will show:
   - **Processing** (10-60 minutes) - Apple is processing your build
   - **Ready to Test** - Build is ready to add to testing!
2. You'll get an email when processing is complete
3. Refresh the page to see updated status

### 6.3 Add to Internal Testing

**Only after build shows "Ready to Test":**

1. In **TestFlight** tab, scroll down to **Internal Testing** section
2. Click **+** next to **Internal Testing** (or click the group name)
3. You'll see a list of available builds
4. Select your processed build (status: "Ready to Test")
5. Fill in **What to Test**: `Initial TestFlight release`
6. Click **Add Build to Internal Testing**

**Note**: The "+" button or "Add Build" option only appears when:
- ✅ You have at least one build uploaded
- ✅ The build status is "Ready to Test" (not "Processing")

### 6.3 Add Testers

1. In **Internal Testing** section, click **Add Testers**
2. Enter email addresses (up to 100)
3. Click **Add**
4. Testers receive email invitations

---

## Step 7: Test Your App

**On your iPhone/iPad:**
1. Install **TestFlight** app from App Store (if not already installed)
2. Check email for invitation (on your phone or computer)
3. Open invitation link on your iPhone/iPad, or open TestFlight app
4. Accept invitation in TestFlight
5. Install your app from TestFlight
6. Test! 🎉

**Note**: You need an iOS device (iPhone/iPad) to test. Windows doesn't run iOS apps.

---

## 🔄 Future Deployments

**Automatic!** Just push to `main`:

**Windows (PowerShell):**
```powershell
git push origin main
```

**Or Git Bash:**
```bash
git push origin main
```

Codemagic automatically:
- Builds your app
- Uploads to TestFlight
- New build appears in TestFlight

Then:
1. Go to TestFlight tab
2. Add new build to Internal Testing
3. Testers get notified automatically

---

## ⚠️ Troubleshooting

### ❌ "No Builds" or "0 Builds" in TestFlight

**This means no build has been uploaded yet. Here's what to do:**

1. **Check Codemagic Build Status:**
   - Go to https://codemagic.io → Your app
   - Look at the latest build
   - ✅ **Green checkmark** = Build succeeded, wait 5-10 min for upload
   - ❌ **Red X** = Build failed, check logs

2. **If Build Succeeded:**
   - Wait 5-10 minutes
   - Refresh App Store Connect TestFlight page
   - Build should appear in **Builds** section (top of page, not in testing groups)

3. **If Build Failed:**
   - Check build logs in Codemagic
   - Common issues:
     - Missing API credentials (Step 4.1)
     - Code signing errors (Step 4.2)
     - Bundle ID mismatch

4. **If You Haven't Built Yet:**
   - Complete Step 5 (Build and Deploy)
   - Push code to trigger automatic build, or start manual build

**📖 Detailed troubleshooting**: See `docs/TROUBLESHOOT_NO_BUILDS.md` for comprehensive guide

---

### Build Fails: "Authentication failed"
- ✅ Check API credentials are correct
- ✅ Verify `.p8` key includes full content (BEGIN/END lines)
  - **Windows**: Make sure you copied the entire file including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`
  - Open `.p8` file in Notepad to verify
- ✅ Ensure Key ID and Issuer ID match

### Build Fails: "App not found"
- ✅ Create app in App Store Connect first (Step 3)
- ✅ Verify Bundle ID matches: `com.your-app-name.surveyapp`

### Build Fails: "Code signing failed" or "Cannot create profile: the request does not include any iOS testing devices"

**Error message**: `Cannot create profile: the request does not include any iOS testing devices while they are required for creating a IOS_APP_DEVELOPMENT profile`

**Solution**:
- ✅ This happens when Codemagic tries to create a **Development** profile instead of **App Store Distribution**
- ✅ **Fixed in `codemagic.yaml`**: Already configured to use `IOS_APP_STORE` profile type
- ✅ **In Codemagic UI**: Make sure code signing is set to **App Store** (not Development)
- ✅ **Verify**: Check that `codemagic.yaml` has `--type IOS_APP_STORE` in the code signing step
- ✅ Push the updated `codemagic.yaml` and rebuild

**If still failing**:
- ✅ Verify Apple Developer account is active
- ✅ Check that Bundle ID `com.your-app-name.surveyapp` is registered in Apple Developer
- ✅ Ensure App Store Connect API credentials are correct

### Build Not Showing in TestFlight

**If you see "No Builds" or "0 Builds":**
- ✅ **Check Codemagic first**: Did the build complete successfully?
  - Go to https://codemagic.io → Your app → Check build status
  - Look for green checkmark or error message
- ✅ **If build failed**: Check build logs for errors (usually API credentials or code signing)
- ✅ **If build succeeded**: Wait 5-10 minutes for upload to App Store Connect
- ✅ **Refresh App Store Connect**: The build may take a few minutes to appear
- ✅ **Check email**: You'll get notifications from Apple about build status

**If build shows "Processing":**
- ✅ This is normal! Wait 10-60 minutes
- ✅ Apple is checking your build, generating symbols, etc.
- ✅ You'll get an email when it's ready
- ✅ Status will change to "Ready to Test"

**If build shows "Ready to Test" but can't add to testing:**
- ✅ Make sure you're clicking the **+** button next to "Internal Testing" (not in the group itself)
- ✅ Try clicking the group name "Initial Testflight Release" to open it
- ✅ Verify Bundle ID matches everywhere

---

## 📋 Quick Reference

### Your Configuration
- **Bundle ID**: `com.your-app-name.surveyapp`
- **Domain**: `your-app-name.net`
- **API URL**: `https://your-app-name.net/api/counter/`

### Important URLs
- **App Store Connect**: https://appstoreconnect.apple.com
- **Codemagic**: https://codemagic.io
- **Apple Developer**: https://developer.apple.com

### Required Codemagic Variables
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_KEY_IDENTIFIER`
- `APP_STORE_CONNECT_PRIVATE_KEY`

---

## ✅ Final Checklist

- [ ] Created App Store Connect API Key
- [ ] Registered Bundle ID: `com.your-app-name.surveyapp`
- [ ] Created app in App Store Connect
- [ ] Added 3 API credentials to Codemagic
- [ ] Configured code signing in Codemagic
- [ ] Updated email in `codemagic.yaml` (optional)
- [ ] Pushed code or triggered manual build
- [ ] Build completed successfully
- [ ] Build processed in TestFlight
- [ ] Added build to Internal Testing
- [ ] Added testers
- [ ] App installed and tested!

---

**That's it! 🚀**

Your app will now automatically deploy to TestFlight on every push to `main` branch.
