# Upload iOS App to TestFlight Without a Mac

This guide shows you how to upload your `.ipa` file to TestFlight without needing a Mac.

## ✅ Best Option: Automatic Upload via Codemagic (Recommended)

**No Mac needed!** Codemagic can automatically upload your build to TestFlight.

### Step 1: Enable Automatic Upload

The `codemagic.yaml` is already configured with `submit_to_testflight: true`. Make sure you have:

1. **App Store Connect API credentials** set up in Codemagic:
   - `APP_STORE_CONNECT_ISSUER_ID`
   - `APP_STORE_CONNECT_KEY_IDENTIFIER`
   - `APP_STORE_CONNECT_PRIVATE_KEY`

2. **Code signing** configured in Codemagic (Automatic or Manual)

### Step 2: Build and Upload

1. Push to `main` branch (or trigger build manually)
2. Codemagic builds your app
3. **Codemagic automatically uploads to TestFlight** ✅
4. Go to [App Store Connect](https://appstoreconnect.apple.com) → Your App → **TestFlight**
5. Wait for processing (10-60 minutes)
6. Add testers!

**That's it!** No Mac needed.

---

## Option 2: App Store Connect Website Upload (No Mac Required)

If automatic upload isn't working, you can upload directly via the App Store Connect website.

### Step 1: Download .ipa from Codemagic

1. Go to your build in Codemagic
2. Click **Artifacts** tab
3. Download the `.ipa` file

### Step 2: Upload via App Store Connect Website

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Sign in with your Apple Developer account
3. Navigate to **My Apps** → Your App
4. Click **TestFlight** tab
5. Click **+** button (or **Upload Build**)
6. Click **Choose File** and select your downloaded `.ipa` file
7. Click **Upload**
8. Wait for processing (10-60 minutes)

**Note**: The website upload feature may have file size limits. If your `.ipa` is too large, use Option 1 (automatic upload) or Option 3.

---

## Option 3: Cloud Mac Services (If Website Upload Fails)

If the website upload doesn't work, you can rent a cloud Mac for a few minutes:

### MacStadium (Pay-per-use)

1. Sign up at https://www.macstadium.com
2. Rent a Mac instance ($0.50-2.00/hour)
3. Download **Transporter** app
4. Upload your `.ipa` file
5. Cancel subscription immediately

### AWS EC2 Mac Instances

1. Launch an EC2 Mac instance in AWS
2. Connect via SSH
3. Use command-line tools to upload

**Note**: These are more expensive and complex. Option 1 (automatic upload) is much easier.

---

## Option 4: Use a Friend's Mac (One-Time)

If you just need to upload once:

1. Download `.ipa` from Codemagic
2. Ask a friend/colleague with a Mac to:
   - Download **Transporter** app (free from Mac App Store)
   - Drag and drop your `.ipa` file
   - Click **Deliver**

---

## Troubleshooting Automatic Upload

### Upload Fails in Codemagic

**Check these:**

1. **App Store Connect API credentials**:
   - Go to Codemagic → Settings → Environment variables
   - Verify `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_KEY_IDENTIFIER`, `APP_STORE_CONNECT_PRIVATE_KEY` are set
   - Check that the `.p8` key file content is correct (include the full key with headers)

2. **Code signing**:
   - Ensure code signing is configured in Codemagic
   - Verify Bundle ID matches App Store Connect

3. **App exists in App Store Connect**:
   - Your app must exist in App Store Connect with matching Bundle ID
   - Go to https://appstoreconnect.apple.com and create the app if needed

4. **Check build logs**:
   - In Codemagic, check the build logs for upload errors
   - Look for messages about authentication or signing issues

### Common Errors

**"Authentication failed"**:
- Verify App Store Connect API credentials are correct
- Check that the `.p8` key file content includes the full key (with `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`)

**"App not found"**:
- Create the app in App Store Connect first
- Ensure Bundle ID matches exactly

**"Code signing failed"**:
- Configure code signing in Codemagic
- Use Automatic code signing if possible

---

## Recommended Workflow

1. **Enable automatic upload** in `codemagic.yaml` (already done ✅)
2. **Set up App Store Connect API credentials** in Codemagic
3. **Push to main branch** → Build → Auto-upload → Done! 🎉

No Mac needed at any point!

---

## Quick Checklist

- [ ] App Store Connect API credentials configured in Codemagic
- [ ] Code signing configured in Codemagic
- [ ] App created in App Store Connect with matching Bundle ID
- [ ] `submit_to_testflight: true` enabled in `codemagic.yaml`
- [ ] Push code to trigger build
- [ ] Check App Store Connect → TestFlight for uploaded build
- [ ] Wait for processing
- [ ] Add testers

---

## Resources

- [App Store Connect](https://appstoreconnect.apple.com)
- [Codemagic Automatic Upload Docs](https://docs.codemagic.io/publishing/app-store-connect/)
- [App Store Connect API](https://developer.apple.com/app-store-connect/api/)
