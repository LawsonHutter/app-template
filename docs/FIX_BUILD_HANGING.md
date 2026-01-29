# Fix Docker Build Hanging at "Resolving Provenance"

If Docker build hangs at "resolving provenance for metadata file", try these fixes:

## Quick Fix 1: Disable BuildKit Provenance

```bash
# Cancel current build (Ctrl+C)
# Then rebuild without provenance
DOCKER_BUILDKIT=0 docker compose -f docker-compose.yml -f docker-compose.prod.yml build

# Or set environment variable
export DOCKER_BUILDKIT=0
docker compose -f docker-compose.yml -f docker-compose.prod.yml build
```

## Quick Fix 2: Build Without Cache

```bash
# Cancel current build (Ctrl+C)
# Build without cache and provenance
docker compose -f docker-compose.yml -f docker-compose.prod.yml build --no-cache --progress=plain
```

## Quick Fix 3: Restart Docker Daemon

```bash
# Cancel current build (Ctrl+C)
# Restart Docker
sudo systemctl restart docker

# Wait a few seconds, then try again
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

## Quick Fix 4: Build Services Separately

```bash
# Cancel current build (Ctrl+C)
# Build one at a time
docker compose -f docker-compose.yml -f docker-compose.prod.yml build db
docker compose -f docker-compose.yml -f docker-compose.prod.yml build backend
docker compose -f docker-compose.yml -f docker-compose.prod.yml build frontend

# Then start
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## Quick Fix 5: Use Legacy Builder

```bash
# Cancel current build (Ctrl+C)
# Disable BuildKit completely
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0

# Rebuild
docker compose -f docker-compose.yml -f docker-compose.prod.yml build
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## Recommended: Try Fix 1 First

The "resolving provenance" step is a BuildKit feature that can hang. Disabling it usually fixes the issue.
