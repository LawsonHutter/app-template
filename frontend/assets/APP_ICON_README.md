# App Icon & Launch Screen

Add your app logo as **app_icon.png** (1024x1024 px, no transparency for App Store) in this folder.

From the frontend directory, run:
```powershell
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

This generates iOS/Android/web app icons and replaces the default launch/splash screen. Codemagic runs both automatically before each build.
