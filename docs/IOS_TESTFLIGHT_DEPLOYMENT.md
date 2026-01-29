# iOS TestFlight Deployment Guide

This guide walks you through deploying your Flutter app to iOS TestFlight.

> **Don't have a Mac?** See [`IOS_BUILD_WITHOUT_MAC.md`](./IOS_BUILD_WITHOUT_MAC.md) for building iOS apps using GitHub Actions or cloud services.

## Prerequisites

1. **Apple Developer Account** ($99/year)
   - Sign up at https://developer.apple.com/programs/
   - Required for TestFlight and App Store distribution

2. **macOS Machine with Xcode**
   - iOS builds require macOS and Xcode
   - Install Xcode from the Mac App Store
   - Install Xcode Command Line Tools: `xcode-select --install`

3. **Flutter iOS Setup**
   ```bash
   flutter doctor
   # Ensure iOS toolchain is installed and configured
   ```

## Step 1: Initialize iOS Project (if not already done)

If you don't have an `ios/` folder in your Flutter project:

```bash
cd frontend
flutter create --platforms=ios .
```

This creates the iOS project files in `frontend/ios/`.

## Step 2: Configure iOS App Settings

### 2.1 Update App Bundle Identifier

Edit `frontend/ios/Runner.xcodeproj/project.pbxproj` or use Xcode:

1. Open `frontend/ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** target
3. Go to **Signing & Capabilities**
4. Set **Bundle Identifier** to something like: `com.yourdomain.surveyapp`
   - Must be unique (e.g., `com.dipoll.surveyapp`)

### 2.2 Configure App Display Name

Edit `frontend/ios/Runner/Info.plist`:

```xml
<key>CFBundleDisplayName</key>
<string>Survey App</string>
```

### 2.3 Configure API URL for iOS

The app currently uses `String.fromEnvironment('API_BASE_URL')` which works for iOS builds too.

**For production iOS builds**, use:

```bash
flutter build ios --release --dart-define=API_BASE_URL=https://dipoll.net/api/counter/
```

**For TestFlight**, you'll want HTTPS (not HTTP) since iOS enforces App Transport Security.

## Step 3: Configure App Transport Security (ATS)

iOS requires HTTPS for network requests. Since your backend is currently HTTP, you have two options:

### Option A: Use HTTPS (Recommended)

Set up SSL certificates on your EC2 server (see `docs/DEPLOY_CUSTOM_DOMAIN.md`), then use:

```bash
--dart-define=API_BASE_URL=https://dipoll.net/api/counter/
```

### Option B: Allow HTTP for Development (Not Recommended for Production)

Edit `frontend/ios/Runner/Info.plist` to allow HTTP:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

**Warning**: This allows insecure HTTP connections. Only use for development/testing.

## Step 4: Build iOS App

### 4.1 Build for Release

```bash
cd frontend

# Build with production API URL
flutter build ios --release --dart-define=API_BASE_URL=https://dipoll.net/api/counter/
```

This creates an `.ipa` file in `frontend/build/ios/iphoneos/`.

### 4.2 Open in Xcode

```bash
open frontend/ios/Runner.xcworkspace
```

## Step 5: Configure Signing & Capabilities in Xcode

1. **Select Runner** in the project navigator
2. Select the **Runner** target
3. Go to **Signing & Capabilities**
4. **Team**: Select your Apple Developer team
5. **Automatically manage signing**: Check this box
6. Xcode will automatically create provisioning profiles

## Step 6: Archive the App

1. In Xcode, select **Product > Scheme > Runner**
2. Select **Any iOS Device** (not a simulator) from the device dropdown
3. Go to **Product > Archive**
4. Wait for the archive to complete
5. The **Organizer** window will open showing your archive

## Step 7: Upload to App Store Connect

### 7.1 Create App in App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Click **My Apps**
3. Click **+** to create a new app
4. Fill in:
   - **Platform**: iOS
   - **Name**: Survey App (or your app name)
   - **Primary Language**: English
   - **Bundle ID**: Select the one you configured (e.g., `com.dipoll.surveyapp`)
   - **SKU**: A unique identifier (e.g., `survey-app-001`)
   - **User Access**: Full Access

### 7.2 Upload Archive

1. In Xcode Organizer, select your archive
2. Click **Distribute App**
3. Select **App Store Connect**
4. Click **Next**
5. Select **Upload**
6. Click **Next**
7. Select your distribution certificate and provisioning profile
8. Click **Upload**
9. Wait for upload to complete (may take 10-30 minutes)

## Step 8: Submit to TestFlight

1. Go to App Store Connect > Your App > **TestFlight** tab
2. Wait for processing to complete (can take 10-60 minutes)
3. Once processing is done, you'll see your build under **Builds**
4. Click **+** next to **Internal Testing** or **External Testing**
5. Select your build
6. Fill in **What to Test** notes
7. Click **Submit for Review** (for External Testing)
8. Add testers:
   - **Internal Testing**: Up to 100 team members (instant)
   - **External Testing**: Up to 10,000 testers (requires review, usually 24-48 hours)

## Step 9: Testers Install via TestFlight

1. Testers download **TestFlight** app from App Store
2. Accept your email invitation
3. Install your app from TestFlight
4. Test the counter functionality

## Backend Considerations for iOS

### CORS Not Required

Native iOS apps don't use CORS (that's a browser security feature). Your Django backend's `CORS_ALLOWED_ORIGINS` setting doesn't affect iOS apps.

### HTTPS Recommended

iOS enforces App Transport Security (ATS) which requires HTTPS for production apps. For TestFlight:
- **Internal Testing**: Can use HTTP (with ATS exception)
- **External Testing**: Should use HTTPS

### Update Backend CORS (Optional)

If you want to keep CORS settings clean, you can remove iOS from CORS (since it's not needed):

```bash
# On EC2, edit .env
CORS_ALLOWED_ORIGINS=http://dipoll.net,http://www.dipoll.net,https://dipoll.net,https://www.dipoll.net
```

iOS apps don't send an `Origin` header, so CORS doesn't apply.

## Troubleshooting

### Build Errors

```bash
# Clean and rebuild
cd frontend
flutter clean
flutter pub get
flutter build ios --release
```

### Signing Errors

- Ensure your Apple Developer account is active
- Check that your Bundle ID matches in Xcode and App Store Connect
- Verify your team is selected in Xcode Signing & Capabilities

### Network Errors

- Ensure your API URL is accessible from iOS devices (not `localhost`)
- For TestFlight, use HTTPS or configure ATS exceptions
- Check that your EC2 security group allows inbound traffic on port 443 (HTTPS)

### Upload Errors

- Ensure you're using the correct Apple ID with App Store Connect access
- Check that your app exists in App Store Connect with matching Bundle ID
- Verify your distribution certificate is valid

## Next Steps

1. **Set up HTTPS** on your EC2 server (see `docs/DEPLOY_CUSTOM_DOMAIN.md`)
2. **Build iOS app** with HTTPS API URL
3. **Upload to TestFlight**
4. **Test with internal testers**
5. **Submit for external testing** (optional)

## Resources

- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [App Store Connect](https://appstoreconnect.apple.com)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [Xcode Documentation](https://developer.apple.com/xcode/)
