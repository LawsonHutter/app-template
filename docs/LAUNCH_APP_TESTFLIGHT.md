# Launch Your App on TestFlight

Now that your app is in App Store Connect, here's how to get it on your phone!

---

## Step 1: Answer Encryption Compliance (Already Fixed!)

✅ **I've added the encryption key to `Info.plist`** to bypass this question.

**What I added:**
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

This tells Apple your app only uses standard encryption (HTTPS), so you don't need to answer the question.

**Next build will include this**, so you won't see the encryption question again.

---

## Step 2: Wait for Build to Upload

1. **Trigger a new build** (or wait for automatic build):
   ```powershell
   git add frontend/ios/Runner/Info.plist
   git commit -m "Add encryption compliance key to bypass question"
   git push origin main
   ```

2. **Wait for build to complete** (10-20 minutes)

3. **Check App Store Connect**:
   - Go to https://appstoreconnect.apple.com
   - Click **My Apps** → **your-app-name**
   - Click **TestFlight** tab
   - Look at **Builds** section (top of page)
   - Build should appear with status: **Processing** → **Ready to Test**

---

## Step 3: Add Build to Internal Testing

Once build shows **"Ready to Test"**:

1. In **TestFlight** tab, scroll down to **Internal Testing** section
2. Click **+** next to **Internal Testing** (or click the group name)
3. Select your processed build (status: "Ready to Test")
4. Fill in **What to Test**:
   ```
   Initial TestFlight release
   - Test survey functionality
   - Verify API connectivity
   - Check UI/UX
   ```
5. Click **Add Build to Internal Testing**

---

## Step 4: Add Yourself as a Tester

1. In **Internal Testing** section, click **Add Testers**
2. Enter your email address (the one associated with your Apple ID)
3. Click **Add**
4. You'll receive an email invitation

---

## Step 5: Install TestFlight App

**On your iPhone/iPad:**

1. Open **App Store**
2. Search for **"TestFlight"**
3. Install **TestFlight** app (by Apple)
4. Open **TestFlight** app

---

## Step 6: Accept Invitation and Install

1. **Check your email** for TestFlight invitation
2. **Click the invitation link** (opens on your iPhone/iPad)
   - Or open **TestFlight** app and accept invitation there
3. **Tap "Accept"** in TestFlight
4. **Tap "Install"** to install your app
5. **Open your app** from home screen!

---

## Quick Reference

### App Store Connect URLs

- **Main**: https://appstoreconnect.apple.com
- **My Apps**: https://appstoreconnect.apple.com/apps
- **TestFlight**: https://appstoreconnect.apple.com/apps → Your app → TestFlight

### TestFlight App

- **Download**: Search "TestFlight" in App Store
- **Developer**: Apple Inc.
- **Free**: Yes

---

## Troubleshooting

### Build Not Showing in TestFlight

**If build doesn't appear:**
- Wait 10-60 minutes for processing
- Check build completed successfully in Codemagic
- Verify upload succeeded (check build logs)
- Refresh App Store Connect page

### Can't Add Build to Testing

**If "+" button doesn't appear:**
- Make sure build status is **"Ready to Test"** (not "Processing")
- Wait for processing to complete
- Check email for completion notification

### Invitation Not Received

**If you don't get email:**
- Check spam folder
- Verify email address is correct
- Check App Store Connect → Users and Access → Your email
- Try adding tester again

### Can't Install from TestFlight

**If installation fails:**
- Make sure you're on iOS device (not simulator)
- Check iOS version meets minimum (13.0+)
- Try deleting and reinstalling TestFlight app
- Restart your iPhone/iPad

---

## Future Updates

**Automatic updates:**
- Push code to `main` branch
- Codemagic builds automatically
- New build appears in TestFlight
- Add to Internal Testing
- Testers get notified automatically
- They can update from TestFlight app

---

## Summary Checklist

- [ ] Encryption compliance key added to Info.plist ✅
- [ ] Build triggered and completed
- [ ] Build uploaded to App Store Connect
- [ ] Build processed (status: "Ready to Test")
- [ ] Build added to Internal Testing
- [ ] Testers added (including yourself)
- [ ] TestFlight app installed on iPhone/iPad
- [ ] Invitation accepted
- [ ] App installed and running! 🎉

---

**You're almost there!** Once the build processes and you add it to Internal Testing, you can install it on your phone!
