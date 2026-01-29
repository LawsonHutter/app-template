# Debug Docker Build - Step by Step Commands

If Docker build is hanging, run these commands manually to see exactly where it fails.

## Backend Build Steps

### Step 1: Base Image
```bash
# This is what Docker does internally
docker pull python:3.11-slim
```

### Step 2: Set Working Directory
```bash
# Docker sets WORKDIR /app
# (This happens inside container, can't test directly)
```

### Step 3: Install System Dependencies
```bash
# Test this command manually
docker run --rm python:3.11-slim sh -c "apt-get update && apt-get install -y gcc postgresql-client && rm -rf /var/lib/apt/lists/*"
```

### Step 4: Copy Requirements
```bash
# Test copying requirements file
docker run --rm -v "$(pwd)/backend:/app" -w /app python:3.11-slim sh -c "cat requirements.txt"
```

### Step 5: Install Python Packages
```bash
# Test pip install (this is often where it hangs)
docker run --rm -v "$(pwd)/backend:/app" -w /app python:3.11-slim sh -c "pip install --upgrade pip && pip install -r requirements.txt"
```

### Step 6: Copy Code
```bash
# Test copying code
docker run --rm -v "$(pwd)/backend:/app" -w /app python:3.11-slim sh -c "ls -la"
```

### Step 7: Install Gunicorn (Production)
```bash
# Test gunicorn install
docker run --rm -v "$(pwd)/backend:/app" -w /app python:3.11-slim sh -c "pip install gunicorn"
```

---

## Frontend Build Steps

### Step 1: Pull Flutter Image
```bash
docker pull ghcr.io/cirruslabs/flutter:stable
```

### Step 2: Set Working Directory
```bash
# WORKDIR /app (internal)
```

### Step 3: Copy pubspec files
```bash
# Test copying pubspec
docker run --rm -v "$(pwd)/frontend:/app" -w /app ghcr.io/cirruslabs/flutter:stable sh -c "cat pubspec.yaml"
```

### Step 4: Install Flutter Dependencies
```bash
# Test flutter pub get (this can hang)
docker run --rm -v "$(pwd)/frontend:/app" -w /app ghcr.io/cirruslabs/flutter:stable sh -c "flutter pub get"
```

### Step 5: Copy Source Code
```bash
# Test copying code
docker run --rm -v "$(pwd)/frontend:/app" -w /app ghcr.io/cirruslabs/flutter:stable sh -c "ls -la lib/"
```

### Step 6: Build Flutter Web (THIS IS WHERE IT OFTEN HANGS)
```bash
# Test flutter build (this is the slowest step)
docker run --rm -v "$(pwd)/frontend:/app" -w /app \
  -e API_BASE_URL=http://localhost:8000/api/counter/ \
  ghcr.io/cirruslabs/flutter:stable sh -c "flutter build web --release --dart-define=API_BASE_URL=http://localhost:8000/api/counter/"
```

---

## Quick Test Script

Create a test script to run each step:

```bash
#!/bin/bash
# test-build.sh

echo "=== Testing Backend Build ==="

echo "Step 1: Pull base image..."
docker pull python:3.11-slim

echo "Step 2: Install system deps..."
docker run --rm python:3.11-slim sh -c "apt-get update && apt-get install -y gcc postgresql-client && rm -rf /var/lib/apt/lists/*"

echo "Step 3: Test pip install..."
docker run --rm -v "$(pwd)/backend:/app" -w /app python:3.11-slim sh -c "pip install --upgrade pip && pip install -r requirements.txt"

echo "=== Testing Frontend Build ==="

echo "Step 1: Pull Flutter image..."
docker pull ghcr.io/cirruslabs/flutter:stable

echo "Step 2: Test flutter pub get..."
docker run --rm -v "$(pwd)/frontend:/app" -w /app ghcr.io/cirruslabs/flutter:stable sh -c "flutter pub get"

echo "Step 3: Test flutter build (this takes longest)..."
docker run --rm -v "$(pwd)/frontend:/app" -w /app \
  -e API_BASE_URL=http://localhost:8000/api/counter/ \
  ghcr.io/cirruslabs/flutter:stable sh -c "flutter build web --release --dart-define=API_BASE_URL=http://localhost:8000/api/counter/"
```

---

## Most Likely Hang Points

1. **`pip install -r requirements.txt`** - Downloading Python packages
2. **`flutter pub get`** - Downloading Dart packages  
3. **`flutter build web`** - Compiling Flutter (takes 1-5 minutes)
4. **`resolving provenance`** - Docker BuildKit metadata (can hang)

---

## Skip BuildKit (Quick Fix)

If it hangs at "resolving provenance", disable BuildKit:

```bash
DOCKER_BUILDKIT=0 docker compose build
```

---

## Build One Service at a Time

```bash
# Build database (fast, no build needed)
docker compose build db

# Build backend (tests Python/Django)
docker compose build backend

# Build frontend (tests Flutter, slowest)
docker compose build frontend
```

This way you can see which specific service is hanging.
