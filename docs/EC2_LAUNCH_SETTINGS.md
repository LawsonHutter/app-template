# EC2 Launch Settings for Public Web & App Store App

Recommended settings when launching your EC2 instance for a public application.

## ✅ Current Settings (Good)

- **Name**: `counter-app` ✓
- **AMI**: Ubuntu Server 24.04 LTS ✓ (or 22.04 LTS - both work)
- **Instance type**: `t3.micro` ✓ (free tier eligible, good for starting)
- **Auto-assign public IP**: Enable ✓ (required for public access)
- **Network**: Default VPC ✓

## ⚠️ Settings to Change

### 1. Key Pair (REQUIRED - Do This First!)

**Action**: Click **"Create new key pair"**

**Settings:**
- **Key pair name**: `counter-app-key` (or any name you prefer)
- **Key pair type**: **RSA** (default)
- **Private key file format**: **.pem** (for Linux/Ubuntu)
- Click **"Create key pair"**

**⚠️ IMPORTANT**: 
- The `.pem` file will download automatically
- **SAVE THIS FILE SECURELY!** You cannot download it again
- Recommended location: `C:\Users\Lawson\Desktop\Github\app-template\security\counter-app-key.pem`
- Create the `security` folder if it doesn't exist

**Why**: You need this to SSH into your server and run deployment scripts.

---

### 2. Security Group (IMPORTANT - Security)

**Current**: SSH from "Anywhere" (0.0.0.0/0) - **NOT RECOMMENDED**

**Action**: Click **"Edit"** in Network settings → Firewall section

**Recommended Rules:**

| Type | Protocol | Port | Source | Why |
|------|----------|------|--------|-----|
| **SSH** | TCP | 22 | **My IP** | Secure access (only from your computer) |
| **HTTP** | TCP | 80 | **Anywhere** (0.0.0.0/0) | Public web access |
| **HTTPS** | TCP | 443 | **Anywhere** (0.0.0.0/0) | Secure web access |

**How to set "My IP":**
1. Click the dropdown next to SSH source
2. Select **"My IP"** (AWS automatically detects your IP)
3. Or manually enter your IP if "My IP" doesn't work

**Why restrict SSH?**
- SSH from "Anywhere" allows anyone to try to hack your server
- Restricting to "My IP" means only you can SSH in
- HTTP/HTTPS must be open for public web access

**Note**: If your IP changes (e.g., different network), you can update the security group later in AWS Console.

---

### 3. Storage (Increase Size)

**Current**: 8 GiB - **TOO SMALL**

**Action**: Click **"Edit"** in Configure storage section

**Recommended:**
- **Size**: **20-30 GiB** (free tier includes 30 GB)
- **Volume type**: **gp3** (default, good)
- **IOPS**: 3000 (default, fine)
- **Encryption**: Optional (can enable later)

**Why more storage?**
- Docker images take ~2-3 GB
- Flutter build artifacts: ~1-2 GB
- PostgreSQL database: ~1-2 GB
- System files: ~5-8 GB
- Logs and temporary files: ~2-3 GB
- **Total needed**: ~15-20 GB minimum
- **Recommended**: 30 GB for safety and growth

**Cost**: Free tier includes 30 GB, so no extra cost!

---

### 4. Advanced Details (Optional but Recommended)

Click **"Advanced details"** to expand:

**User data** (optional - can skip):
```bash
#!/bin/bash
# This runs on first boot
apt-get update
apt-get upgrade -y
```

**Or leave empty** - you'll run `setup-ec2.ps1` script after launch.

---

## 📋 Final Checklist Before Launch

Before clicking **"Launch instance"**, verify:

- [ ] **Key pair**: Created and `.pem` file downloaded and saved
- [ ] **Security group**: 
  - [ ] SSH (22) from **"My IP"** (not "Anywhere")
  - [ ] HTTP (80) from **"Anywhere"** (0.0.0.0/0)
  - [ ] HTTPS (443) from **"Anywhere"** (0.0.0.0/0)
