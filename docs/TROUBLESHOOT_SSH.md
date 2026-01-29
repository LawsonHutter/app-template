# Troubleshoot SSH Connection Hanging

If SSH is hanging (not connecting), check these common issues:

## 1. Check Security Group

**In AWS Console:**
1. Go to **EC2** → **Instances**
2. Select your instance
3. Click **Security** tab
4. Click on the security group name
5. Check **Inbound rules**:
   - Should have **SSH (22)** from **Your IP** or **0.0.0.0/0**
   - If missing, add it:
     - **Type**: SSH
     - **Port**: 22
     - **Source**: `My IP` (or your specific IP)

## 2. Check Instance Status

**In AWS Console:**
1. Go to **EC2** → **Instances**
2. Check **Instance state**:
   - Should be **Running** ✅
   - If **Stopped**, click **Start instance**
   - If **Pending**, wait for it to start

## 3. Check Public IP

**In AWS Console:**
1. Go to **EC2** → **Instances**
2. Select your instance
3. Check **Public IPv4 address**:
   - Should match: `52.73.150.104`
   - If different, use the correct IP

## 4. Test Connectivity

**From PowerShell:**
```powershell
# Test if port 22 is open
Test-NetConnection -ComputerName 52.73.150.104 -Port 22

# Or ping
ping 52.73.150.104
```

**If ping fails**: Instance might be down or network issue
**If ping works but SSH doesn't**: Security group issue

## 5. Try SSH with Verbose Output

```powershell
ssh -v -i security\survey-app-key.pem ubuntu@52.73.150.104
```

This shows where it's hanging:
- **Hangs at "Connecting to..."**: Security group or network issue
- **Hangs at "Authenticating..."**: Key file issue
- **Connection refused**: Instance not running or wrong port

## 6. Check Key File Permissions

```powershell
# Fix permissions (Windows)
.\scripts\fix-ssh-permissions.ps1
```

## 7. Try AWS Session Manager (Alternative)

If SSH still doesn't work, use AWS Session Manager:

1. **Install AWS CLI** (if not installed)
2. **Install Session Manager plugin**
3. **In AWS Console** → **EC2** → **Instances**
4. Select instance → **Connect** → **Session Manager** → **Connect**

No SSH key needed!

## 8. Check Instance Logs

**In AWS Console:**
1. Go to **EC2** → **Instances**
2. Select your instance
3. **Actions** → **Monitor and troubleshoot** → **Get system log**
4. Look for errors

## Quick Checklist

- [ ] Instance is **Running**
- [ ] Security group allows **SSH (22)** from your IP
- [ ] Using correct **Public IP** (`52.73.150.104`)
- [ ] Key file exists and has correct permissions
- [ ] Can ping the instance
- [ ] Port 22 is open (Test-NetConnection)

## Most Common Issue

**Security group not allowing SSH from your IP** - This is the #1 cause of hanging SSH connections.

Fix: Add SSH rule in security group allowing your IP address.
