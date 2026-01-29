# Bundle ID Setup Guide

## Your Bundle ID

For your domain `your-app-name.net`, use:

**Bundle ID**: `com.your-app-name.surveyapp`

### Why This Format?

- **Reverse domain notation**: `com.domain.appname`
- Even though your domain is `.net`, use `com` (standard iOS convention)
- Format: `com.your-app-name.surveyapp` or `com.your-app-name.appname`

---

## Step 1: Register App ID in Apple Developer

### 1.1 Go to Apple Developer

1. Go to https://developer.apple.com/account/resources/identifiers/list
2. Click the **+** button (top left)
3. Select **App IDs** → **Continue**

### 1.2 Select App Type

1. Select **App** → **Continue**

### 1.3 Fill in App ID Details

1. **Description**: `Your App Name` (or your app name)
2. **Bundle ID**: Select **Explicit**
3. **Bundle ID Value**: Enter `com.your-app-name.surveyapp`
4. **Capabilities** (optional): 
   - Enable any services you need (Push Notifications, Sign in with Apple, etc.)
   - For basic Your App Name, you may not need any
5. Click **Continue**
6. Review and click **Register**

---

## Step 2: Verify Bundle ID in Your Code

### 2.1 Check `codemagic.yaml`

Already set to:
```yaml
vars:
  APP_ID: "com.your-app-name.surveyapp"
```

### 2.2 Check iOS Project

The Bundle ID has been updated in:
- `frontend/ios/Runner.xcodeproj/project.pbxproj`
- Should be: `com.your-app-name.surveyapp`

### 2.3 Verify in Xcode (Optional)

If you have Xcode:
1. Open `frontend/ios/Runner.xcworkspace`
2. Select **Runner** target
3. Go to **Signing & Capabilities**
4. Verify **Bundle Identifier** is `com.your-app-name.surveyapp`

---

## Step 3: Create App in App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Click **My Apps** → **+** → **New App**
3. Fill in:
   - **Platform**: iOS
   - **Name**: Your App Name (or your app name)
   - **Primary Language**: English
   - **Bundle ID**: Select `com.your-app-name.surveyapp` from dropdown
   - **SKU**: `survey-app-001` (or any unique identifier)
   - **User Access**: Full Access
4. Click **Create**

---

## Alternative Bundle IDs

If `com.your-app-name.surveyapp` is taken or you prefer different naming:

- `com.your-app-name.survey` - Shorter
- `com.your-app-name.app` - Generic
- `net.your-app-name.surveyapp` - Using .net (less common)
- `com.your-app-name.surveyapp2024` - With year suffix

**Important**: Whatever you choose, it must match in:
- Apple Developer (App ID registration)
- App Store Connect (when creating app)
- `codemagic.yaml` (APP_ID variable)
- iOS project (PRODUCT_BUNDLE_IDENTIFIER)

---

## Current Configuration

✅ **codemagic.yaml**: `com.your-app-name.surveyapp`
✅ **iOS Project**: Updated to `com.your-app-name.surveyapp`
✅ **Ready to register**: Use `com.your-app-name.surveyapp` in Apple Developer

---

## Next Steps

1. **Register App ID** in Apple Developer with `com.your-app-name.surveyapp`
2. **Create app** in App Store Connect using this Bundle ID
3. **Configure Codemagic** with App Store Connect API credentials
4. **Build and deploy** - Everything should match!

---

## Troubleshooting

### "Bundle ID already exists"

- Someone else may have registered it
- Try: `com.your-app-name.surveyapp2024` or `com.your-app-name.surveyapp1`
- Or use a more specific name: `com.your-app-name.surveyapp.prod`

### "Bundle ID doesn't match"

- Ensure it's identical in all places:
  - Apple Developer App ID
  - App Store Connect app
  - codemagic.yaml
  - iOS project file

### "Invalid Bundle ID format"

- Must be reverse domain notation
- Use lowercase letters, numbers, dots, hyphens
- Format: `com.domain.appname`
- No spaces or special characters

---

**Your Bundle ID**: `com.your-app-name.surveyapp` ✅
