# How to Find Your EC2 Instance IP Address

## Quick Steps

1. **Go to AWS Console** → **EC2**
2. **Click "Instances"** (left sidebar)
3. **Find your instance** (`survey-app`)
4. **Look at the "Public IPv4 address"** column
5. **Copy that IP address** (looks like: `54.123.45.67`)

## Detailed Steps

### Option 1: AWS Console (Easiest)

1. Open [AWS Console](https://console.aws.amazon.com)
2. Navigate to **EC2** service
3. Click **"Instances"** in the left menu
4. Find your instance named `survey-app`
5. In the instance details, look for:
   - **Public IPv4 address**: `xx.xx.xx.xx` ← **This is what you need!**
   - **Public IPv4 DNS**: `ec2-xx-xx-xx-xx.compute-1.amazonaws.com` (alternative)

### Option 2: If IP is Not Showing

If you don't see a Public IPv4 address:
- The instance might still be starting (wait 1-2 minutes)
- Check "Instance state" - should be "running" (green)
- If it says "pending", wait for it to change to "running"

### Option 3: Using AWS CLI

```bash
aws ec2 describe-instances --filters "Name=tag:Name,Values=survey-app" --query "Reservations[*].Instances[*].[PublicIpAddress]" --output text
```

---

## Connect Using the IP

Once you have the IP address:

```powershell
# Replace xx.xx.xx.xx with your actual IP
ssh -i survey-app-key.pem ubuntu@xx.xx.xx.xx
```

Or using the DNS name:

```powershell
ssh -i survey-app-key.pem ubuntu@ec2-xx-xx-xx-xx.compute-1.amazonaws.com
```

---

## Troubleshooting

### "Permission denied (publickey)"
- Make sure you're using the correct key file
- Check file path is correct
- On Windows, you might need to use the full path

### "Connection timed out"
- Check security group allows SSH (port 22) from your IP
- Verify instance is "running"
- Check if you have the correct IP address

### "Host key verification failed"
- Type `yes` when prompted
- Or remove old key: `ssh-keygen -R your-ec2-ip`
