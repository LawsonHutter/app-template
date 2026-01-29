# Flutter + Django Web App Template

This is a **template repository** for creating new Flutter + Django web applications.

## 🚀 Quick Start: Create New Project

### Option 1: Use GitHub Template (Recommended)

1. Click **"Use this template"** → **"Create a new repository"**
2. Name your repository (e.g., `my-new-app`)
3. Clone your new repository
4. Run setup script:
   ```powershell
   .\scripts\setup-from-template.ps1 `
     -ProjectName "my-new-app" `
     -Domain "mynewapp.com" `
     -BundleId "com.mynewapp.app"
   ```

### Option 2: Clone and Customize

```powershell
# Clone template
git clone https://github.com/yourusername/flutter-django-template.git my-new-app
cd my-new-app

# Remove template git history
Remove-Item -Recurse -Force .git
git init
git branch -M main

# Run setup script
.\scripts\setup-from-template.ps1 `
  -ProjectName "my-new-app" `
  -Domain "mynewapp.com" `
  -BundleId "com.mynewapp.app"
```

## 📋 What's Included

- **Backend**: Django REST API with PostgreSQL/SQLite support
- **Frontend**: Flutter web app with modern dark theme
- **iOS Support**: Complete iOS build pipeline with Codemagic
- **Deployment**: AWS/EC2 deployment scripts and configs
- **Documentation**: Comprehensive guides for setup, deployment, troubleshooting

## 🎯 Features

- ✅ **Local Development**: SQLite or Docker/PostgreSQL
- ✅ **Production Deployment**: AWS EC2 with nginx, SSL, Docker
- ✅ **iOS Builds**: Automated TestFlight deployment via Codemagic
- ✅ **CI/CD**: GitHub Actions for testing
- ✅ **Complete Docs**: 40+ documentation files

## 📚 Documentation

- **Template Setup**: [`docs/TEMPLATE_SETUP.md`](docs/TEMPLATE_SETUP.md)
- **Quick Start**: [`docs/QUICK_START.md`](docs/QUICK_START.md)
- **Deployment**: [`docs/DEPLOY_TO_PRODUCTION.md`](docs/DEPLOY_TO_PRODUCTION.md)
- **TestFlight**: [`docs/DEPLOYMENT_STEPS.md`](docs/DEPLOYMENT_STEPS.md)

## 🔧 Setup Checklist

After creating your project:

- [ ] Run `setup-from-template.ps1` with your values
- [ ] Update App Store Connect API credentials
- [ ] Create app in App Store Connect
- [ ] Set up Codemagic
- [ ] Configure AWS/EC2 deployment
- [ ] Update domain DNS
- [ ] Test locally
- [ ] Deploy to production

## 📖 Full Documentation

See [`docs/`](docs/) directory for complete documentation.

---

**Ready to build your app?** Start with [`docs/TEMPLATE_SETUP.md`](docs/TEMPLATE_SETUP.md)
