# Codemagic Setup Guide for iOS TestFlight

This guide walks you through setting up Codemagic to build and deploy your iOS app to TestFlight.

## Prerequisites

1. **Apple Developer Account** ($99/year)
   - Sign up at https://developer.apple.com/programs/
   - Required for TestFlight and App Store distribution

2. **Codemagic Account**
   - Sign up at https://codemagic.io (free tier: 500 build minutes/month)

3. **App Store Connect API Key** (for automatic uploads)
   - Go to https://appstoreconnect.apple.com
   - Navigate to **Users and Access** → **Keys** → **App Store Connect API**
   - Create a new key with **App Manager** or **Admin** role
   - Download the `.p8` key file
   - Note the **Key ID** and **Issuer ID**

## Step 1: Connect Your Repository

1. Go to https://codemagic.io
2. Click **Add application**
3. Select **GitHub** and authorize Codemagic
4. Choose your `survey-web-app` repository
5. Select **Flutter** as the project type

## Step 2: Configure Environment Variables

In Codemagic UI, go to your app → **Settings** → **Environment variables**:

### Required for TestFlight Upload:

1. **APP_STORE_CONNECT_ISSUER_ID**
   - Value: Your Issuer ID from App Store Connect (format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)

2. **APP_STORE_CONNECT_KEY_IDENTIFIER**
   - Value: Your Key ID from App Store Connect (format: `XXXXXXXXXX`)

3. **APP_STORE_CONNECT_PRIVATE_KEY**
   - Value: The contents of your `.p8` key file (copy the entire file content)

### Optional:

4. **API_BASE_URL**
   - Value: `https://dipoll.net/api/counter/` (or your API URL)
   - Defaults to `https://dipoll.net/api/counter/` if not set

## Step 3: Configure Code Signing

1. In Codemagic UI, go to your app → **Settings** → **Code signing**
2. Click **Add certificate**
3. Choose one of these options:

### Option A: Automatic Code Signing (Recommended)

1. Select **Automatic code signing**
2. Enter your **Bundle ID** (e.g., `com.dipoll.surveyapp`)
3. Codemagic will automatically manage certificates and provisioning profiles

### Option B: Manual Code Signing

1. Upload your **Distribution Certificate** (`.p12` file)
2. Upload your **Provisioning Profile** (`.mobileprovision` file)
3. Enter the certificate password

## Step 4: Update Bundle ID

1. In Codemagic UI, go to your app → **Settings** → **Build settings**
2. Update the **APP_ID** variable in `codemagic.yaml` or set it in the UI:
   - Default: `com.dipoll.surveyapp`
   - Change to match your App Store Connect app

Or edit `codemagic.yaml`:
```yaml
vars:
  APP_ID: "com.yourdomain.yourapp"  # Update this
```

## Step 5: Create App in App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Click **My Apps** → **+** → **New App**
3. Fill in:
   - **Platform**: iOS
   - **Name**: Survey App (or your app name)
   - **Primary Language**: English
   - **Bundle ID**: Select or create one matching your `APP_ID`
   - **SKU**: A unique identifier (e.g., `survey-app-001`)
   - **User Access**: Full Access

## Step 6: Configure Workflow

The `codemagic.yaml` file is already configured. You can customize it if needed:

- **Build settings**: Edit `codemagic.yaml` in your repository
- **Email notifications**: Update the email in `codemagic.yaml`
- **TestFlight auto-upload**: Uncomment `submit_to_testflight: true` in `codemagic.yaml`

### Automatic Builds on Git Push

The workflow is configured to automatically build when you push to the `main` branch (if changes are in `frontend/` or `codemagic.yaml`).

**To enable automatic builds in Codemagic UI:**

1. Go to your app → **Settings** → **Build triggers**
2. Enable **Automatic builds**
3. Select **Push to branch**: `main`
4. Optionally add path filters: `frontend/**`

**Or use the `codemagic.yaml` triggers** (already configured):
- Builds automatically on push to `main` branch
- Only triggers if `frontend/` or `codemagic.yaml` files change

## Step 7: Start Your First Build

1. In Codemagic UI, go to your app
2. Click **Start new build**
3. Select **iOS Workflow**
4. Choose your branch (usually `main`)
5. Click **Start new build**

## Step 8: Monitor Build

1. Watch the build progress in real-time
2. Build typically takes 10-20 minutes
3. If successful, the `.ipa` file will be:
   - Uploaded to TestFlight automatically (if configured)
   - Available as a download artifact

## Step 9: After a Successful Build

### Option A: Automatic TestFlight Upload (Recommended)

