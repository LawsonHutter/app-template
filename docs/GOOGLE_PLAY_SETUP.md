# Google Play Deployment Setup

Guide to deploy your Android app to Google Play, including **Internal testing** (Google’s TestFlight-style track).

## Google Play Testing Tracks (Similar to TestFlight)

| Track | Testers | Review | Speed |
|-------|---------|--------|-------|
| **Internal testing** | Up to 100 | None | Live in seconds |
| **Closed testing** | Unlimited | Yes | Usually within hours |
| **Open testing** | Public | Yes | Usually within days |
| **Production** | Everyone | Yes | Full review |

**Internal testing** is the closest to TestFlight – no review, quick availability, and simple sharing via a link.

---

## Prerequisites

- **Google Play Developer account** ($25 one-time) – https://play.google.com/console
- **Backend live** – API reachable (e.g. `https://yourdomain.com/api/counter/`)

---

## Part 1: Create the App in Play Console

### 1.1 Create a new app

1. Go to https://play.google.com/console
2. Click **Create app**
3. **App name**: Your app name
4. **Default language**: English (or your choice)
5. **App or game**: App
6. **Free or paid**: Free
7. Accept declarations and create

### 1.2 Set up the app

Work through the left sidebar:

1. **App access** – Choose who can use the app (e.g. “All functionality available without restrictions” if fully open)
2. **Ads** – Does your app contain ads? Yes/No
3. **Content rating** – Complete questionnaire (e.g. select “Utility” for a simple app)
4. **Target audience** – Age groups
5. **News app** – No (unless it is)
6. **COVID-19** – No (unless it is)
7. **Data safety** – Describe what data you collect (or “No data collected” if applicable)

---

## Part 2: Build Your App Bundle (AAB)

### 2.1 Set Application ID

Update `frontend/android/app/build.gradle`:

```gradle
defaultConfig {
    applicationId = "com.yourdomain.yourapp"  // Must match Play Console app
    // ...
}
```

Use the same format as iOS (e.g. `com.dipoll.surveyapp`). This must be unique and unchanged once the app is on Play.

### 2.2 Build locally

```powershell
cd frontend
flutter pub get
flutter build appbundle --release --dart-define=API_BASE_URL=https://yourdomain.com/api/counter/
```

Output: `frontend/build/app/outputs/bundle/release/app-release.aab`

### 2.3 Signing

For internal testing you can start with **upload key signing** (Play App Signing). Create an upload keystore:

```powershell
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Create `frontend/android/key.properties` (add to `.gitignore`):

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```

Update `frontend/android/app/build.gradle` to use it (see Part 2.4 below).

---

## Part 3: Internal Testing

### 3.1 Create internal testing track

1. Play Console → Your app → **Testing** → **Internal testing**
2. Click **Create new release**
3. **Upload** your `.aab` file (drag & drop or browse)
4. Add release notes
5. **Save** → **Review release** → **Start rollout to Internal testing**

### 3.2 Add testers

1. On the **Internal testing** page, go to **Testers**
2. Click **Create email list**
3. Name it (e.g. “Internal testers”) and add emails
4. **Save**
5. Copy the **opt-in URL** and share it with testers

Testers click the link, accept the invitation, and can install the app from the Play Store.

---

## Part 4: Signing Configuration (Release Builds)

For release builds, configure signing in `frontend/android/app/build.gradle`:

```gradle
android {
    // ... existing config ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            // ...
        }
    }
}
```

At the top of the file, before `android {`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Without a `key.properties` file, `flutter build appbundle` uses the debug keystore. Play Console can accept that for internal testing, but you’ll be prompted to enroll in Play App Signing and use an upload key for production.

---

## Part 5: Optional – Codemagic Android Workflow

To build and upload automatically (similar to iOS), add an Android workflow to `codemagic.yaml`. You’ll need:

- **Google Play credentials** (service account JSON) in Codemagic
- Android workflow steps to build the AAB and publish to the internal testing track

See Codemagic’s [Flutter Android publishing docs](https://docs.codemagic.io/flutter-publishing/publishing-to-google-play/) for details.

---

## Quick Reference

| Item | Where |
|------|-------|
| Build output | `frontend/build/app/outputs/bundle/release/app-release.aab` |
| Application ID | `frontend/android/app/build.gradle` → `applicationId` |
| API URL | `--dart-define=API_BASE_URL=https://...` when building |
| Internal testing | Play Console → Testing → Internal testing |
| Tester link | Internal testing → Testers → opt-in URL |

---

## Troubleshooting

**“You need to use a different package name”**  
Change `applicationId` in `build.gradle`; it must be unique across Play Store.

**“App not signed”**  
Create a keystore and `key.properties`, and configure `signingConfigs.release` in `build.gradle`.

**“Version code must be greater than X”**  
Increment `versionCode` in `pubspec.yaml` (or `build.gradle`) for each new upload.
