# Codemagic Environment Variables - Important Notes

## About Base64 Encoding

Codemagic shows this message:
> "Note that binaries need to be base64-encoded before they can be saved to environment variables."

**For App Store Connect API credentials, you do NOT need base64 encoding.**

### Why?

1. **Issuer ID**: Plain text (UUID format) - no encoding needed
2. **Key ID**: Plain text (alphanumeric) - no encoding needed  
3. **Private Key (.p8 file)**: Text file in PEM format - no encoding needed

The `.p8` file is **not a binary file** - it's a text file containing the private key in PEM (Privacy-Enhanced Mail) format. You can open it in any text editor.

### When DO You Need Base64 Encoding?

Base64 encoding is only needed for actual binary files like:
- Images (.png, .jpg)
- Executables (.exe, .bin)
- Archives (.zip, .tar)
- Certificates in binary format (.cer, .p12)

### For App Store Connect API Key

**✅ Correct**: Paste the private key as plain text:
```
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgMMAkWvmi/skcLZEN
...
-----END PRIVATE KEY-----
```

**❌ Wrong**: Don't base64-encode it:
```
LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0t...
```

---

## How to Add Environment Variables in Codemagic

### Step 1: Navigate to Environment Variables

1. Go to https://codemagic.io
2. Click on your app
3. Go to **Settings** → **Environment variables**

### Step 2: Create Group (If Needed)

1. Click **Add group** or **Create group**
2. Name it: `app_store_credentials`
3. Save

### Step 3: Add Variables

For each variable:

1. Click **Add variable** (or **+** button)
2. Fill in:
   - **Name**: Exact variable name (case-sensitive)
   - **Value**: The value (plain text, no encoding)
   - **Group**: Select `app_store_credentials`
   - **Secure**: ✅ Check this (hides value in UI)
3. Click **Add** or **Save**

---

## Variable Access in Scripts

Codemagic's message says:
> "You can access these variables in your code by adding the $ symbol in front of the variable name."

**For App Store Connect publishing**, you don't need to use `$` in scripts because:

1. **Using `auth: integration`**: Codemagic automatically uses environment variables from the group
2. **No script access needed**: The `app_store_connect` publishing section handles it automatically

### When You WOULD Use `$` in Scripts

If you wanted to access variables in build scripts:

```yaml
scripts:
  - name: Echo variable
    script: |
      echo "Issuer ID: $APP_STORE_CONNECT_ISSUER_ID"
      echo "Key ID: $APP_STORE_CONNECT_KEY_IDENTIFIER"
```

But for TestFlight upload, you don't need this - Codemagic handles it automatically.

---

## Complete Setup for App Store Connect

### Required Variables

All in group `app_store_credentials`:

1. **APP_STORE_CONNECT_ISSUER_ID**
   - Value: `187efa47-e5eb-4d34-8a00-e50fc4825b69`
   - Format: Plain text (UUID)

2. **APP_STORE_CONNECT_KEY_IDENTIFIER**
   - Value: `S67R9DU7BU`
   - Format: Plain text (alphanumeric)

3. **APP_STORE_CONNECT_PRIVATE_KEY**
   - Value: Entire PEM-formatted key (with BEGIN/END lines)
   - Format: Plain text (PEM format)
   - **No base64 encoding needed!**

### Configuration in codemagic.yaml

```yaml
environment:
  groups:
    - app_store_credentials  # Matches group name in Codemagic UI

publishing:
  app_store_connect:
    auth: integration  # Automatically uses variables from group
    submit_to_testflight: true
```

---

## Verification

After adding variables:

1. **Check variable names**: Must match exactly (case-sensitive)
2. **Check group name**: Must be `app_store_credentials`
3. **Check values**: 
   - Issuer ID: Full UUID
   - Key ID: Full key identifier
   - Private Key: Includes BEGIN/END lines, all content between

4. **Test in build**: 
   - Trigger a build
   - Check "Verify App Store Connect credentials" step
   - Should show: "✅ All App Store Connect credentials are set"

---

## Troubleshooting

### Variable Not Found

**Error**: `❌ APP_STORE_CONNECT_XXX is not set`

**Fix**:
- Check variable name is exact (case-sensitive)
- Check group name matches `app_store_credentials`
- Verify variable exists in Codemagic UI

### Upload Still Fails

**Even with credentials set**:

1. Check app exists in App Store Connect
2. Verify Bundle ID matches: `com.dipoll.surveyapp`
3. Check API key has **Admin** or **App Manager** access
4. Verify API key is active (not revoked)

---

## Summary

- ✅ **No base64 encoding** needed for App Store Connect credentials
- ✅ **Paste private key as plain text** (PEM format)
- ✅ **Use `auth: integration`** in codemagic.yaml (automatic variable access)
- ✅ **Group name must match**: `app_store_credentials`
- ✅ **Variable names must be exact** (case-sensitive)

**The private key is text, not binary - paste it directly!**
