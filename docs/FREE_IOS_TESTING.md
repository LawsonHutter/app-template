# Free iOS Testing Options

This guide explains how to test your iOS app without paying the $99/year Apple Developer Program fee.

## ⚠️ Important Limitations

**TestFlight requires a paid Apple Developer account ($99/year).** However, there are free alternatives for testing on your own device.

---

## Option 1: Free Apple Developer Account (7-Day Testing)

Apple provides a **free** Apple Developer account that lets you test apps on your own device for **7 days**.

### Limitations:
- ✅ **Free** - No cost
- ✅ Test on your own iPhone/iPad
- ❌ **7-day expiration** - App stops working after 7 days, must re-sign
- ❌ **No TestFlight** - Cannot use TestFlight beta testing
- ❌ **No App Store** - Cannot publish to App Store
- ❌ **Limited to your device** - Cannot share with others easily
- ❌ **Requires Mac** - Need Xcode to sign and install

### How to Use (Requires Mac):

1. **Sign up for free Apple ID** (if you don't have one)
2. **Install Xcode** on a Mac
3. **Connect your iPhone** via USB
4. **Open project in Xcode**
5. **Select your device** as the build target
6. **Xcode will prompt** to sign with your free Apple ID
7. **Build and run** - App installs on your device
8. **Re-sign every 7 days** when it expires

**Problem**: You don't have a Mac, so this won't work directly.

---

## Option 2: Build .ipa and Install via Third-Party Tools (Free Account)

You can build the `.ipa` in Codemagic (free tier) and install it using third-party tools, but this still has limitations.

### Step 1: Build in Codemagic

1. Use Codemagic free tier (500 build minutes/month)
2. Build your app (no code signing needed for development builds)
3. Download the `.ipa` file

### Step 2: Install on Your Device

**Option A: Using AltStore (Free, No Mac Required)**

1. **Install AltStore** on your iPhone:
   - Go to https://altstore.io on your iPhone
   - Follow instructions to install via computer (Windows/Mac/Linux)
   - Requires installing AltServer on your computer

2. **Install your .ipa**:
   - Open AltStore on your iPhone
   - Tap **+** → Select your `.ipa` file
   - App installs (expires in 7 days, re-sign via AltStore)

**Option B: Using 3uTools (Windows, Free)**

1. Download **3uTools** (Windows software)
2. Connect iPhone via USB
3. Go to **Apps** → **Install** → Select your `.ipa`
4. App installs (requires free Apple ID, expires in 7 days)

**Option C: Using Sideloadly (Windows/Mac, Free)**

1. Download **Sideloadly** from https://sideloadly.io
2. Connect iPhone via USB
3. Drag `.ipa` file into Sideloadly
4. Enter your free Apple ID
5. Click **Start** - App installs (expires in 7 days)

### Limitations:
- ⚠️ **7-day expiration** - Must re-sign weekly
- ⚠️ **Free Apple ID required** - Need to sign up (free)
- ⚠️ **USB connection needed** - For initial installation
- ⚠️ **No TestFlight** - Cannot use TestFlight features
- ⚠️ **Limited distribution** - Harder to share with testers

---

## Option 3: Use Codemagic to Build Development Build (Free)

You can modify the build to create a development build that doesn't require App Store signing.

### Modify `codemagic.yaml`:

```yaml
- name: Build ipa for development (no signing required)
  script: |
    cd frontend
    flutter build ios --release --no-codesign
    # Then package manually or use different method
```

**Note**: This creates an unsigned build that still needs to be signed to install on a device.

---

## Option 4: Test on iOS Simulator (Free, But Requires Mac)

- iOS Simulator only works on Mac
- Not an option without a Mac

---

## Option 5: Pay for Apple Developer Account ($99/year)

**This is the easiest option** if you want:
- ✅ **No expiration** - Apps work indefinitely
- ✅ **TestFlight** - Easy beta testing with up to 10,000 testers
- ✅ **App Store** - Publish to App Store
- ✅ **No Mac needed** - Use Codemagic for everything
- ✅ **Easy distribution** - Share via TestFlight links

**Cost**: $99/year (about $8.25/month)

---

## Recommended Approach

### For Free Testing (Limited):

1. **Sign up for free Apple ID** (if you don't have one)
2. **Build in Codemagic** (free tier)
3. **Download `.ipa`** from Codemagic artifacts
4. **Use Sideloadly or 3uTools** to install on your iPhone
5. **Re-sign every 7 days** when it expires

### For Professional Testing:

1. **Pay for Apple Developer account** ($99/year)
2. **Use Codemagic automatic upload** to TestFlight
3. **Install via TestFlight app** - No expiration, easy updates
4. **Share with testers** easily

---

## Comparison Table

| Feature | Free Account | Paid Account ($99/year) |
|---------|-------------|------------------------|
| **Cost** | Free | $99/year |
| **Test on own device** | ✅ (7 days) | ✅ (permanent) |
| **TestFlight** | ❌ | ✅ |
| **Share with testers** | ❌ (difficult) | ✅ (easy) |
| **App Store publishing** | ❌ | ✅ |
| **Re-signing needed** | ✅ (every 7 days) | ❌ |
| **Mac required** | ✅ (for signing) | ❌ (Codemagic handles it) |

---

## Step-by-Step: Free Testing with Sideloadly

### Prerequisites:
- Free Apple ID (create at https://appleid.apple.com)
- Windows/Mac computer
- iPhone connected via USB
- `.ipa` file from Codemagic

### Steps:

1. **Download Sideloadly**:
   - Go to https://sideloadly.io
   - Download for Windows or Mac
   - Install the software

2. **Build in Codemagic**:
   - Trigger a build (or wait for automatic build)
   - Download the `.ipa` file from artifacts

3. **Install via Sideloadly**:
   - Open Sideloadly
   - Connect iPhone via USB
   - Drag `.ipa` file into Sideloadly
   - Enter your free Apple ID email and password
   - Click **Start**
   - Wait for installation (may take a few minutes)

4. **Trust the Developer**:
   - On iPhone: **Settings** → **General** → **VPN & Device Management**
   - Tap your Apple ID
   - Tap **Trust**

5. **Launch App**:
   - Find your app on the home screen
   - Launch and test!

6. **Re-sign in 7 Days**:
   - When app expires, repeat step 3
   - Sideloadly will re-sign automatically

---

## Troubleshooting

### "Untrusted Developer" Error:
- Go to **Settings** → **General** → **VPN & Device Management**
- Tap your Apple ID → **Trust**

### App Expires After 7 Days:
- This is normal with free accounts
- Re-sign using Sideloadly/AltStore/3uTools

### Can't Install .ipa:
- Ensure `.ipa` is built for iOS (not simulator)
- Check that your device iOS version is compatible
- Try a different tool (Sideloadly, 3uTools, AltStore)

### Build Fails in Codemagic:
- Free accounts can still build in Codemagic
- Code signing may fail - try building without signing first
- Check build logs for specific errors

---

## Summary

**Free Option**:
- ✅ Build in Codemagic (free tier)
- ✅ Download `.ipa`
- ✅ Install via Sideloadly/3uTools (free)
- ⚠️ Re-sign every 7 days
- ❌ No TestFlight

**Paid Option** ($99/year):
- ✅ Build in Codemagic
- ✅ Automatic TestFlight upload
- ✅ Install via TestFlight app
- ✅ No expiration
- ✅ Easy sharing with testers

**Recommendation**: If you're serious about iOS development, the $99/year is worth it for the convenience and TestFlight features. If you're just testing, the free option with Sideloadly works but requires weekly re-signing.

---

## Resources

- [Sideloadly](https://sideloadly.io) - Free iOS app installer
- [3uTools](https://www.3u.com) - Windows iOS management tool
- [AltStore](https://altstore.io) - Alternative app store
- [Free Apple Developer Account](https://developer.apple.com/programs/) - Sign up for free account
