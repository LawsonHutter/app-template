# Fix: "Error connecting to backend localhost" on iOS Device

## Problem

Your app is trying to connect to `http://localhost:8000` which doesn't work on a real iOS device.

**Why?**
- `localhost` on a device refers to the device itself, not your server
- You need to use your actual backend URL: `https://your-app-name.net`

---

## ✅ Fix Applied

I've updated the default API URL in your code:

**Before:**
```dart
defaultValue: 'http://localhost:8000/api/counter/',
```

**After:**
```dart
defaultValue: 'https://your-app-name.net/api/counter/',
```

---

## Verify Your Backend is Running

Before testing, make sure your backend is accessible:

1. **Check backend is running**:
   - Go to https://your-app-name.net/api/counter/
   - Should see a response (even if it's an error, it means backend is reachable)

2. **Check CORS settings**:
   - Backend must allow requests from your iOS app
   - Update `CORS_ALLOWED_ORIGINS` in backend settings

---

## For Local Development

If you want to test locally on a simulator:

1. **Use your computer's IP address** instead of localhost:
   ```dart
   // Find your IP: ipconfig (Windows) or ifconfig (Mac/Linux)
   // Example: 'http://192.168.1.100:8000/api/counter/'
   ```

2. **Or use a development build** with different URL:
   ```powershell
   flutter run --dart-define=API_BASE_URL=http://YOUR_IP:8000/api/counter/
   ```

---

## For Production/TestFlight

The app will now use `https://your-app-name.net/api/counter/` by default.

**Codemagic build** also passes the URL:
```yaml
--dart-define=API_BASE_URL="https://your-app-name.net/api/counter/"
```

---

## Update Backend CORS (If Needed)

If you get CORS errors, update your backend settings:

**In `backend/survey_backend/settings.py`:**

```python
CORS_ALLOWED_ORIGINS = [
    "https://your-app-name.net",
    "http://localhost:3000",  # For local web testing
    # Add your iOS app bundle ID if needed
]

# Or allow all origins (less secure, for testing)
# CORS_ALLOW_ALL_ORIGINS = True
```

---

## Test the Fix

1. **Push the updated code**:
   ```powershell
   git add frontend/lib/survey_screen.dart
   git commit -m "Fix API URL to use production backend instead of localhost"
   git push origin main
   ```

2. **Wait for new build** in Codemagic

3. **Install new build** from TestFlight

4. **Test the app** - should now connect to `https://your-app-name.net`

---

## Troubleshooting

### Still Getting Connection Error

**Check:**
1. Backend is running: https://your-app-name.net/api/counter/
2. Backend allows CORS from iOS app
3. Network connectivity on device
4. SSL certificate is valid (for HTTPS)

### CORS Errors

**Symptoms**: "CORS policy" errors in logs

**Fix**: Update `CORS_ALLOWED_ORIGINS` in backend settings

### SSL Certificate Errors

**Symptoms**: Certificate validation errors

**Fix**: 
- Ensure backend has valid SSL certificate
- Or temporarily allow insecure connections (not recommended for production)

---

## Quick Checklist

- [ ] Default API URL updated to `https://your-app-name.net/api/counter/` ✅
- [ ] Backend is running and accessible
- [ ] CORS settings allow iOS app
- [ ] New build created with fix
- [ ] App installed from TestFlight
- [ ] Connection works! 🎉

---

**The fix is applied!** Push the code and rebuild to get the updated API URL.
