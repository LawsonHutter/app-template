# Fix "Resolving Provenance" Hang

If Docker build hangs at "resolving provenance for metadata file", disable BuildKit.

## Quick Fix

```bash
# Cancel current build (Ctrl+C)
# Then rebuild without BuildKit
DOCKER_BUILDKIT=0 docker compose -f docker-compose.yml -f docker-compose.prod.yml build

# Then start
COMPOSE_COMPATIBILITY=1 docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## Permanent Fix (Set Environment Variable)

Add to your `~/.bashrc` or `~/.profile`:

```bash
# Disable BuildKit to avoid provenance hangs
export DOCKER_BUILDKIT=0
```

Then reload:
```bash
source ~/.bashrc
```

## Why This Happens

"Resolving provenance" is a BuildKit feature that:
- Verifies image signatures
- Can hang on slow networks or EC2 instances
- Not needed for your use case

Disabling BuildKit uses the legacy builder which skips this step.
