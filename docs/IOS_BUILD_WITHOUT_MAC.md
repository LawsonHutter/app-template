# Building iOS Apps Without a Mac

Since you don't have a Mac, you can use **GitHub Actions** to build your iOS app on Apple's cloud infrastructure. This guide shows you how.

## Option 1: GitHub Actions (Recommended - Free)

GitHub Actions provides free macOS runners that can build iOS apps.

### Step 1: Set Up Your Repository

1. Ensure your code is pushed to GitHub
2. The workflow file `.github/workflows/build-ios.yml` is already created

### Step 2: Configure iOS Project Settings

Before building, you need to configure your iOS app:

1. **Create iOS project** (if not exists):
   ```bash
   cd frontend
   flutter create --platforms=ios .
   ```

2. **Set Bundle Identifier**:
   - You'll need to do this manually the first time, or use a service that can configure it
   - Bundle ID format: `com.yourdomain.appname` (e.g., `com.dipoll.surveyapp`)

### Step 3: Manual First-Time Setup (One-Time)

For the first build, you'll need to:

1. **Get a Mac temporarily** (borrow, rent, or use a cloud Mac service):
   - Open `frontend/ios/Runner.xcworkspace` in Xcode
   - Configure Bundle ID and signing
   - Or use a service like **Codemagic** or **AppCircle** (see Option 2)

2. **Or use a cloud Mac service**:
   - **MacStadium**: Rent a cloud Mac ($99+/month)
   - **AWS EC2 Mac instances**: Pay-per-use Mac in the cloud
   - **MacinCloud**: Remote Mac access ($20-50/month)

### Step 4: Trigger GitHub Actions Build

#### Method A: Manual Trigger (Workflow Dispatch)

1. Go to your GitHub repository
2. Click **Actions** tab
3. Select **Build iOS for TestFlight** workflow
4. Click **Run workflow**
5. Enter:
   - **API URL**: `https://dipoll.net/api/counter/` (or your API URL)
   - **Build Number**: (optional, defaults to run number)
6. Click **Run workflow**

#### Method B: Push to Main Branch

Just push changes to `frontend/` and the workflow will run automatically:

```bash
git add frontend/
git commit -m "Update frontend"
git push origin main
```

#### Method C: Create a Tag

```bash
git tag ios-v1.0.0
git push origin ios-v1.0.0
```

### Step 5: Download Build Artifacts

1. Go to **Actions** tab in GitHub
2. Click on the completed workflow run
3. Scroll down to **Artifacts**
4. Download:
   - **ios-app**: Contains the `.ipa` file
   - **ios-archive**: Contains the Xcode archive (for manual upload)

### Step 6: Upload to App Store Connect

You have two options:

#### Option A: Using Transporter App (Mac Required)

1. Download **Transporter** from Mac App Store (free)
2. Open Transporter
3. Drag and drop your `.ipa` file
4. Click **Deliver**

#### Option B: Using Xcode Organizer (Mac Required)

1. Open Xcode
2. Go to **Window > Organizer**
3. Click **+** and select your `.xcarchive` file
4. Click **Distribute App**
5. Follow the prompts

#### Option C: Use a Cloud Service (No Mac Needed)

See **Option 2** below for services that handle upload automatically.

## Option 2: Cloud Build Services (Easier, Some Free Tiers)

These services can build AND upload to TestFlight automatically:

### Codemagic (Recommended)

1. **Sign up**: https://codemagic.io (free tier available)
2. **Connect GitHub**: Authorize Codemagic to access your repo
3. **Configure**:
   - Select your Flutter project
   - Set API URL: `https://dipoll.net/api/counter/`
   - Configure signing (they guide you through it)
4. **Build**: Click "Start new build"
5. **Auto-upload**: They can upload to TestFlight automatically

**Free tier**: 500 build minutes/month

### AppCircle

1. **Sign up**: https://appcircle.io
2. **Connect repo**: Link your GitHub repo
3. **Configure**: Set up iOS build configuration
4. **Build & Upload**: Automatic TestFlight upload

**Free tier**: Limited builds

### Bitrise

1. **Sign up**: https://bitrise.io
2. **Add app**: Connect your GitHub repo
3. **Configure workflow**: Use Flutter workflow template
4. **Build**: Trigger builds manually or on push

**Free tier**: 200 builds/month

## Option 3: Manual Build Service

If you just need someone to build it once:

1. **Fiverr**: Hire someone to build and upload ($20-50)
2. **Upwork**: Find a Flutter/iOS developer
3. **Friends/Colleagues**: Ask someone with a Mac

## Recommended Approach

**For ongoing development**: Use **GitHub Actions** (free) + **Codemagic** (free tier) for automatic TestFlight uploads.

**For one-time build**: Use **Codemagic** or hire someone on Fiverr.

## Setting Up Codemagic (Step-by-Step)

1. **Create account**: https://codemagic.io/signup
2. **Add app**: Click "Add application" → Select GitHub → Choose your repo
3. **Configure**:
   - **Project type**: Flutter
   - **Workflow**: iOS
4. **Set environment variables**:
   - `API_BASE_URL`: `https://dipoll.net/api/counter/`
5. **Configure signing**:
   - Upload your Apple Developer certificate
   - Or let Codemagic manage it (they guide you)
6. **Build**: Click "Start new build"
7. **Auto-upload**: Enable "TestFlight" distribution in settings

## Troubleshooting

### GitHub Actions Build Fails

- **Check logs**: Click on the failed workflow → View logs
- **Common issues**:
  - Missing `ios/` folder → Run `flutter create --platforms=ios .`
  - Signing errors → Need to configure signing first (one-time Mac access)
  - API URL issues → Check the `--dart-define` parameter

### Can't Upload IPA

- **Transporter errors**: Usually signing issues
- **Xcode errors**: Archive might need re-signing
- **Solution**: Use Codemagic or similar service that handles signing

### No Mac for First-Time Setup

- **Use Codemagic**: They can help configure signing without a Mac
- **Rent a Mac**: MacStadium, AWS EC2 Mac, MacinCloud
- **Hire someone**: Fiverr/Upwork for one-time setup

## Next Steps

1. **Choose your approach**: GitHub Actions (free) or Codemagic (easier)
2. **Set up iOS project**: Ensure `frontend/ios/` exists
3. **Configure Bundle ID**: One-time setup (may need Mac or Codemagic)
4. **Build**: Trigger workflow or use Codemagic
5. **Upload**: Use Transporter (Mac) or Codemagic (automatic)

## Resources

- [GitHub Actions macOS Runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#supported-runners-and-hardware-resources)
- [Codemagic Flutter iOS Guide](https://docs.codemagic.io/getting-started/building-a-flutter-app/)
- [App Store Connect API](https://developer.apple.com/app-store-connect/api/) - For automated uploads
