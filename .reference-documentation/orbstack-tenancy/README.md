# OrbStack Tenancy (nginx-guarded, Supervisor-controlled)

Secure per-user containers on macOS (OrbStack), gated by Cloudflare Access/Tunnel, guarded by nginx, and orchestrated by a Go Supervisor.

## Features

- **Authentication**: JWT cookie (30m sliding window) + Redis-backed revocation
- **Isolation**: One container per user (non-root, all caps dropped), dedicated network & volumes
- **Lifecycle**: Automatic sleep after **20 min** idle; wake on request with 45s warmup flow
- **Data**: Hybrid storage — central SQLite (admin/auth/aggregates) + per-tenant SQLite (history) + per-tenant files volume
- **Security**: Multi-layered defense with Cloudflare edge, nginx rate limiting, container isolation
- **Resource Limits**: 2 CPU cores, 4GB RAM, 512 PIDs per tenant
- **Admin**: Supervisor APIs for list/status/logs/stop and summary ingest

## Quick Start

### Automated Setup (Recommended)

```bash
./setup.sh
```

The setup script checks prerequisites, configures `.env`, builds images, and starts the local stack (gateway, supervisor, redis). Re-run with `docker compose --profile prod up` to include Cloudflare.

> 🔐 **Secrets:** Production-quality secrets are distributed via the internal secrets bundle. Always sync the latest copy before editing `.env` so your local instance matches shared credentials.

### Manual Setup

```bash
cp .env.example .env
# Edit .env and set your secrets (COOKIE_JWT_SECRET, REDIS_PASSWORD, TENANT_NAMESPACE_KEY).
# Pull values from the shared secrets bundle before running locally.

docker compose --profile build-only build tenant-base-build
docker compose up -d --build
# Include cloudflared once TUNNEL_TOKEN is set
# docker compose --profile prod up -d --build

# Verify health
curl http://localhost:8080/health
```

## Documentation

- **[GETTING_STARTED.md](GETTING_STARTED.md)** - Complete setup guide with examples and troubleshooting
- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** - System design and architecture decisions
- **[docs/API.md](docs/API.md)** - API reference for all endpoints
- **[docs/ADDENDUM-v1.1.md](docs/ADDENDUM-v1.1.md)** - Configuration options and operational settings
- **[SECURITY.md](SECURITY.md)** - Security model and best practices

## Prerequisites

- **macOS** with [OrbStack](https://orbstack.dev) installed (or Docker Desktop)
- **Docker Compose** v2+
- **Cloudflare Account** (for production deployment with Tunnel/Access)

### Version Alignment
- OrbStack / Docker Engine 1.0+ (Docker 26+)
- Docker Compose v2.24 or newer
- Go 1.22.x (see `supervisor/go.mod`)
- Node.js 22.x (tenant base image)
- npm bundled with Node 22 (`npm ci` respects `package-lock.json`)
- Redis 7.x (container image `redis:7-alpine`)

## Architecture

```
Cloudflare Access/Tunnel → nginx Gateway (:8080) → Supervisor (:4010) → Tenant Containers
                                                          ↓
                                                    Redis + SQLite
```

Each user gets an isolated container with:
- Dedicated Docker network
- Two persistent volumes (files + history database)
- Resource limits enforced
- Non-root execution
- No Docker socket access

## Common Commands

```bash
make up          # Start all services
make down        # Stop all services
make logs        # View supervisor logs
make build       # Rebuild all images
make tenant-build # Rebuild tenant base image
# Production only
# docker compose --profile prod up -d
```

## Production Deployment

1. Configure Cloudflare Tunnel and get `TUNNEL_TOKEN`
2. Update `.env` with production values:
   - `PUBLIC_BASE_URL=https://backend.yourdomain.com`
   - `COOKIE_DOMAIN=backend.yourdomain.com`
   - Strong secrets for `COOKIE_JWT_SECRET`, `REDIS_PASSWORD`, `TENANT_NAMESPACE_KEY`
3. In Cloudflare, route your domain to `gateway:8080`
4. Deploy: `docker compose --profile prod up -d --build`

See [GETTING_STARTED.md](GETTING_STARTED.md) for detailed production setup instructions.

## Testing

```bash
# Login
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"user_id":"test-user","email":"test@example.com","plan":"free","onboarding_completed":true}' \
  -c cookies.txt

# Wake up tenant
curl -X POST http://localhost:8080/warmup \
  -H "Content-Type: application/json" \
  -d '{"user_id":"test-user"}' \
  -b cookies.txt

# Send chat message
curl -X POST http://localhost:8080/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello!"}' \
  -b cookies.txt
```

## License

See [LICENSE](LICENSE)
