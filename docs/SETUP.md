# Project Setup Guide

## Initial GitHub Repository Setup

### 1. Create Repository on GitHub

1. Go to GitHub and create a new repository
2. Name it `survey-web-app` (or your preferred name)
3. Initialize with a README (we'll replace it)
4. Add .gitignore: None (we'll add our custom one)
5. Choose license if needed

### 2. Initialize Local Git Repository

```bash
# In your project root directory
git init
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/survey-web-app.git
```

### 3. Initial Commit

```bash
# Add all files
git add .

# Commit
git commit -m "chore: initial project setup with Flutter and Django structure"

# Push to GitHub
git push -u origin main
```

## Repository Structure Best Practices

### Why Monorepo?

For a Flutter + Django project, a **monorepo** (single repository) is recommended because:

- ✅ Shared types/interfaces can be documented in one place
- ✅ Easier to coordinate backend and frontend changes
- ✅ Single CI/CD pipeline
- ✅ Simplified dependency management
- ✅ Better for small to medium projects

### Alternative: Separate Repos

If your project grows large or teams are separate:
- `survey-web-app-backend` - Django API
- `survey-web-app-frontend` - Flutter app

## Branch Strategy

### Recommended Flow

```
main (production)
  └── develop (integration)
      ├── feature/user-authentication
      ├── feature/survey-crud
      ├── fix/login-bug
      └── backend/api-optimization
```

### Branch Protection Rules

Set up in GitHub Settings → Branches:

1. **main branch**:
   - Require pull request reviews
   - Require status checks to pass
   - Require branches to be up to date

2. **develop branch**:
   - Require pull request reviews
   - Allow force pushes (for rebasing)

## GitHub Repository Settings

### 1. Repository Settings

- **Description**: Full-stack survey web app (Flutter + Django)
- **Topics**: `flutter`, `django`, `web-app`, `survey`, `rest-api`
- **Visibility**: Public/Private (your choice)

### 2. Secrets & Variables

For CI/CD and deployment (Settings → Secrets and variables → Actions):

- `DJANGO_SECRET_KEY`
- `DATABASE_URL`
- `ALLOWED_HOSTS`

### 3. Issues & Projects

Enable:
- ✅ Issues
- ✅ Projects (for project management)
- ✅ Wiki (optional, for documentation)

### 4. Labels

Create labels for organization:
- `backend` - Backend-related issues
- `frontend` - Frontend-related issues
- `bug` - Bug reports
- `feature` - Feature requests
- `documentation` - Documentation updates

## Next Steps

1. Set up backend Django project: `cd backend && django-admin startproject survey_backend .`
2. Set up frontend Flutter project: `cd frontend && flutter create .`
3. Configure CORS for Django to allow Flutter requests
4. Set up database migrations
5. Configure environment variables

See backend and frontend specific setup guides in their respective directories.
