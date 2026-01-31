# Codemagic + TestFlight Setup

Step-by-step guide to set up automatic iOS builds and TestFlight deployment.

## Prerequisites

- **Apple Developer Account** ($99/year) – https://developer.apple.com/programs/
- **Codemagic account** (free tier: 500 build min/month) – https://codemagic.io
- **Backend live** – Your API must be reachable (e.g. `https://yourdomain.com/api/counter/`)

---

## Part 1: Apple & App Store Connect

### 1.1 Register App ID (Bundle ID)

1. Go to https://developer.apple.com/account/resources/identifiers/list
2. Click **+** → **App IDs** → **App** → Continue
3. **Description**: Your app name  
4. **Bundle ID**: Explicit → `com.yourdomain.yourapp` (e.g. `com.lawsonhutter.counterapp`)
5. Continue → Register

### 1.2 Create App Store Connect API Key

1. Go to https://appstoreconnect.apple.com → **Users and Access** → **Keys** (App Store Connect API)
2. **+** to create a key
3. **Name**: Codemagic (or similar)
4. **Access**: App Manager or Admin
5. Create → Download the `.p8` file once (you can’t download it again)
6. Note:
   - **Key ID** (e.g. `S67R9DU7BU`)
   - **Issuer ID** (at top of Keys page, e.g. `187efa47-e5eb-4d34-8a00-e50fc4825b69`)

### 1.3 Create App in App Store Connect

1. Go to https://appstoreconnect.apple.com → **My Apps** → **+** → **New App**
2. Platform: iOS  
3. Name, language, Bundle ID (select the one you registered)
4. SKU: unique ID (e.g. `counter-app-001`)
5. Create

---

## Part 2: Codemagic

### 2.1 Connect Repository

1. Go to https://codemagic.io → **Add application**
2. Choose **GitHub** and authorize
3. Select your repo
4. Project type: **Flutter** (Codemagic auto-detects `frontend/`)

### 2.2 Environment Variables

1. Your app → **Settings** → **Environment variables**
2. Create group: `app_store_credentials`
3. Add (all **Secure** checked):

| Name | Value |
|------|--------|
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID from step 1.2 |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | Key ID from step 1.2 |
| `APP_STORE_CONNECT_PRIVATE_KEY` | Entire `.p8` file content (with BEGIN/END lines) |
| `API_BASE_URL` | `https://yourdomain.com/api/counter/` |

**Note:** Paste the `.p8` content as plain text; do not base64-encode it.

### 2.3 App Store Connect Integration (for automatic code signing)

Codemagic needs the API key registered as an **integration** and the workflow must reference it. This is separate from environment variables.

1. In Codemagic: **Teams** → **Personal Account** (or your team) → **Integrations**
2. Find **Developer Portal** or **App Store Connect** → **Connect**
3. Fill in:
   - **Integration name**: Use **App Store Connect** (must match `integrations.app_store_connect` in `codemagic.yaml`)
   - **Issuer ID**: From step 1.2 (UUID format)
   - **Key ID**: From step 1.2 (alphanumeric)
   - **Private key**: Upload your `.p8` file, or paste its full contents
4. **Save**

If your app is under a team, use **Team integrations** instead so the integration is shared. The key must have **App Manager** or **Admin** access to create provisioning profiles.

**Important:** In `codemagic.yaml`, `integrations.app_store_connect` must be the exact integration name you set above (e.g. `App Store Connect`). If you used a different name, change it in the YAML to match.

### 2.4 Code Signing

1. **Settings** → **Code signing**
2. **Automatic code signing**
3. **Distribution certificate**: Use the App Store Connect integration you created in 2.3
4. **Bundle ID**: Same as `APP_ID` (e.g. `com.lawsonhutter.counterapp`)

### 2.5 Update codemagic.yaml

**Option A – Use the config script (recommended)**

1. In `security/deployment.config`, set:
   ```
   DOMAIN=yourdomain.com
   USE_HTTPS=true
   APP_ID=com.yourdomain.yourapp
   CODEMAGIC_EMAIL=your@email.com
   ```
2. Run:
   ```powershell
   .\scripts\update-codemagic-config.ps1
   ```

**Option B – Edit codemagic.yaml manually**

Update `API_BASE_URL`, `APP_ID`, and the email under `publishing.email.recipients`.

Then commit and push.

### 2.6 Enable Auto-Builds (Optional)

1. **Settings** → **Build triggers**
2. Enable **Automatic builds**
3. Branch: `main`
4. Paths (optional): `frontend/**`, `codemagic.yaml`

The repo’s `codemagic.yaml` already triggers on push to `main` when `frontend/` or `codemagic.yaml` change.

### 2.7 Disable Android Workflow (Optional)

To avoid long build times, only build iOS. If Codemagic auto-created an Android workflow:
1. **Settings** → **Workflows**
2. Disable or delete the Android workflow
3. Keep only **iOS Workflow** enabled

---

## Part 3: First Build

1. Codemagic → Your app → **Start new build**
2. Branch: `main`
3. Workflow: **iOS Workflow**
4. **Start new build**

Builds usually take 10–20 minutes. On success, the build is uploaded to TestFlight.

---

## Part 4: TestFlight

1. App Store Connect → Your app → **TestFlight**
2. Wait for the build to finish processing (often 10–60 minutes)
3. **Internal Testing** → **+** → Add testers (up to 100, no review)
4. Or **External Testing** → **+** → Add testers (up to 10,000, requires review)

---

## Quick Reference

| Item | Where |
|------|-------|
| API URL | `codemagic.yaml` vars, or Codemagic env var `API_BASE_URL` |
| Bundle ID | `codemagic.yaml` `APP_ID`, iOS project, App Store Connect |
| API credentials (env) | Codemagic → Settings → Environment variables → `app_store_credentials` |
| API key for code signing | Codemagic → Teams → Integrations → Developer Portal / App Store Connect |
| Build logs | Codemagic → Build → Logs |
| TestFlight | App Store Connect → My Apps → [App] → TestFlight |

---

## Troubleshooting

**"No valid code signing certificates" / "Did not find matching provisioning profiles"**  
1. **Create the integration** (most common fix): **Teams** → **Integrations** → **Developer Portal** or **App Store Connect** → **Connect**. Add Issuer ID, Key ID, upload `.p8`. Name it **App Store Connect** (must match `integrations.app_store_connect` in `codemagic.yaml`).  
2. **Same team:** If the app is under a Codemagic team, the integration must be under **Team integrations** (not Personal).  
3. **API key permissions:** The App Store Connect API key needs **App Manager** or **Admin** access so Codemagic can create provisioning profiles’s Bundle ID.  
4. **Bundle ID in Apple:** Register the Bundle ID at [developer.apple.com/identifiers](https://developer.apple.com/account/resources/identifiers/list) and create an app in App Store Connect with that exact Bundle ID.  
5. **Consistency:** `APP_ID`, `ios_signing.bundle_identifier`, and the iOS project must all use the same Bundle ID.

**Upload fails – “App doesn’t exist”**  
Create the app in App Store Connect (Part 1.3) with the same Bundle ID.

**Code signing errors**  
Ensure Bundle ID matches everywhere: `codemagic.yaml`, iOS project, App Store Connect, `ios_signing.bundle_identifier`.

**API connection errors in app**  
Use your real HTTPS API URL in `API_BASE_URL` (e.g. `https://lawsonhutter.com/api/counter/`).

**Credentials not found**  
Verify variable names and group `app_store_credentials` exactly match what `codemagic.yaml` expects.

