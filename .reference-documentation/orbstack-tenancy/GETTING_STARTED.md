# Getting Started with OrbStack Tenancy

This guide will help you set up and run the OrbStack Tenancy system on your local machine or deploy it to production.

## Prerequisites

### Required
- **macOS** (OrbStack is macOS-only)
- **OrbStack** 1.0+ ([download here](https://orbstack.dev))
  - Provides a fast, lightweight Docker runtime optimized for macOS
  - Alternative: Docker Desktop works too, but OrbStack is recommended
- **Git** (to clone the repository)

### Optional (for production)
- **Cloudflare Account** with Access and Tunnel configured
- **Domain name** for public access

### Version Matrix
- OrbStack / Docker Engine: 1.0+ (ships Docker 26+)
- Docker Compose: v2.24 or newer
- Go toolchain: 1.22.x (matches `supervisor/go.mod`)
- Node.js: 22.x (tenant base image)
- npm: use the version bundled with Node 22; run `npm ci` for deterministic installs
- Redis: 7.x (container uses `redis:7-alpine`)

## Quick Start (Automated)

For the fastest setup, use the automated script:

```bash
cd orbstack-tenancy
./setup.sh
```

This script will:
1. Check prerequisites (Docker/OrbStack)
2. Create `.env` from `.env.example`
3. Build the tenant base image
4. Start gateway, supervisor, and redis (run with `--profile prod` to include cloudflared)
5. Verify health
6. Display next steps

## Manual Setup

If you prefer to set up manually or need to customize the process:

### Step 1: Verify OrbStack is Running

```bash
docker info
```

You should see output showing Docker is running. If not, start OrbStack.

### Step 2: Configure Environment

```bash
cp .env.example .env
```

Edit `.env` and update the following **critical** values. Local secrets are distributed via the internal secrets bundle—pull the latest copy before running so everyone uses the same keys.

```bash
# Local defaults (safe for localhost only)
PUBLIC_BASE_URL=http://localhost:8080
COOKIE_DOMAIN=localhost
COOKIE_JWT_SECRET=<shared-secret>
REDIS_PASSWORD=<shared-secret>
TENANT_NAMESPACE_KEY=<shared-secret>

# Optional (leave blank for local dev unless testing integrations)
ANTHROPIC_API_KEY=
OPENAI_API_KEY=
```

For production override the URL and domain, set a real `TUNNEL_TOKEN`, and rotate every secret before rollout.

**Security Best Practices:**
- Generate strong random secrets: `openssl rand -hex 32`
- Never commit real secrets to git
- Rotate secrets regularly in production

### Step 3: Build Tenant Base Image

This creates the Docker image that will be used for all tenant containers:

```bash
docker compose --profile build-only build tenant-base-build
```

This may take 3-5 minutes on first run as it:
- Downloads Node.js 22 Alpine base image
- Installs build dependencies (Python, make, g++)
- Installs npm dependencies (Express, better-sqlite3, undici)
- Cleans up build tools to reduce image size

### Step 4: Start All Services

```bash
docker compose up -d --build
```

Because `cloudflared` is tagged with the `prod` profile it is skipped during local runs. To include it (after setting `TUNNEL_TOKEN`) use:

```bash
docker compose --profile prod up -d --build
```

The default local stack starts:
- **gateway** - nginx reverse proxy with rate limiting
- **supervisor** - Go orchestration service (port 4010)
- **redis** - Session storage and revocation list

### Step 5: Verify Everything Works

```bash
# Check service health
curl http://localhost:8080/health

# Expected response:
# {"status":"ok","time":"2024-10-14T...","redis_ok":true,"central_db_ok":true}

# View running containers
docker compose ps

# Check supervisor logs
docker compose logs -f supervisor
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│ Cloudflare Access/Tunnel (Public Edge)                  │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│ nginx Gateway (:8080)                                   │
│ - Rate limiting (60 req/min)                            │
│ - Request size limits (10MB)                            │
│ - WebSocket support                                      │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│ Supervisor (:4010)                                       │
│ - JWT Authentication                                     │
│ - Container Lifecycle (sleep/wake)                       │
│ - Reverse Proxy to Tenants                              │
│ - Admin APIs                                             │
└────────────────────┬────────────────────────────────────┘
                     │
            ┌────────┴────────┐
            ▼                 ▼
┌─────────────────┐  ┌─────────────────┐
│ Tenant Container│  │ Tenant Container│  (One per user)
│ app__<hash>     │  │ app__<hash>     │
│                 │  │                 │
│ - Isolated net  │  │ - Isolated net  │
│ - Files volume  │  │ - Files volume  │
│ - History DB    │  │ - History DB    │
│ - 2 CPU/4GB RAM │  │ - 2 CPU/4GB RAM │
└─────────────────┘  └─────────────────┘
```

## Testing the System

### 1. Login and Get Session Cookie

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "test-user-123",
    "email": "test@example.com",
    "plan": "free",
    "onboarding_completed": true
  }' \
  -c cookies.txt
```

### 2. Check Session Status

```bash
curl http://localhost:8080/session/status \
  -b cookies.txt
```

### 3. Wake Up Your Tenant Container

```bash
curl -X POST http://localhost:8080/warmup \
  -H "Content-Type: application/json" \
  -d '{"user_id": "test-user-123"}' \
  -b cookies.txt
```

This will:
- Create a dedicated Docker network (`net__app__<hash>`)
- Create two volumes (files and history)
- Start a container with resource limits
- Wait up to 45 seconds for health check to pass

### 4. Send a Chat Message

```bash
curl -X POST http://localhost:8080/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hello, world!",
    "conversation_id": "conv-001"
  }' \
  -b cookies.txt
