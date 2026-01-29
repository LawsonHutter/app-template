# Deploy to TestFlight - Complete Guide

This guide walks you through deploying your iOS app to TestFlight using Codemagic.

## ✅ Prerequisites Checklist

- [x] Apple Developer Account ($99/year) - **You have this!**
- [ ] App Store Connect API Key created
- [ ] App created in App Store Connect
- [ ] Codemagic account set up
- [ ] Repository connected to Codemagic

---

## Step 1: Create App Store Connect API Key

This allows Codemagic to automatically upload your app to TestFlight.

### 1.1 Go to App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Sign in with your Apple Developer account
3. Click **Users and Access** in the top menu

### 1.2 Create API Key

1. Click the **Keys** tab
2. Click the **+** button (or "Generate API Key")
3. Fill in:
   - **Name**: `Codemagic CI/CD` (or any name you prefer)
   - **Access**: Select **App Manager** or **Admin** role
4. Click **Generate**
5. **Important**: Download the `.p8` key file immediately (you can only download it once!)
6. Note the **Key ID** (shown on the page, format: `XXXXXXXXXX`)
7. Note the **Issuer ID** (shown at the top of the Keys page, format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)

### 1.3 Save Your Credentials

You'll need these three values:
- **Issuer ID**: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
- **Key ID**: `XXXXXXXXXX`
- **Private Key**: Contents of the `.p8` file (starts with `-----BEGIN PRIVATE KEY-----`)

---

## Step 2: Create App in App Store Connect

Before you can upload builds, you need to create the app in App Store Connect.

### 2.1 Create New App

1. Go to https://appstoreconnect.apple.com
2. Click **My Apps**
3. Click the **+** button → **New App**

### 2.2 Fill in App Details

1. **Platform**: Select **iOS**
2. **Name**: Enter your app name (e.g., "Your App Name")
3. **Primary Language**: Select **English** (or your preferred language)
4. **Bundle ID**: 
   - If you already have one, select it from the dropdown
   - If not, click **Register a new Bundle ID** (see Step 2.3)
5. **SKU**: Enter a unique identifier (e.g., `survey-app-001`)
   - This is for your internal tracking, can be anything unique
6. **User Access**: Select **Full Access**
7. Click **Create**

### 2.3 Register Bundle ID (If Needed)

If you need to create a new Bundle ID:

1. Go to https://developer.apple.com/account/resources/identifiers/list
2. Click the **+** button
3. Select **App IDs** → **Continue**
4. Select **App** → **Continue**
5. Fill in:
   - **Description**: Your app name
   - **Bundle ID**: 
     - **Explicit**: `com.yourdomain.yourapp` (recommended)
     - Or **Wildcard**: `com.yourdomain.*` (less specific)
6. Click **Continue** → **Register**
7. Go back to App Store Connect and select this Bundle ID

### 2.4 Update Your Bundle ID in Code

Make sure your Bundle ID matches everywhere:

1. **Update `codemagic.yaml`**:
   ```yaml
   vars:
     APP_ID: "com.yourdomain.yourapp"  # Match your App Store Connect Bundle ID
   ```

2. **Update iOS project** (if needed):
   - The Bundle ID should already be set when you initialized the iOS project
   - Verify in `frontend/ios/Runner.xcodeproj` or via Xcode

---

## Step 3: Set Up Codemagic

### 3.1 Connect Repository (If Not Done)

1. Go to https://codemagic.io
2. Click **Add application** (or go to your existing app)
3. Select **GitHub** and authorize Codemagic
4. Choose your `survey-web-app` repository
5. Select **Flutter** as the project type

### 3.2 Configure App Store Connect API Credentials

