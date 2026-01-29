# Docker Explained - Understanding What's Happening

This guide walks through how Docker works in this project step by step.

## 🎯 What is Docker?

Docker packages your application and all its dependencies into a **container** - like a lightweight virtual machine. This ensures:
- Your app runs the same way on any machine
- No "it works on my machine" problems
- Easy deployment to servers

---

## 📁 Understanding Build Context

### The Problem We Just Fixed

The error you saw was:
```
"/infra/nginx/nginx.conf": not found
```

**Why did this happen?**

In `docker-compose.yml`, the frontend service has:
```yaml
build:
  context: ./frontend
  dockerfile: Dockerfile
```

The `context: ./frontend` means Docker can **only see files inside the `./frontend` directory** when building. It's like telling Docker: "You can only access files in this folder."

So when the Dockerfile tried to copy `infra/nginx/nginx.conf`, Docker couldn't find it because `infra/` is outside the `frontend/` directory.

### The Solution

We simplified the frontend Dockerfile to **not need any files outside** the `frontend/` directory. Now it just uses nginx's default configuration.

---

## 🐳 Understanding the Dockerfiles

### Backend Dockerfile (`backend/Dockerfile`)

Let's walk through it line by line:

```dockerfile
FROM python:3.11-slim
```
**What it does**: Starts with a Python 3.11 base image (pre-installed Python)
**Think of it as**: "Start with a Linux system that has Python already installed"

---

```dockerfile
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
```
**What it does**: Sets environment variables
- `PYTHONDONTWRITEBYTECODE=1`: Don't create `.pyc` files (saves space)
- `PYTHONUNBUFFERED=1`: Show Python output immediately in Docker logs

---

```dockerfile
WORKDIR /app
```
**What it does**: Sets the working directory inside the container to `/app`
**Think of it as**: "All commands run from this folder, like `cd /app`"

---

```dockerfile
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client
```
**What it does**: Installs system packages needed for PostgreSQL
- `gcc`: Compiler needed for some Python packages
- `postgresql-client`: Tools to interact with PostgreSQL database

---

```dockerfile
COPY requirements.txt .
```
**What it does**: Copies `requirements.txt` from your computer into the container
**Why first?**: Docker caches layers. If `requirements.txt` doesn't change, Docker reuses the cached installation next time (faster builds!)

---

```dockerfile
RUN pip install --upgrade pip && \
    pip install -r requirements.txt
```
**What it does**: Installs all Python packages listed in `requirements.txt`
**This is like**: Running `pip install -r requirements.txt` but inside the container

---