```

### 5. View Admin Information

```bash
# List all tenant containers
curl http://localhost:8080/tenants

# Check tenant status
curl "http://localhost:8080/status?user_id=test-user-123"

# View tenant logs (replace with your user_id)
curl http://localhost:8080/tenants/test-user-123/logs

# Stop a tenant manually
curl -X POST http://localhost:8080/tenants/test-user-123/stop
```

## Understanding the Lifecycle

### Sleep/Wake Flow

1. **Initial Request (Sleeping)**
   - User makes authenticated request
   - Supervisor checks if tenant is running
   - Returns `401` with `X-Wake-Required: 1` header

2. **Warmup**
   - Frontend calls `POST /warmup {user_id}`
   - Supervisor creates/starts tenant container
   - Waits for healthy status (max 45 seconds)

3. **Active State**
   - Requests proxy through to tenant container
   - Supervisor injects `X-User-ID` header
   - Activity updates last-seen timestamp

4. **Idle Timeout**
   - After 20 minutes of inactivity
   - Reaper automatically stops container
   - Container and data persist (not deleted)

5. **Next Request**
   - Cycle repeats from step 1

### Session Management

- **JWT Cookie**: 30-minute sliding window
- **Refresh**: Auto-refreshed when ≤10 minutes remaining
- **Revocation**: On logout, JTI added to Redis blacklist
- **Security**: HttpOnly, Secure, SameSite=Strict

## Troubleshooting

### Services won't start

```bash
# Check all container statuses
docker compose ps

# View logs for specific service
docker compose logs supervisor
docker compose logs gateway
docker compose logs redis

# Restart all services
docker compose restart
```

### Tenant won't wake up

```bash
# Check if tenant image exists
docker images | grep tenant-base

# Rebuild tenant base image
make tenant-build

# Check supervisor logs for errors
docker compose logs supervisor | grep -i error
```

### Permission errors

```bash
# Supervisor runs as root to access Docker socket
# Tenants run as non-root user 'app'

# Check volume permissions
docker volume ls | grep vol__
docker volume inspect vol__app__<hash>__files
```

### Database locked errors

SQLite uses WAL mode to minimize locking:
- Central DB: `/var/lib/supervisor/central.db`
- Tenant DBs: `/app/data/db/history.db` (per container)

If you see locks:
```bash
# Restart supervisor
docker compose restart supervisor

# Check for zombie processes
docker compose exec supervisor ps aux
```

### Health check failing

```bash
# Test tenant health endpoint directly
docker compose exec supervisor sh -c \
  "wget -qO- http://<tenant-ip>:8080/health"

# Increase warmup timeout in .env
WARMUP_HEALTH_TIMEOUT_SECONDS=60
```

## Production Deployment

### 1. Configure Cloudflare Tunnel

```bash
# Install cloudflared locally
brew install cloudflare/cloudflare/cloudflared

# Authenticate
cloudflared tunnel login

# Create tunnel
cloudflared tunnel create xavior-backend

# Get tunnel token
cloudflared tunnel token <tunnel-id>
```

### 2. Update .env for Production

```bash
PUBLIC_BASE_URL=https://backend.yourdomain.com
COOKIE_DOMAIN=backend.yourdomain.com
COOKIE_JWT_SECRET=<strong-random-secret>
REDIS_PASSWORD=<strong-password>
TENANT_NAMESPACE_KEY=<32-random-bytes>
TUNNEL_TOKEN=<cloudflare-tunnel-token>
```

### 3. Configure Cloudflare Access

In Cloudflare dashboard:
- Enable Cloudflare Access
- Create access policy for your domain
- Configure authentication (OAuth, SAML, etc.)

### 4. Route Traffic

In Cloudflare Tunnel configuration:
- Route `backend.yourdomain.com` → `http://gateway:8080`

### 5. Deploy

```bash
docker compose up -d --build
```

### 6. Monitor

```bash
# Watch logs
docker compose logs -f supervisor

# Monitor resource usage
docker stats

# Check tenant status
curl https://backend.yourdomain.com/tenants
```

## Development Tips

### Rebuild tenant image after code changes

```bash
make tenant-build
docker compose restart supervisor
```

### Reset everything

```bash
# Stop and remove all containers, networks, volumes
docker compose down -v

# Start fresh
./setup.sh
```

### Debug tenant container

```bash
# Find tenant container name
docker ps | grep app__

# Exec into tenant
docker exec -it <container-name> sh

# Check files
ls -la /app/data/users/
ls -la /app/data/db/
```

### Modify tenant application

Edit `tenants/base-app/app.js` then rebuild:

```bash
make tenant-build
# Existing tenants won't auto-update - stop them first
docker compose exec supervisor curl -X POST http://localhost:4010/tenants/<user-id>/stop
```

## Useful Commands

```bash
# Quick rebuild and restart
make build && make up

# View supervisor logs
make logs

# Stop everything
make down

# Full cleanup
docker compose down -v
docker volume prune
docker network prune

# Check which tenants are running
docker ps --filter "label=tenant"

# View all tenant volumes
docker volume ls | grep "vol__app__"
```

## Next Steps

- Read `docs/ARCHITECTURE.md` for detailed design decisions
- Read `docs/API.md` for complete API reference
- Read `docs/ADDENDUM-v1.1.md` for configuration options
- Read `SECURITY.md` for security best practices

## Support

For issues or questions:
1. Check the logs: `docker compose logs -f supervisor`
2. Review the documentation in `docs/`
3. Open an issue on GitHub
