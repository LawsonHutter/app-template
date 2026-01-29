# Check Memory Usage on EC2

How to check if you're running out of RAM on your EC2 instance.

## Quick Memory Check

```bash
# See current memory usage
free -h

# See detailed memory info
cat /proc/meminfo | head -20

# See memory usage over time
watch -n 1 free -h
```

## Check EC2 Instance Type and Specs

```bash
# See instance metadata (instance type, RAM, etc.)
curl http://169.254.169.254/latest/meta-data/instance-type

# See all instance info
curl http://169.254.169.254/latest/meta-data/

# Check CPU info
lscpu

# Check total RAM
grep MemTotal /proc/meminfo
```

## Check Docker Memory Usage

```bash
# See memory usage by containers
docker stats --no-stream

# See memory usage in real-time
docker stats

# Check Docker system info
docker system df
docker info | grep -i memory
```

## Check What's Using Memory

```bash
# Top processes by memory
top -o %MEM

# Or use htop (if installed)
htop

# See memory usage by process
ps aux --sort=-%mem | head -20
```

## Check Swap Usage

```bash
# See if swap is being used (bad sign - means out of RAM)
free -h
swapon --show

# Check swap usage
cat /proc/swaps
```

## Check EC2 Instance Type in AWS Console

1. Go to **EC2** → **Instances**
2. Select your instance
3. Check **Instance type** (e.g., `t2.micro`, `t2.small`)
4. Check **Instance state** and **Status checks**

### Common Instance Types and RAM

- **t2.micro**: 1 GB RAM
- **t2.small**: 2 GB RAM
- **t2.medium**: 4 GB RAM
- **t3.micro**: 1 GB RAM
- **t3.small**: 2 GB RAM

## If Running Out of Memory

### Symptoms
- Builds hang or crash
- System becomes slow
- Swap being used (check with `free -h`)
- OOM (Out of Memory) errors in logs

### Solutions

1. **Upgrade EC2 Instance**:
   - Stop instance
   - Change instance type (e.g., t2.micro → t2.small)
   - Start instance

2. **Reduce Docker Memory Limits**:
   - Edit `docker-compose.yml` and `docker-compose.prod.yml`
   - Lower memory limits in `deploy.resources.limits.memory`

3. **Stop Unused Services**:
   ```bash
   # See what's running
   docker ps
   docker stats
   
   # Stop unused containers
   docker stop <container-name>
   ```

4. **Clean Up Docker**:
   ```bash
   # Remove unused images/containers
   docker system prune -a
   docker volume prune
   ```

## Quick Diagnostic Commands

```bash
# All-in-one memory check
echo "=== Instance Type ==="
curl -s http://169.254.169.254/latest/meta-data/instance-type
echo ""
echo "=== Memory Usage ==="
free -h
echo ""
echo "=== Docker Memory ==="
docker stats --no-stream
echo ""
echo "=== Top Memory Processes ==="
ps aux --sort=-%mem | head -10
```

## Check Memory During Build

```bash
# In one terminal, start build
docker compose build

# In another terminal, monitor memory
watch -n 1 'free -h && echo "" && docker stats --no-stream'
```
