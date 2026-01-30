# Android Emulator Setup for Flutter

This guide shows you how to set up an Android emulator that works with Flutter development in Cursor.

## Prerequisites

1. **Android Studio** - [Download](https://developer.android.com/studio)
2. **Flutter SDK** - Already installed (part of project setup)

## Step 1: Install Android Studio

1. Download Android Studio from https://developer.android.com/studio
2. Run the installer
3. During setup, make sure to install:
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device (AVD)

## Step 2: Configure Flutter to Use Android Studio

1. Open a terminal/PowerShell
2. Run Flutter doctor to check setup:
   ```powershell
   flutter doctor
   ```
3. If Android toolchain shows issues, run:
   ```powershell
   flutter doctor --android-licenses
   ```
   (Accept all licenses by typing `y`)

## Step 3: Create an Android Emulator

### Option A: Using Android Studio GUI (Recommended)

1. **Open Android Studio**
2. **Open Device Manager:**
   - Click "More Actions" (three dots) → "Virtual Device Manager"
   - Or: Tools → Device Manager
3. **Create Device:**
   - Click "Create Device" button
   - Select a device (e.g., "Pixel 5" or "Pixel 6")
   - Click "Next"
4. **Select System Image:**
   - Choose a system image (e.g., "Tiramisu" API 33 or "UpsideDownCake" API 34)
   - If you see "Download" next to an image, click it to download
   - Click "Next"
5. **Finish Setup:**
   - Review the configuration
   - Click "Finish"
   - The emulator will appear in your device list

### Option B: Using Command Line

1. **List available system images:**
   ```powershell
   flutter emulators
   ```
   Or:
   ```powershell
   sdkmanager --list | findstr "system-images"
   ```

2. **Create emulator via command line:**
   ```powershell
   # First, install a system image (if needed)
   sdkmanager "system-images;android-33;google_apis;x86_64"
   
   # Create AVD
   avdmanager create avd -n "pixel_5_api_33" -k "system-images;android-33;google_apis;x86_64" -d "pixel_5"
   ```

## Step 4: Verify Emulator Setup

1. **List available emulators:**
   ```powershell
   flutter emulators
   ```
   You should see your emulator listed.

2. **Launch emulator manually (optional):**
   ```powershell
   flutter emulators --launch <emulator_id>
   ```
   Or from Android Studio: Click the ▶️ play button next to your emulator.

3. **Check if Flutter detects it:**
   ```powershell
   flutter devices
   ```
   You should see your emulator listed as "emulator-xxxx" or similar.

## Step 5: Use with Cursor/Flutter

Once the emulator is set up, you can:

1. **Use the provided script (recommended):**
   ```powershell
   .\scripts\start-android.ps1
   ```
   This starts the backend, launches your Flutter emulator if needed, and runs your app.

2. **Or run Flutter directly:**
   ```powershell
   cd frontend
   flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/counter/
   ```

## Troubleshooting

### "No emulators found"
- Make sure you've created at least one emulator in Android Studio
- Run `flutter emulators` to verify it's detected
- Try launching the emulator manually from Android Studio first

### "Android toolchain not found"
- Make sure Android Studio is installed
- Run `flutter doctor` to see what's missing
- Install Android SDK Platform Tools from Android Studio SDK Manager

### "Emulator won't start"
- Make sure virtualization is enabled in BIOS (Intel VT-x or AMD-V)
- Check Windows Hyper-V settings (may conflict with Android emulator)
- Try a different system image (x86_64 instead of arm64)

### "Flutter can't find Android SDK"
- Set ANDROID_HOME environment variable:
  ```powershell
  # Usually located at:
  $env:ANDROID_HOME = "C:\Users\YourUsername\AppData\Local\Android\Sdk"
  ```
- Or add to System Environment Variables permanently

### Emulator is slow
- Enable hardware acceleration in BIOS
- Allocate more RAM to the emulator (in AVD settings)
- Use a lighter system image (x86_64 instead of arm64)

## Quick Reference

**List emulators:**
```powershell
flutter emulators
```

**Launch specific emulator:**
```powershell
flutter emulators --launch <emulator_id>
```

**List running devices:**
```powershell
flutter devices
```

**Run app on Android:**
```powershell
cd frontend
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/counter/
```

**Use the convenience script:**
```powershell
.\scripts\start-android.ps1
```

## Next Steps

Once your emulator is set up:
1. ✅ Run `.\scripts\start-android.ps1` to test
2. ✅ The app should launch on the emulator
3. ✅ Backend should be accessible at `http://10.0.2.2:8000`

For more help, see `INIT_SETUP.md` in the project root.
