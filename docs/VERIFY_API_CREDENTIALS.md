# Verify App Store Connect API Credentials

## Your Credentials (from App Store Connect)

✅ **Issuer ID**: `YOUR_ISSUER_ID`
✅ **Key ID**: `YOUR_KEY_ID`
✅ **Private Key**: (shown below - must include BEGIN/END lines)

```
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgMMAkWvmi/skcLZEN
i9xKqVmCrx+1ewf9f8oloy9zuVugCgYIKoZIzj0DAQehRANCAARiQKerUDpBe8se
S3Tb/Tjj2tpg7FEB2Gq5vIBgXOPRkkv+l0WZwnVklwk2tcYm7LM7qSVGI6A2Advj
/OhhZfop
-----END PRIVATE KEY-----
```

---

## Step-by-Step: Add to Codemagic

### Step 1: Go to Codemagic Environment Variables

1. Go to https://codemagic.io
2. Click on your app
3. Go to **Settings** → **Environment variables**
4. Look for group `app_store_credentials`
   - If it doesn't exist, create it (click "Add group" or similar)

### Step 2: Add Variable 1 - Issuer ID

1. Click **Add variable** (or **+** button)
2. Fill in:
   - **Name**: `APP_STORE_CONNECT_ISSUER_ID` (exact, case-sensitive)
   - **Value**: `YOUR_ISSUER_ID`
   - **Group**: `app_store_credentials` (select from dropdown or create)
   - **Secure**: ✅ Check this box (recommended)
3. Click **Add** or **Save**

### Step 3: Add Variable 2 - Key ID

1. Click **Add variable** again
2. Fill in:
   - **Name**: `APP_STORE_CONNECT_KEY_IDENTIFIER` (exact, case-sensitive)
   - **Value**: `YOUR_KEY_ID`
   - **Group**: `app_store_credentials`
   - **Secure**: ✅ Check this box (recommended)
3. Click **Add** or **Save**

### Step 4: Add Variable 3 - Private Key

**Important**: The private key is text (PEM format), NOT a binary file. You do NOT need to base64-encode it.

1. Click **Add variable** again
2. Fill in:
   - **Name**: `APP_STORE_CONNECT_PRIVATE_KEY` (exact, case-sensitive)
   - **Value**: Copy the **ENTIRE** private key as plain text, including BEGIN/END lines:
     ```
     -----BEGIN PRIVATE KEY-----
     MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgMMAkWvmi/skcLZEN
     i9xKqVmCrx+1ewf9f8oloy9zuVugCgYIKoZIzj0DAQehRANCAARiQKerUDpBe8se
     S3Tb/Tjj2tpg7FEB2Gq5vIBgXOPRkkv+l0WZwnVklwk2tcYm7LM7qSVGI6A2Advj
     /OhhZfop
     -----END PRIVATE KEY-----
     ```
   - **Group**: `app_store_credentials`
   - **Secure**: ✅ Check this box (required!)
   - **Important**: 
     - Include the `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----` lines
     - Paste as plain text (not base64-encoded)
     - Include all lines between BEGIN and END
3. Click **Add** or **Save**

**Note**: Codemagic's message about base64-encoding applies to binary files. The private key (.p8 file) is actually a text file in PEM format, so paste it directly as text.

---

## Verification Checklist

After adding all 3 variables, verify:

- [ ] All 3 variables exist in group `app_store_credentials`
- [ ] Variable names are EXACT (case-sensitive):
  - `APP_STORE_CONNECT_ISSUER_ID`
  - `APP_STORE_CONNECT_KEY_IDENTIFIER`
  - `APP_STORE_CONNECT_PRIVATE_KEY`
- [ ] Issuer ID value: `YOUR_ISSUER_ID`
- [ ] Key ID value: `YOUR_KEY_ID`
- [ ] Private Key includes `-----BEGIN PRIVATE KEY-----` at start
- [ ] Private Key includes `-----END PRIVATE KEY-----` at end
- [ ] Private Key includes all lines in between
- [ ] Group name is `app_store_credentials` (matches `codemagic.yaml`)

---

## Common Mistakes

### ❌ Wrong Variable Names
- `APP_STORE_CONNECT_ISSUER_ID` ✅
- `app_store_connect_issuer_id` ❌ (wrong case)
- `APP_STORE_ISSUER_ID` ❌ (missing CONNECT)

### ❌ Wrong Group Name
- `app_store_credentials` ✅ (matches codemagic.yaml)
- `appstore_credentials` ❌ (missing underscore)
- `app_store_connect` ❌ (wrong name)

### ❌ Private Key Format Issues
- Missing `-----BEGIN PRIVATE KEY-----` ❌
- Missing `-----END PRIVATE KEY-----` ❌
- Extra spaces or line breaks ❌
- Only partial key content ❌

### ❌ Values in Wrong Variables
- Issuer ID in Key ID field ❌
- Key ID in Issuer ID field ❌

---

## Test After Adding

1. **Trigger a new build:**
   ```powershell
   git commit --allow-empty -m "Test API credentials"
   git push origin main
   ```

2. **Check build logs** for "Verify App Store Connect credentials" step:
   - ✅ Should see: "✅ All App Store Connect credentials are set"
   - ❌ If you see errors, fix the missing/incorrect variable

3. **Check Publishing section** for upload messages:
   - ✅ Should see: "Uploading to App Store Connect..."
   - ✅ Should see: "Successfully uploaded to App Store Connect"

---

## If Still Not Working

### Check Build Logs

Look for these messages:

**✅ Success:**
```
Verify App Store Connect credentials
✅ All App Store Connect credentials are set
Issuer ID: 187efa47...
Key ID: YOUR_KEY_ID
```

**❌ Failure:**
```
❌ APP_STORE_CONNECT_ISSUER_ID is not set
❌ APP_STORE_CONNECT_KEY_IDENTIFIER is not set
❌ APP_STORE_CONNECT_PRIVATE_KEY is not set
```

### Verify Group Name

In `codemagic.yaml`, the group is:
```yaml
groups:
  - app_store_credentials
```

Make sure the group name in Codemagic UI matches exactly.

### Re-add Credentials

If unsure, delete and re-add all 3 variables:
1. Delete existing variables
2. Re-add them one by one
3. Double-check values
4. Trigger new build

---

## Quick Copy-Paste Values

### Variable 1: APP_STORE_CONNECT_ISSUER_ID
```
YOUR_ISSUER_ID
```

### Variable 2: APP_STORE_CONNECT_KEY_IDENTIFIER
```
YOUR_KEY_ID
```

### Variable 3: APP_STORE_CONNECT_PRIVATE_KEY
```
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgMMAkWvmi/skcLZEN
i9xKqVmCrx+1ewf9f8oloy9zuVugCgYIKoZIzj0DAQehRANCAARiQKerUDpBe8se
S3Tb/Tjj2tpg7FEB2Gq5vIBgXOPRkkv+l0WZwnVklwk2tcYm7LM7qSVGI6A2Advj
/OhhZfop
-----END PRIVATE KEY-----
```

---

**After adding these, trigger a new build and check the logs!**
