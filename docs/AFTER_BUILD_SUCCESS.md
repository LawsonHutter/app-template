# What to Do After a Successful Codemagic Build

This guide explains what to do after your iOS build succeeds in Codemagic.

## ✅ Build Succeeded - Now What?

### Step 1: Check Build Artifacts

1. Go to your build in Codemagic
2. Click on the **Artifacts** tab
3. You should see:
   - `*.ipa` file (iOS app package)

### Step 2: Upload to TestFlight

**🎉 Automatic Upload is Now Enabled!** (No Mac Required)

The `codemagic.yaml` is configured with `submit_to_testflight: true`, so uploads happen automatically.

#### Option A: Automatic Upload (Recommended - No Mac Needed) ✅

**This is already enabled!** Just make sure you have:

1. **App Store Connect API credentials** configured in Codemagic:
   - `APP_STORE_CONNECT_ISSUER_ID`
   - `APP_STORE_CONNECT_KEY_IDENTIFIER`
   - `APP_STORE_CONNECT_PRIVATE_KEY`

2. **Code signing** configured in Codemagic

Then:
1. ✅ **Upload happens automatically** during build (no action needed!)
2. Go to [App Store Connect](https://appstoreconnect.apple.com)
3. Navigate to **My Apps** → Your App → **TestFlight** tab
4. Wait for processing (10-60 minutes)
5. Once you see your build, proceed to Step 3

#### Option B: Manual Upload via App Store Connect Website (No Mac Required)

If automatic upload isn't working:

1. Download the `.ipa` file from Codemagic artifacts
2. Go to [App Store Connect](https://appstoreconnect.apple.com)
3. Navigate to **My Apps** → Your App → **TestFlight** tab
4. Click **+** → **Upload Build**
5. Select your downloaded `.ipa` file
6. Wait for processing (10-60 minutes)

**See `docs/UPLOAD_WITHOUT_MAC.md` for detailed instructions.**

### Step 3: Add Testers

Once your build is processed in TestFlight:

1. Go to **TestFlight** tab in App Store Connect
2. Click **+** next to **Internal Testing** or **External Testing**
3. Select your build
4. Fill in **What to Test** notes (describe what testers should focus on)
5. Click **Submit for Review** (required for External Testing)

#### Internal Testing (Instant)

- Up to **100 team members**
- No App Review required
- Testers get access immediately after you add them
- Add testers: **TestFlight** → **Internal Testing** → **Add Testers**

#### External Testing (Requires Review)

- Up to **10,000 testers**
- Requires App Review (usually 24-48 hours)
- Testers need to accept email invitation
- Add testers: **TestFlight** → **External Testing** → **Add Testers**

### Step 4: Invite Testers

1. Go to **TestFlight** → **Internal Testing** (or **External Testing**)
2. Click **Add Testers** or **Manage Testers**
3. Add testers by:
   - **Email addresses**: Enter email addresses
   - **Public Link**: Create a public link (External Testing only)
4. Testers will receive an email invitation
5. They need to:
   - Install **TestFlight** app from App Store
   - Accept the invitation
   - Install your app from TestFlight

## 🔄 Automatic Builds

### How Automatic Builds Work

When you push to `main` branch with changes to `frontend/`:

1. Codemagic **automatically starts a build**
2. Build completes (10-20 minutes)
3. If auto-upload enabled, uploads to TestFlight automatically
4. You get an email notification (if configured)

### Enable Automatic Upload to TestFlight

Edit `codemagic.yaml`:

```yaml
app_store_connect:
  auth: integration
  submit_to_testflight: true  # Uncomment this line
  # beta_groups:  # Optional: specify beta groups
  #   - Internal Testing
```

Then commit and push:
```bash
git add codemagic.yaml
git commit -m "Enable automatic TestFlight upload"
git push origin main
```

## 📧 Email Notifications

Update your email in `codemagic.yaml`:

```yaml
publishing:
  email:
    recipients:
      - your-email@example.com  # Update this
    notify:
      success: true
      failure: true
```

## 🎯 Quick Checklist

After a successful build:

- [ ] Check build artifacts in Codemagic
- [ ] Download `.ipa` (if manual upload) OR wait for auto-upload
- [ ] Go to App Store Connect → TestFlight
- [ ] Wait for build processing (10-60 minutes)
- [ ] Add build to Internal/External Testing
- [ ] Fill in "What to Test" notes
- [ ] Submit for review (External Testing only)
- [ ] Add testers
- [ ] Testers install TestFlight and accept invitation
- [ ] Test your app!

## 🐛 Troubleshooting

### Build Succeeded but No Upload

- Check if `submit_to_testflight: true` is enabled
- Verify App Store Connect API credentials are correct
- Check build logs for upload errors

### Build Not Processing in TestFlight

- Wait longer (can take up to 60 minutes)
- Check App Store Connect for error messages
- Verify Bundle ID matches in Codemagic and App Store Connect

### Testers Can't Install

- Ensure they have TestFlight app installed
- Check they accepted the email invitation
- Verify the build is in "Ready to Test" status
- For External Testing, ensure review is approved

## 📚 Resources

- [App Store Connect](https://appstoreconnect.apple.com)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [Codemagic Build Status](https://codemagic.io/apps)
