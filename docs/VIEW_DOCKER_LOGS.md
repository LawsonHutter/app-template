# View Docker Container Logs

How to see what's happening inside your Docker containers.

## View All Logs

```powershell
# Last 50 lines from all containers
docker compose logs --tail=50

# Follow logs (live updates)
docker compose logs -f

# Last 100 lines and follow
docker compose logs --tail=100 -f
```

## View Specific Service Logs

```powershell
# Backend logs
docker compose logs backend

# Frontend logs
docker compose logs frontend

# Database logs
docker compose logs db

# Nginx logs (if running in production)
docker compose logs nginx
```

## Follow Specific Service (Live)

```powershell
# Follow backend logs
docker compose logs -f backend

# Follow frontend logs
docker compose logs -f frontend

# Follow all logs
docker compose logs -f
```

## View Logs with Timestamps

```powershell
# With timestamps
docker compose logs -t

# Specific service with timestamps
docker compose logs -t backend
```

## Clear Logs and Start Fresh

```powershell
# View logs since containers started
docker compose logs --since 10m

# View logs from specific time
docker compose logs --since 2024-01-19T10:00:00
```

## Quick Commands

```powershell
# See what's running
docker compose ps

# View all logs (last 50 lines)
docker compose logs --tail=50

# Follow backend (most useful for debugging)
docker compose logs -f backend

# View errors only
docker compose logs 2>&1 | Select-String -Pattern "error|Error|ERROR"
```

## Using Docker Desktop

If you have Docker Desktop installed:
1. Open Docker Desktop
2. Go to **Containers** tab
3. Click on a container name (e.g., `survey-backend`)
4. Click **Logs** tab
5. See live logs with search/filter options

## Common Use Cases

### Debug Backend Issues
```powershell
docker compose logs -f backend
```

### Debug Frontend Issues
```powershell
docker compose logs -f frontend
```

### Check Database Connection
```powershell
docker compose logs db | Select-String -Pattern "ready|listening|error"
```

### See All Errors
```powershell
docker compose logs | Select-String -Pattern "error|Error|ERROR|exception|Exception"
```
