# Copy Backend and Frontend to EC2

Since `backend/` and `frontend/` directories were in `.gitignore`, they weren't cloned to EC2. Here's how to copy them.

## Quick Method: Use the Script

```powershell
.\scripts\copy-to-ec2.ps1 -Ec2Ip 52.73.150.104
```

This copies all project files including `backend/` and `frontend/`.

---

## Manual Method: Copy Directories Separately

Run these commands in PowerShell from your project root:

```powershell
# Copy backend directory
scp -i security\survey-app-key.pem -r backend ubuntu@52.73.150.104:~/survey-web-app/

# Copy frontend directory  
scp -i security\survey-app-key.pem -r frontend ubuntu@52.73.150.104:~/survey-web-app/
```

**Note**: These commands may take a few minutes depending on file sizes.

---

## Verify on EC2

After copying, SSH into EC2 and verify:

```bash
cd ~/survey-web-app
ls -la backend/
ls -la frontend/
```

You should see:
- `backend/manage.py`
- `backend/requirements.txt`
- `backend/survey_backend/`
- `frontend/lib/main.dart`
- `frontend/pubspec.yaml`

---

## Troubleshooting

**Connection timeout?**
- Check security group allows SSH (port 22) from your IP
- Verify EC2 instance is running
- Try connecting via SSH first: `ssh -i security\survey-app-key.pem ubuntu@52.73.150.104`

**Permission denied?**
- Run `.\scripts\fix-ssh-permissions.ps1` to fix key file permissions

**Files not appearing?**
- Check you're in the right directory on EC2: `pwd`
- List files: `ls -la ~/survey-web-app/`
