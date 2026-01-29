# AWS EC2 Launch Instance - Step by Step Guide

This guide walks you through launching your EC2 instance for the counter app.

## Current Step: Step 2 - Select AMI

### ❌ What You Have Selected (Wrong)
- **AMI**: Microsoft Windows Server 2025
- **Why wrong**: Windows doesn't work well with Docker for this setup, and you'd need to install Docker differently

### ✅ What You Should Select

**In the Quick Start section, click "Ubuntu"**

Then select:
- **Ubuntu Server 22.04 LTS** (or latest)
- Look for: "Free tier eligible"
- Architecture: **64-bit (x86)**
- AMI ID will be something like: `ami-0c55b159cbfafe1f0` (varies by region)

**Why Ubuntu?**
- Best support for Docker
- Free tier eligible
- Easy to set up
- Most tutorials use Ubuntu

---

## Step-by-Step Configuration

### Step 1: Name and Tags ✅ (You've done this)
- **Name**: `survey-app` ✅

### Step 2: Application and OS Images (AMI) ⚠️ **CHANGE THIS**

**Action**: 
1. Click **"Ubuntu"** in Quick Start (left sidebar)
2. Select **"Ubuntu Server 22.04 LTS"** (or latest)
3. Make sure it says "Free tier eligible"

### Step 3: Instance Type ✅ (Good choice)
- **Instance type**: `t3.micro` ✅
- Free tier eligible
- 2 vCPU, 1 GiB RAM
- Perfect for this app

### Step 4: Key Pair (Login) ⚠️ **DO THIS**

**Action**:
1. Click **"Create new key pair"**
2. **Key pair name**: `survey-app-key` (or any name you like)
3. **Key pair type**: **RSA** (default)
4. **Private key file format**: **.pem** (for Linux/Ubuntu)
5. Click **"Create key pair"**
6. **IMPORTANT**: The `.pem` file will download automatically - **SAVE THIS FILE SECURELY!**
   - You'll need it to SSH into your server
   - Store it in a safe place (e.g., `C:\Users\Lawson\.ssh\survey-app-key.pem`)

**⚠️ Warning**: If you lose this file, you won't be able to connect to your instance!

### Step 5: Network Settings ⚠️ **CONFIGURE THIS**

**Current settings** (you can keep these):
- **Network**: Default VPC (vpc-08f97f72f709a54cb) ✅
- **Subnet**: No preference ✅
- **Auto-assign public IP**: **Enable** ✅ (IMPORTANT - you need this!)

**Firewall (Security Group)** - **Click "Edit"**:

**Current rules** (you have Windows rules - we need Linux rules):
- ❌ Remove: "Allow RDP traffic" (that's for Windows)
- ✅ Add: "Allow SSH traffic from" → **My IP** (safer) or **Anywhere** (0.0.0.0/0) for now
- ✅ Add: "Allow HTTPS traffic from the internet" → **Anywhere** (0.0.0.0/0)
- ✅ Add: "Allow HTTP traffic from the internet" → **Anywhere** (0.0.0.0/0)

**Security Group Rules Summary**:
```
Type          Protocol  Port Range  Source
SSH           TCP       22          My IP (or 0.0.0.0/0)
HTTP          TCP       80          0.0.0.0/0
HTTPS         TCP       443         0.0.0.0/0
```

**Security Group Name**: `survey-app-sg` (or any name)

### Step 6: Configure Storage ✅ (Default is fine)

**Current**: 30 GiB gp3 ✅
- This is fine for your app
- Free tier includes 30 GB
- You can increase later if needed

### Step 7: Advanced Details (Skip for now)

Leave defaults - you can configure later.

### Step 8: Review and Launch

**Before clicking "Launch instance"**:
1. ✅ Review all settings
2. ✅ Make sure AMI is **Ubuntu** (not Windows)
3. ✅ Make sure key pair is created/downloaded
4. ✅ Security group has SSH, HTTP, HTTPS

**Click "Launch instance"**

---

## After Launch

### 1. Note Your Instance Details

After launching, you'll see:
- **Instance ID**: `i-xxxxxxxxxxxxx`
- **Public IPv4 address**: `xx.xx.xx.xx` (this is your server IP!)
- **Status**: "pending" → "running" (takes 1-2 minutes)

### 2. Connect to Your Instance

**On Windows (PowerShell)**:

```powershell
# Navigate to where you saved the .pem file
cd C:\Users\Lawson\.ssh  # or wherever you saved it

# Set correct permissions (Windows may not need this, but try)
icacls survey-app-key.pem /inheritance:r

# Connect via SSH
ssh -i survey-app-key.pem ubuntu@your-ec2-ip-address
```

**First time connecting**:
- You'll see a warning about authenticity - type `yes`
- You're now connected to your Ubuntu server!

### 3. Next Steps (After Connecting)

Once connected, follow the EC2 deployment guide:
- See `docs/DEPLOY_AWS.md` → "AWS EC2 (Full Control Method)"
- Install Docker
- Deploy your app

---

## Quick Reference Checklist

Before clicking "Launch instance", verify:

- [ ] **AMI**: Ubuntu Server 22.04 LTS (NOT Windows)
- [ ] **Instance type**: t3.micro
- [ ] **Key pair**: Created and .pem file downloaded
- [ ] **Security group**: SSH (22), HTTP (80), HTTPS (443)
- [ ] **Public IP**: Enabled
- [ ] **Storage**: 30 GiB (default is fine)

---

## Common Mistakes to Avoid

1. ❌ **Don't select Windows** - Use Ubuntu
2. ❌ **Don't forget to download the .pem file** - You can't get it again!
3. ❌ **Don't forget to enable public IP** - You need this to connect
4. ❌ **Don't forget security group rules** - Need SSH, HTTP, HTTPS

---

## Need Help?

If you get stuck:
1. Check `docs/DEPLOY_AWS.md` for detailed EC2 setup
2. AWS Console → EC2 → Instances → Your instance → "Connect" button (has instructions)

Good luck! 🚀
