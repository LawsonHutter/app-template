# Docker Memory Limits Explained

Memory limits have been added to prevent containers from crashing your EC2 instance.

## Why Memory Limits?

EC2 instances (especially t2.micro with 1GB RAM) can run out of memory if containers use too much, causing:
- Container crashes
- System instability
- OOM (Out of Memory) kills

## Memory Limits Set

### Backend (Django/Gunicorn)
- **Limit**: 512MB
- **Reservation**: 256MB
- **CPU Limit**: 0.5 cores
- **Why**: Django needs memory for Python processes and Gunicorn workers

### Database (PostgreSQL)
- **Limit**: 256MB
- **Reservation**: 128MB
- **CPU Limit**: 0.5 cores
- **Why**: PostgreSQL can use a lot of memory, but for small apps 256MB is enough

### Frontend (Nginx serving Flutter)
- **Limit**: 128MB
- **Reservation**: 64MB
- **CPU Limit**: 0.25 cores
- **Why**: Just serving static files, very lightweight

### Nginx (Reverse Proxy)
- **Limit**: 128MB
- **Reservation**: 64MB
- **CPU Limit**: 0.25 cores
- **Why**: Just routing traffic, very lightweight

## Total Memory Usage

**Maximum**: ~1GB (512 + 256 + 128 + 128 = 1024MB)
**Reserved**: ~512MB (256 + 128 + 64 + 64 = 512MB)

This fits comfortably on a t2.micro (1GB RAM) with room for the OS.

## How It Works

### Limits
- **Maximum** memory a container can use
- If exceeded, container is killed/restarted
- Prevents one service from consuming all memory

### Reservations
- **Guaranteed** memory for the container
- Docker reserves this upfront
- Ensures container always has minimum memory

## Adjusting Limits

If you need more memory for a service:

```yaml
deploy:
  resources:
    limits:
      memory: 1G  # Increase limit
      cpus: '1.0'  # Increase CPU
    reservations:
      memory: 512M  # Increase reservation
      cpus: '0.5'
```

**Warning**: Don't exceed your EC2 instance's total memory!

## Monitoring Memory Usage

```bash
# Check container memory usage
docker stats

# Check specific container
docker stats survey-backend
```

## If Containers Keep Crashing

1. **Check memory usage**:
   ```bash
   docker stats
   free -h
   ```

2. **Increase limits** (if you have more RAM):
   - Edit `docker-compose.yml` or `docker-compose.prod.yml`
   - Increase `memory` limits
   - Restart: `docker compose up -d`

3. **Reduce workers** (for backend):
   - In `docker-compose.prod.yml`, change:
     ```yaml
     command: gunicorn survey_backend.wsgi:application --bind 0.0.0.0:8000 --workers 2 --timeout 120
     ```
   - Fewer workers = less memory

4. **Upgrade EC2 instance**:
   - t2.micro (1GB) → t2.small (2GB)
   - More memory = more headroom

## Best Practices

- ✅ Set limits for all containers
- ✅ Monitor with `docker stats`
- ✅ Start with conservative limits, increase if needed
- ✅ Leave 200-300MB for the OS
- ✅ Test under load to find optimal limits