1. In Codemagic, go to your app → **Settings** → **Environment variables**
2. Click **Add variable** for each of these:

   **Variable 1: APP_STORE_CONNECT_ISSUER_ID**
   - **Name**: `APP_STORE_CONNECT_ISSUER_ID`
   - **Value**: Your Issuer ID (from Step 1.2)
   - **Group**: Create or select `app_store_credentials`
   - Click **Add**

   **Variable 2: APP_STORE_CONNECT_KEY_IDENTIFIER**
   - **Name**: `APP_STORE_CONNECT_KEY_IDENTIFIER`
   - **Value**: Your Key ID (from Step 1.2)
   - **Group**: `app_store_credentials`
   - Click **Add**

   **Variable 3: APP_STORE_CONNECT_PRIVATE_KEY**
   - **Name**: `APP_STORE_CONNECT_PRIVATE_KEY`
   - **Value**: Open your `.p8` file in a text editor and copy the **entire contents**:
     ```
     -----BEGIN PRIVATE KEY-----
     MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg...
     ... (entire key content) ...
     -----END PRIVATE KEY-----
     ```
   - **Group**: `app_store_credentials`
   - Click **Add**

### 3.3 Configure Code Signing

1. Go to your app → **Settings** → **Code signing**
2. Click **Add certificate**
3. Select **Automatic code signing** (Recommended)
4. Enter your **Bundle ID** (e.g., `com.yourdomain.yourapp`)
5. Codemagic will automatically:
   - Create certificates
   - Generate provisioning profiles
   - Manage everything for you

**Alternative: Manual Code Signing**
- If automatic doesn't work, you can upload your own certificates
- Requires exporting from Xcode or Keychain Access

### 3.4 Update Bundle ID in Codemagic

1. Go to **Settings** → **Build settings**
2. Check that the `APP_ID` variable matches your App Store Connect Bundle ID
3. Or update `codemagic.yaml`:
   ```yaml
   vars:
     APP_ID: "com.yourdomain.yourapp"  # Your actual Bundle ID
   ```

### 3.5 Update Email for Notifications (Optional)

Edit `codemagic.yaml`:
```yaml
publishing:
  email:
    recipients:
      - your-email@example.com  # Your actual email
```

---

## Step 4: Build and Deploy

### 4.1 Trigger Build

**Option A: Automatic Build (Recommended)**
- Just push to `main` branch:
  ```bash
  git add .
  git commit -m "Ready for TestFlight deployment"
  git push origin main
  ```
- Codemagic will automatically start building

**Option B: Manual Build**
1. Go to Codemagic → Your app
2. Click **Start new build**
3. Select **iOS Workflow**
4. Choose `main` branch
5. Click **Start new build**

### 4.2 Monitor Build

1. Watch the build progress in Codemagic
2. Build typically takes 10-20 minutes
3. You'll see these steps:
   - Get Flutter dependencies
   - Set up code signing
   - Build IPA
   - Upload to TestFlight (automatic!)

### 4.3 Check Build Status

- **Success**: Build completes and uploads to TestFlight automatically
- **Failure**: Check build logs for errors (usually code signing or API credentials)

---

## Step 5: Verify Upload in App Store Connect

### 5.1 Check TestFlight

1. Go to https://appstoreconnect.apple.com
2. Click **My Apps** → Your app
3. Click the **TestFlight** tab
4. You should see your build under **Builds** section
5. Status will show:
   - **Processing** (10-60 minutes) - Apple is processing your build
   - **Ready to Test** - Build is ready!

### 5.2 Wait for Processing

- Apple processes builds (checks for issues, generates symbols, etc.)
- Usually takes 10-60 minutes
- You'll get an email when processing is complete

---

## Step 6: Add Build to TestFlight Testing

### 6.1 Internal Testing (Instant - Recommended for First Test)

1. In TestFlight tab, find **Internal Testing** section
2. Click **+** next to **Internal Testing**
3. Select your processed build
4. Fill in **What to Test**:
   ```
   Initial TestFlight release
   - Test survey functionality
   - Verify API connectivity
   - Check UI/UX
   ```
5. Click **Add Build to Internal Testing**
6. Build is immediately available!

### 6.2 Add Internal Testers

1. In **Internal Testing** section, click **Add Testers**
2. Enter email addresses of team members (up to 100)
3. Click **Add**
4. Testers will receive email invitations
5. They need to:
   - Install **TestFlight** app from App Store
   - Accept the email invitation
   - Install your app from TestFlight

