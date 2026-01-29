# What Does "Building Docker" Do?

When you run `docker compose build` or `docker build`, Docker creates an **image** - a snapshot of your application with all its dependencies. Think of it like creating a package that contains everything needed to run your app.

---

## 🎯 The Big Picture

**Building** = Creating a reusable image  
**Running** = Starting a container from that image

---

## 📦 What Happens During Build

### Backend Build (`backend/Dockerfile`)

When you build the backend:

1. **Starts with base image**: `python:3.11-slim`
   - A minimal Linux system with Python 3.11 pre-installed

2. **Sets working directory**: `/app`
   - All commands run from this folder

3. **Installs system dependencies**:
   - `gcc`, `postgresql-client` (needed for database connections)

4. **Copies requirements.txt**: 
   - Copies your Python dependencies list

5. **Installs Python packages**:
   - Runs `pip install -r requirements.txt`
   - Installs Django, DRF, psycopg2, etc.

6. **Copies your code**:
   - Copies all your Django code (`backend/` directory)

7. **Sets default command**:
   - What runs when container starts (e.g., `runserver` or `gunicorn`)

**Result**: A complete, self-contained Python environment with your Django app ready to run.

---

### Frontend Build (`frontend/Dockerfile`)

When you build the frontend:

1. **Stage 1 - Build**:
   - Uses Flutter image (`ghcr.io/cirruslabs/flutter:stable`)
   - Copies your Flutter code
   - Runs `flutter pub get` (installs Dart packages)
   - Runs `flutter build web` (compiles Flutter to web files)
   - Creates optimized HTML, CSS, JavaScript files

2. **Stage 2 - Serve**:
   - Uses lightweight `nginx:alpine` image
   - Copies the built web files from Stage 1
   - Sets up nginx to serve the static files

**Result**: A web server (nginx) with your compiled Flutter app ready to serve.

---

## 🔄 Build vs. Run

### `docker compose build`
- **Creates images** (the packages)
- Takes time (downloads dependencies, compiles code)
- Only needed when:
  - Code changes
  - Dependencies change
  - First time setup

### `docker compose up`
- **Starts containers** (runs the images)
- Fast (just starts existing images)
- Happens every time you want to run the app

### `docker compose up --build`
- **Builds AND runs** in one command
- Useful when you've made changes

---

## 📊 Example: What Gets Built

### Backend Image Contains:
```
python:3.11-slim (base)
├── Python 3.11
├── pip
├── Django 4.x
├── Django REST Framework
├── psycopg2 (PostgreSQL driver)
├── gunicorn (production server)
├── Your Django code
│   ├── manage.py
│   ├── survey_backend/
│   └── click_counter/
└── Command to run: gunicorn or runserver
```

### Frontend Image Contains:
```
nginx:alpine (base)
├── nginx web server
└── Your compiled Flutter app
    ├── index.html
    ├── main.dart.js (compiled Dart)
    ├── assets/
    └── icons/
```

---

## ⚡ Why Build Separately?

### Build Once, Run Many Times

```bash
# Build (takes 2-5 minutes)
docker compose build

# Run (takes seconds)
docker compose up -d

# Stop and start again (still fast - uses existing images)
docker compose down
docker compose up -d  # No rebuild needed!
```

### When to Rebuild

**Rebuild when:**
- ✅ You change Python dependencies (`requirements.txt`)
- ✅ You change Flutter dependencies (`pubspec.yaml`)
- ✅ You modify `Dockerfile`
- ✅ You want fresh dependencies

**Don't rebuild when:**
- ❌ You only change code (Docker copies code at runtime with volumes)
- ❌ You just want to restart the app

---

## 🎨 Multi-Stage Builds (Frontend)

The frontend uses a **multi-stage build**:

```
Stage 1: Build stage
├── Flutter SDK (large, ~2GB)
├── Compiles your app
└── Creates web files

Stage 2: Production stage
├── Only nginx (small, ~50MB)
└── Only the compiled web files
```

**Why?** Final image is tiny (only nginx + files), but we needed Flutter SDK to build.

---

## 🔍 What You See During Build

```bash
$ docker compose build frontend

[+] Building 45.2s
 => [frontend build 1/6] FROM docker.io/library/flutter:stable
 => [frontend build 2/6] WORKDIR /app
 => [frontend build 3/6] COPY pubspec.yaml pubspec.lock ./
 => [frontend build 4/6] RUN flutter pub get
 => [frontend build 5/6] COPY . .
 => [frontend build 6/6] RUN flutter build web
 => [frontend production 1/3] FROM docker.io/library/nginx:alpine
 => [frontend production 2/3] COPY --from=build /app/build/web /usr/share/nginx/html
 => [frontend production 3/3] COPY nginx.conf /etc/nginx/nginx.conf
 => => exporting to image
 => => => writing image sha256:abc123...
```

Each step shows what's happening!

---

## 💡 Key Takeaways

1. **Build = Create image** (package with app + dependencies)
2. **Run = Start container** (execute the image)
3. **Build is slow** (downloads, compiles) - do it when needed
4. **Run is fast** (just starts existing image)
5. **Images are reusable** - build once, run many times
6. **Multi-stage builds** keep final images small

---

## 🚀 Common Commands

```bash
# Build everything
docker compose build

# Build specific service
docker compose build frontend

# Build and run
docker compose up --build

# Just run (uses existing images)
docker compose up -d

# Rebuild without cache (fresh start)
docker compose build --no-cache
```

---

**Think of it like**: Building a Docker image is like creating a complete, ready-to-run application package. Running it is like opening that package and starting the app!
