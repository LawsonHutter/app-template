# Troubleshooting: "No Builds Available" in TestFlight

If you see "No Builds" or "0 Builds" in TestFlight despite building, follow these steps:

---

## Step 1: Check Codemagic Build Status

### 1.1 Go to Codemagic

1. Go to https://codemagic.io
2. Sign in
3. Click on your app
4. Look at the **latest build**

### 1.2 Check Build Status

**✅ Build Succeeded (Green Checkmark):**
- Build completed successfully
- **Next**: Go to Step 2

**❌ Build Failed (Red X):**
- Build did not complete
- **Action**: Click on the build to see error logs
- **Common issues**:
  - Code signing errors
  - API credentials missing/incorrect
  - Code errors (like the CardTheme error we just fixed)
- **Fix**: Resolve errors and rebuild

**🔄 Build In Progress:**
- Build is still running
- **Action**: Wait for it to complete (10-20 minutes)

**⏸️ Build Not Started:**
- No build has been triggered
- **Action**: Go to Step 5 (trigger a build)

---

## Step 2: Check Build Logs for Upload

Even if build succeeded, check if it uploaded to TestFlight:

### 2.1 Open Build Logs

1. In Codemagic, click on the **successful build**
2. Scroll down to find the **publishing** section
3. Look for **App Store Connect** or **TestFlight** upload messages

### 2.2 What to Look For

**✅ Success Messages:**
```
✓ Successfully uploaded to App Store Connect
✓ Build submitted to TestFlight
✓ Upload complete
```

**❌ Error Messages:**
```
✗ Failed to upload to App Store Connect
✗ Authentication failed
✗ App not found
✗ Invalid credentials
```

**If you see errors:**
- Check Step 3 (Verify API Credentials)
- Check Step 4 (Verify App Setup)

---

## Step 3: Verify App Store Connect API Credentials

### 3.1 Check Environment Variables in Codemagic

1. Go to Codemagic → Your app → **Settings** → **Environment variables**
2. Verify these 3 variables exist in group `app_store_credentials`:

   - `APP_STORE_CONNECT_ISSUER_ID`
   - `APP_STORE_CONNECT_KEY_IDENTIFIER`
   - `APP_STORE_CONNECT_PRIVATE_KEY`

### 3.2 Verify Values

**Issuer ID:**
- Format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` (UUID)
- Should match what you saved from App Store Connect

**Key ID:**
- Format: `XXXXXXXXXX` (alphanumeric, usually 10 characters)
- Should match what you saved from App Store Connect

**Private Key:**
- Must include **entire contents** of `.p8` file:
  ```
  -----BEGIN PRIVATE KEY-----
  [key content]
  -----END PRIVATE KEY-----
  ```
- **Common mistake**: Missing BEGIN/END lines or incomplete key

### 3.3 Test Credentials

If credentials are wrong, the build will fail with authentication errors. Check build logs for:
- "Authentication failed"
- "Invalid API key"
- "Unauthorized"

---

## Step 4: Verify App Setup in App Store Connect

### 4.1 Check App Exists

1. Go to https://appstoreconnect.apple.com
2. Click **My Apps**
3. Verify your app **"dipoll"** exists
4. Verify Bundle ID is `com.dipoll.surveyapp`

**If app doesn't exist:**
- Create it first (see Step 3 in DEPLOYMENT_STEPS.md)
- Then rebuild

### 4.2 Check Bundle ID Match

Verify Bundle ID matches in **all** places:

- ✅ **App Store Connect**: `com.dipoll.surveyapp`
- ✅ **Codemagic `codemagic.yaml`**: `APP_ID: "com.dipoll.surveyapp"`
- ✅ **iOS Project**: `com.dipoll.surveyapp`

**If Bundle IDs don't match:**
- Build will upload but won't appear in TestFlight
- Fix Bundle ID and rebuild

---

## Step 5: Check Where to Look for Builds

### 5.1 Correct Location in App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Click **My Apps** → **dipoll**
3. Click **TestFlight** tab
4. **Look at the TOP of the page** - there's a **"Builds"** section
5. **NOT** in the "Internal Testing" group (that's where you add builds AFTER they appear)

### 5.2 What You Should See

**If build exists:**
- Build number (e.g., "1.0.0 (1)")
- Status: "Processing" or "Ready to Test"
- Upload date/time

**If no build:**
- "No Builds" message
- Empty list

### 5.3 Common Mistake

❌ **Wrong**: Looking inside "Internal Testing" group for builds
✅ **Correct**: Looking at "Builds" section at top of TestFlight page

---

## Step 6: Wait for Processing

### 6.1 Build Processing Timeline

1. **Build completes in Codemagic**: 10-20 minutes
2. **Upload to App Store Connect**: 2-5 minutes
3. **Apple processing**: 10-60 minutes
4. **Total**: 20-85 minutes from build start

### 6.2 Build Statuses

**"Processing"**:
- ✅ Build uploaded successfully
- ⏳ Apple is checking your build
- 📧 You'll get an email when done
- **Action**: Wait 10-60 minutes

**"Ready to Test"**:
- ✅ Build is ready!
- ✅ Can now add to testing groups
- **Action**: Go to Step 7

**"Invalid" or "Failed"**:
- ❌ Build has issues
- **Action**: Check email from Apple for details
- **Common issues**: Missing compliance info, code signing issues

---

## Step 7: Check Email Notifications

### 7.1 Check Your Email

Apple sends emails for:
- ✅ Build uploaded successfully
- ✅ Build processing complete
- ❌ Build failed/invalid

**Check spam folder** if you don't see emails.

### 7.2 Email Settings

1. Go to App Store Connect → **Users and Access** → **Your Account**
2. Check notification preferences
3. Ensure email notifications are enabled

---

## Step 8: Verify Automatic Upload is Enabled

### 8.1 Check `codemagic.yaml`

Verify this section exists:
```yaml
publishing:
  app_store_connect:
    auth: integration
    submit_to_testflight: true  # ← This must be true