If you've enabled `submit_to_testflight: true` in `codemagic.yaml`:

1. **Wait for upload** (build log will show upload progress)
2. **Go to App Store Connect** → Your App → **TestFlight** tab
3. **Wait for processing** (10-60 minutes) - Apple processes the build
4. **Once processed**, you'll see your build under **Builds**
5. **Add testers**:
   - Click **+** next to **Internal Testing** or **External Testing**
   - Select your build
   - Fill in **What to Test** notes
   - Click **Submit for Review** (for External Testing)
   - Add testers:
     - **Internal Testing**: Up to 100 team members (instant)
     - **External Testing**: Up to 10,000 testers (requires review, usually 24-48 hours)

### Option B: Manual Upload

If auto-upload is not enabled:

1. **Download the `.ipa` artifact** from Codemagic:
   - Go to your build → **Artifacts** tab
   - Download the `.ipa` file

2. **Upload to TestFlight**:
   - **Option 1**: Use **Transporter** app (Mac required)
     - Download from Mac App Store
     - Drag and drop `.ipa` file
     - Click **Deliver**
   - **Option 2**: Use **Xcode** (Mac required)
     - Open Xcode → **Window** → **Organizer**
     - Click **+** and select your `.ipa` or `.xcarchive`
     - Click **Distribute App** → **App Store Connect**
   - **Option 3**: Use **App Store Connect** website
     - Go to App Store Connect → Your App → **TestFlight**
     - Click **+** → **Upload Build**
     - Select your `.ipa` file

3. **Wait for processing** (10-60 minutes)

4. **Add testers** (same as Option A, step 5)

### Option C: Test Locally First

Before uploading to TestFlight, you can test the build:

1. **Download the `.ipa`** from Codemagic artifacts
2. **Install on a device** (requires Apple Developer account):
   - Use **Xcode** → **Window** → **Devices and Simulators**
   - Drag `.ipa` to your connected device
   - Or use **3uTools**, **iMazing**, or similar tools

## Troubleshooting

### Error: "Did not find xcodeproj"

✅ **Fixed!** The iOS project has been initialized. The `Runner.xcodeproj` and `Runner.xcworkspace` files now exist in `frontend/ios/`.

### Error: Code Signing Issues

- Ensure your Apple Developer account is active
- Verify Bundle ID matches in Codemagic, Xcode project, and App Store Connect
- Check that certificates are valid and not expired
- Try using Automatic code signing in Codemagic

### Error: API Connection Issues

- Verify your API URL is accessible (not `localhost`)
- For TestFlight, use HTTPS (not HTTP)
- Check that your EC2 security group allows inbound traffic

### Error: Build Fails

- Check build logs in Codemagic
- Ensure Flutter dependencies are up to date: `flutter pub get`
- Verify `codemagic.yaml` syntax is correct

### Error: TestFlight Upload Fails

- Verify App Store Connect API credentials are correct
- Check that your app exists in App Store Connect with matching Bundle ID
- Ensure your API key has the correct permissions

## Automatic Builds on Git Push

### How It Works

The `codemagic.yaml` is configured to automatically trigger builds when:

- You push to the `main` branch
- Changes are made to `frontend/` directory or `codemagic.yaml`

### Enable in Codemagic UI

1. Go to your app → **Settings** → **Build triggers**
2. Enable **Automatic builds**
3. Select **Push to branch**: `main`
4. (Optional) Add path filters: `frontend/**`

### Manual Trigger

You can still trigger builds manually:

1. Go to your app in Codemagic
2. Click **Start new build**
3. Select branch and workflow
4. Click **Start new build**

### Disable Automatic Builds

If you want to build only manually:

1. In Codemagic UI: Disable **Automatic builds** in settings
2. Or remove the `triggering:` section from `codemagic.yaml`

## Next Steps

1. **Commit and push** the iOS project files:
   ```bash
   git add frontend/ios/ codemagic.yaml
   git commit -m "Initialize iOS project and add Codemagic configuration"
   git push origin main
   ```

2. **Set up Codemagic** following steps above

3. **Run your first build** in Codemagic (or wait for automatic build on push)

4. **After successful build**:
   - Download `.ipa` artifact (if manual upload)
   - Or wait for automatic TestFlight upload
   - Go to App Store Connect → TestFlight
   - Add testers and distribute

5. **Test your app** via TestFlight

## Resources

- [Codemagic Flutter iOS Guide](https://docs.codemagic.io/getting-started/building-a-flutter-app/)
- [App Store Connect API](https://developer.apple.com/app-store-connect/api/)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