- [ ] **Storage**: Increased to **20-30 GiB** (not 8 GiB)
- [ ] **AMI**: Ubuntu Server 24.04 LTS (or 22.04 LTS)
- [ ] **Instance type**: t3.micro (free tier eligible)
- [ ] **Auto-assign public IP**: Enable

---

## 🚀 After Launch

### 1. Note Your Instance Details

After launching, you'll see:
- **Instance ID**: `i-xxxxxxxxxxxxx`
- **Public IPv4 address**: `xx.xx.xx.xx` ← **Save this!**
- **Status**: "pending" → "running" (takes 1-2 minutes)

### 2. Move Your Key File

Move the downloaded `.pem` file to your project:

```powershell
# Create security folder if it doesn't exist
New-Item -ItemType Directory -Force -Path "C:\Users\Lawson\Desktop\Github\app-template\security"

# Move the key file (adjust path to where it downloaded)
Move-Item -Path "$env:USERPROFILE\Downloads\counter-app-key.pem" -Destination "C:\Users\Lawson\Desktop\Github\app-template\security\counter-app-key.pem"
```

### 3. Set Up EC2 Instance

Run the setup script:

```powershell
.\scripts\setup-ec2.ps1
```

The script reads `EC2_ELASTIC_IP` (preferred), `EC2_IP`, and `KEY_PATH` from `security/deployment.config` automatically.

This will:
- Install Docker and Docker Compose
- Set up the app directory
- Prepare everything for deployment

### 4. Deploy Your App

Once setup is complete:

```powershell
.\scripts\auto-deploy-ec2.ps1
```

The script reads from `security/deployment.config` automatically. If `GITHUB_URL` is set, it uses **git pull** (faster); otherwise it copies files via SCP.

---

## 🔒 Security Best Practices

### For Production (After Testing)

1. **Elastic IP** (Recommended):
   - EC2 → Elastic IPs → Allocate
   - Associate with your instance
   - Use this IP for DNS (won't change on restart)

2. **Update Security Group**:
   - Keep SSH restricted to your IP
   - Consider adding CloudFlare IPs if using CloudFlare proxy
   - Monitor security group logs

3. **Enable CloudWatch**:
   - Monitor instance health
   - Set up alerts for high CPU/memory

4. **Regular Backups**:
   - Enable EBS snapshots
   - Backup database regularly

---

## 💰 Cost Estimate

**Free Tier (First Year):**
- t3.micro instance: **FREE** (750 hours/month)
- 30 GB EBS storage: **FREE**
- Data transfer: 15 GB out free

**After Free Tier:**
- t3.micro: ~$7-10/month
- 30 GB storage: ~$3/month
- **Total**: ~$10-13/month

**Very affordable for a public app!**

---

## 🆘 Troubleshooting

### Can't SSH after launch?
- Wait 2-3 minutes for instance to fully start
- Check security group allows SSH from your IP
- Verify you're using the correct `.pem` key file
- Try: `.\scripts\connect-ec2.ps1`

### Instance won't start?
- Check AWS service limits (new accounts may have limits)
- Verify you have sufficient permissions
- Check AWS Console for error messages

### Need to change settings after launch?
- **Storage**: Can increase (but not decrease) via EC2 Console
- **Security group**: Can modify anytime in EC2 → Security Groups
- **Instance type**: Can change (stop instance first)

---

## 📚 Next Steps

1. ✅ Launch instance with recommended settings
2. ✅ Save your `.pem` key file
3. ✅ Run `.\scripts\setup-ec2.ps1`
4. ✅ Run `.\scripts\auto-deploy-ec2.ps1`
5. ✅ Point your domain DNS to the EC2 IP
6. ✅ Set up SSL certificate (Let's Encrypt)

See [`SETUP_GUIDE.md`](../SETUP_GUIDE.md) for complete deployment guide.