```

### 8.2 If `submit_to_testflight: false` or missing:

The build will succeed but won't upload automatically. You'd need to:
- Download `.ipa` from Codemagic artifacts
- Upload manually (requires Mac or alternative service)

**Fix**: Set `submit_to_testflight: true` and rebuild.

---

## Step 9: Manual Verification Checklist

Use this checklist to verify everything:

- [ ] Codemagic build shows **green checkmark** (succeeded)
- [ ] Build logs show **"Successfully uploaded to App Store Connect"**
- [ ] App exists in App Store Connect with Bundle ID `com.dipoll.surveyapp`
- [ ] All 3 API credentials are set in Codemagic environment variables
- [ ] Bundle ID matches in App Store Connect, Codemagic, and iOS project
- [ ] `submit_to_testflight: true` in `codemagic.yaml`
- [ ] Waiting at least 5-10 minutes after build completion
- [ ] Looking at **"Builds"** section (top of TestFlight page), not inside testing groups
- [ ] Checked email for Apple notifications
- [ ] Refreshed App Store Connect page

---

## Step 10: Still No Builds?

### 10.1 Try Manual Build Trigger

1. Go to Codemagic → Your app
2. Click **Start new build**
3. Select **iOS Workflow**
4. Select `main` branch
5. Click **Start new build**
6. Wait for completion
7. Check App Store Connect again

### 10.2 Check Build Artifacts

1. In Codemagic, open the successful build
2. Check **Artifacts** section
3. Look for `.ipa` file
4. **If `.ipa` exists**: Build succeeded, upload may have failed
5. **If no `.ipa`**: Build didn't complete properly

### 10.3 Contact Support

If everything checks out but still no builds:

1. **Codemagic Support**: Check build logs for specific errors
2. **Apple Developer Support**: If build uploaded but not appearing
3. **Check Apple System Status**: https://developer.apple.com/system-status/

---

## Quick Diagnostic Commands

### Check Latest Build in Codemagic

1. Go to https://codemagic.io → Your app
2. Look at build status and logs

### Check App Store Connect

1. Go to https://appstoreconnect.apple.com → My Apps → dipoll → TestFlight
2. Check "Builds" section at top

### Verify Bundle ID

Check these files:
- `codemagic.yaml`: `APP_ID: "com.dipoll.surveyapp"`
- App Store Connect: Bundle ID should be `com.dipoll.surveyapp`

---

## Most Common Issues

1. **Build failed** → Check build logs for errors
2. **Credentials wrong** → Verify API credentials in Codemagic
3. **App doesn't exist** → Create app in App Store Connect first
4. **Bundle ID mismatch** → Ensure all Bundle IDs match
5. **Looking in wrong place** → Check "Builds" section, not testing groups
6. **Not waiting long enough** → Wait 5-10 minutes after build completion
7. **Upload disabled** → Check `submit_to_testflight: true` in codemagic.yaml

---

**Still stuck?** Share:
1. Codemagic build status (succeeded/failed?)
2. What you see in App Store Connect TestFlight "Builds" section
3. Any error messages from build logs
