# Counter App

A simple counter app with Flutter frontend and Django backend. Press a button to increment a counter stored in the database.

**Features:**
- Flutter web frontend
- Django REST API backend
- EC2 deployment ready
- TestFlight deployment via Codemagic
- Google Play deployment

---

## Quick Start

**Setup Guide:** See **[`SETUP_GUIDE.md`](SETUP_GUIDE.md)** for the full step-by-step guide.

```powershell
# 1. Initialize
.\scripts\init-project.ps1

# 2. Run locally
.\scripts\start-local-web.ps1
```

**Cloning as a template?** Run `.\scripts\rename-project.ps1 -AppName "Your App" -Domain "yourapp.net" -BundleId "com.yourdomain.yourapp"` then follow [`SETUP_GUIDE.md`](SETUP_GUIDE.md).

---

## Project Structure

```
├── backend/          # Django REST API
├── frontend/         # Flutter web app
├── infra/            # Nginx, Docker configs
├── scripts/          # Setup & deployment scripts
├── docs/             # EC2, domain, Codemagic, Play Store guides
└── security/         # deployment.config (gitignored)
```

---

## Tech Stack

- **Frontend:** Flutter Web
- **Backend:** Django REST Framework
- **Database:** SQLite (local) / PostgreSQL (production)

---

## Deployment

| Target | Guide |
|--------|-------|
| EC2 (web) | [`SETUP_GUIDE.md`](SETUP_GUIDE.md) steps 5–8, [`docs/EC2_LAUNCH_SETTINGS.md`](docs/EC2_LAUNCH_SETTINGS.md) |
| TestFlight (iOS) | [`docs/CODEMAGIC_TESTFLIGHT_SETUP.md`](docs/CODEMAGIC_TESTFLIGHT_SETUP.md) |
| Google Play (Android) | [`docs/GOOGLE_PLAY_SETUP.md`](docs/GOOGLE_PLAY_SETUP.md) |

---

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md).