### 6.3 External Testing (Optional - Requires Review)

1. In TestFlight tab, find **External Testing** section
2. Click **+** next to **External Testing**
3. Select your processed build
4. Fill in **What to Test** notes
5. Click **Submit for Review**
6. Wait for Apple review (usually 24-48 hours)
7. Once approved, add testers (up to 10,000)

---

## Step 7: Test Your App

### 7.1 As a Tester

1. Install **TestFlight** app from App Store (if not installed)
2. Check your email for TestFlight invitation
3. Click the invitation link or open TestFlight app
4. Accept the invitation
5. Install your app from TestFlight
6. Test the survey functionality!

### 7.2 Update and Redeploy

When you make changes:

1. Push changes to `main` branch
2. Codemagic automatically builds and uploads
3. New build appears in TestFlight
4. Add to testing group
5. Testers get notified of update

---

## Troubleshooting

### Build Fails: "Authentication failed"

**Solution**:
- Verify App Store Connect API credentials are correct
- Check that `.p8` key content includes full key (with BEGIN/END lines)
- Ensure Key ID and Issuer ID are correct
- Verify the API key has **App Manager** or **Admin** role

### Build Fails: "App not found"

**Solution**:
- Create the app in App Store Connect first (Step 2)
- Verify Bundle ID matches exactly in:
  - App Store Connect
  - `codemagic.yaml` (APP_ID)
  - iOS project settings

### Build Fails: "Code signing failed"

**Solution**:
- Use **Automatic code signing** in Codemagic (easiest)
- Or upload your own certificates manually
- Verify your Apple Developer account is active

### Upload Succeeds but Build Not Showing in TestFlight

**Solution**:
- Wait longer (can take up to 60 minutes)
- Check App Store Connect for error messages
- Verify Bundle ID matches
- Check email for notifications from Apple

### Build Processing Takes Too Long

**Solution**:
- Normal processing time is 10-60 minutes
- Check App Store Connect for status updates
- Large apps take longer to process
- Check email for completion notification

---

## Quick Reference

### Required Environment Variables in Codemagic

| Variable | Description | Example |
|----------|-------------|---------|
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID from App Store Connect | `abc123-def4-5678-90ab-cdef12345678` |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | Key ID from App Store Connect | `ABC123DEF4` |
| `APP_STORE_CONNECT_PRIVATE_KEY` | Full `.p8` key file content | `-----BEGIN PRIVATE KEY-----...` |

### Important URLs

- **App Store Connect**: https://appstoreconnect.apple.com
- **Codemagic**: https://codemagic.io
- **Apple Developer**: https://developer.apple.com

### Key Files

- `codemagic.yaml` - Build configuration
- `.p8` file - App Store Connect API key (keep secure!)
- `frontend/ios/Runner.xcodeproj` - iOS project settings

---

## Next Steps After First Deployment

1. **Test with Internal Testers** - Get feedback
2. **Fix Issues** - Update code based on feedback
3. **Redeploy** - Push changes, Codemagic auto-builds
4. **External Testing** - Submit for external testing (optional)
5. **App Store** - When ready, submit for App Store review

---

## Summary Checklist

- [ ] Created App Store Connect API Key
- [ ] Saved Issuer ID, Key ID, and Private Key
- [ ] Created app in App Store Connect
- [ ] Registered Bundle ID (if needed)
- [ ] Updated Bundle ID in `codemagic.yaml`
- [ ] Added API credentials to Codemagic environment variables
- [ ] Configured code signing in Codemagic
- [ ] Updated email in `codemagic.yaml`
- [ ] Pushed code to trigger build
- [ ] Build completed successfully
- [ ] Build processed in App Store Connect
- [ ] Added build to Internal Testing
- [ ] Added testers
- [ ] Testers installed and tested app

---

**You're all set! 🚀**

Once you complete these steps, your app will automatically build and deploy to TestFlight whenever you push to `main` branch.