```dockerfile
COPY . .
```
**What it does**: Copies ALL files from `backend/` directory into `/app` in container
**Note**: This happens AFTER installing requirements (so code changes don't invalidate the pip cache)

---

```dockerfile
EXPOSE 8000
```
**What it does**: Documents that this container listens on port 8000
**Doesn't actually open the port** - that's done in `docker-compose.yml`

---

```dockerfile
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
```
**What it does**: Default command to run when container starts
**This is like**: Running `python manage.py runserver 0.0.0.0:8000`

---

### Frontend Dockerfile (`frontend/Dockerfile`)

This uses a **multi-stage build** - it has two stages:

#### Stage 1: Build

```dockerfile
FROM ghcr.io/cirruslabs/flutter:stable AS build
```
**What it does**: Uses Flutter image with Flutter SDK pre-installed
**`AS build`**: Names this stage so we can reference it later

---

```dockerfile
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
```
**What it does**: 
1. Sets working directory
2. Copies dependency files (`pubspec.yaml` - like `requirements.txt` for Flutter)
3. Installs Flutter dependencies (`pub get` - like `pip install`)

---

```dockerfile
COPY . .
RUN flutter build web --release --web-renderer canvaskit
```
**What it does**: 
1. Copies all source code
2. Builds Flutter app for web (creates HTML/JS/CSS files in `build/web/`)

---

#### Stage 2: Serve

```dockerfile
FROM nginx:alpine
```
**What it does**: Starts fresh with a lightweight nginx image (web server)
**Why fresh?**: The build stage was huge (Flutter SDK is big). We only need the built files, not the SDK!

---

```dockerfile
COPY --from=build /app/build/web /usr/share/nginx/html
```
**What it does**: Copies built files from the `build` stage to nginx's HTML directory
**`--from=build`**: "Copy from the stage I named 'build'"
**This is like**: Copying your built website files to the web server

---

## 🐙 Understanding docker-compose.yml

Docker Compose orchestrates multiple containers together. Let's look at the key parts:

### Backend Service

```yaml
backend:
  build:
    context: ./backend
    dockerfile: Dockerfile
```
**What it does**: 
- Builds from `./backend` directory (build context)
- Uses `Dockerfile` in that directory

```yaml
  volumes:
    - ./backend:/app
```
**What it does**: Mounts your local `./backend` folder into `/app` in container
**This means**: Changes to files on your computer are immediately visible in container
**Why useful**: You can edit code without rebuilding the Docker image!

```yaml
  ports:
    - "8000:8000"
```
**What it does**: Maps port 8000 on your computer to port 8000 in container
**Format**: `"HOST_PORT:CONTAINER_PORT"`
**This means**: Access `http://localhost:8000` on your computer → goes to container's port 8000

```yaml
  depends_on:
    - db
```
**What it does**: Starts `db` service before `backend`
**Important**: Doesn't wait for database to be READY, just started. We use `healthcheck` for that.

### Database Service

```yaml
db:
  image: postgres:15-alpine
```
**What it does**: Uses pre-built PostgreSQL image (doesn't need a Dockerfile)
**`alpine`**: Lightweight Linux distribution (smaller image size)

```yaml
  volumes:
    - postgres_data:/var/lib/postgresql/data
```
**What it does**: Creates a named volume for database data
**Why**: Data persists even if you stop/remove the container!

### Networks

```yaml
networks:
  survey-network:
    driver: bridge
```
**What it does**: Creates a virtual network
**Why**: Containers can talk to each other by service name (e.g., `backend` can connect to `db:5432`)

---

## 🔄 The Build Process

When you run `docker-compose up --build`:

1. **Docker reads `docker-compose.yml`**
   - "I need 3 services: backend, db, frontend"

2. **For backend service**:
   - Reads `backend/Dockerfile`
   - Starts with Python base image
   - Installs dependencies
   - Copies your code
   - Creates a Docker image

3. **For db service**:
   - Downloads PostgreSQL image (no build needed)

4. **For frontend service**:
   - Reads `frontend/Dockerfile`
   - Builds Flutter app (stage 1)
   - Creates nginx image with built files (stage 2)

5. **Starts all containers**:
   - Creates network
   - Starts containers
   - Connects them together

---

## 🎓 Key Concepts

### Build Context
- **What**: The directory Docker can see during build
- **Set in**: `context: ./backend` in docker-compose.yml
- **Rule**: Can only copy files from within this directory

### Volumes
- **What**: Persistent storage or folder mounting
- **`./backend:/app`**: Mount local folder (changes reflected immediately)
- **`postgres_data:/data`**: Named volume (data persists between container restarts)

### Ports
- **What**: Mapping between host and container
- **`"8000:8000"`**: Host port 8000 → Container port 8000

### Networks
- **What**: Virtual network connecting containers
- **Why**: Containers can find each other by service name

---

## 🚀 What Happens When You Run `docker-compose up`

```
1. Docker Compose reads docker-compose.yml
2. Checks if images exist:
   - If not, builds them (or downloads them)
   - If yes, uses cached versions
3. Creates network: survey-network
4. Creates volumes: postgres_data, backend_static, backend_media
5. Starts containers in dependency order:
   - db (first, because backend depends on it)
   - backend (waits for db to be healthy)
   - frontend (waits for backend to start)
6. All containers now running and connected!
```

---

## 💡 Pro Tips

1. **Build context matters**: Docker can only see files in the context directory
2. **Layer caching**: Docker caches each step. Put frequently-changing files last
3. **Multi-stage builds**: Great for reducing final image size (like frontend)
4. **Volumes**: Use for code during development (changes reflected immediately)
5. **Named volumes**: Use for databases (data persists)

---

## 🔍 Debugging Commands

```bash
# See what Docker is doing
docker-compose build --progress=plain

# Check if images were built
docker images

# Check running containers
docker-compose ps

# View logs
docker-compose logs backend
docker-compose logs -f backend  # Follow logs in real-time

# Execute commands in container
docker-compose exec backend python manage.py migrate
docker-compose exec db psql -U survey_user -d survey_db
```

---

Now you understand what's happening! The Dockerfiles are simpler and should build successfully. 🎉
