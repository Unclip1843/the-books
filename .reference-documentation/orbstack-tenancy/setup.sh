#!/bin/bash
set -e

# OrbStack Tenancy Setup Script
# This script automates the setup process for new users cloning the repository

echo "=================================================="
echo "   OrbStack Tenancy Setup"
echo "=================================================="
echo ""

# Check prerequisites
echo "[1/6] Checking prerequisites..."

# Check for Docker/OrbStack
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker/OrbStack is not installed or not in PATH"
    echo "   Please install OrbStack from: https://orbstack.dev"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ Error: Docker daemon is not running"
    echo "   Please start OrbStack"
    exit 1
fi

echo "✓ Docker/OrbStack is installed and running"

# Check for docker compose
if ! docker compose version &> /dev/null; then
    echo "❌ Error: docker compose is not available"
    exit 1
fi

echo "✓ docker compose is available"

# Check current directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: Please run this script from the orbstack-tenancy directory"
    exit 1
fi

echo ""
echo "[2/6] Setting up environment configuration..."

# Create .env from .env.example if it doesn't exist
if [ -f ".env" ]; then
    echo "⚠️  .env file already exists. Skipping creation."
    echo "   If you want to reset it, delete .env and run this script again."
else
    cp .env.example .env
    echo "✓ Created .env from .env.example"
    echo ""
    echo "⚠️  IMPORTANT: Review and update .env file with your settings:"
    echo "   - Set strong COOKIE_JWT_SECRET (32+ characters)"
    echo "   - Set strong REDIS_PASSWORD"
    echo "   - Set strong TENANT_NAMESPACE_KEY (32 bytes)"
    echo "   - Add your ANTHROPIC_API_KEY and/or OPENAI_API_KEY"
    echo "   - Update COOKIE_DOMAIN and PUBLIC_BASE_URL for production"
    echo ""
fi

echo ""
echo "[3/6] Building tenant base image..."
echo "   This may take a few minutes on first run..."

if docker compose --profile build-only build tenant-base-build; then
    echo "✓ Tenant base image built successfully"
else
    echo "❌ Error: Failed to build tenant base image"
    exit 1
fi

echo ""
echo "[4/6] Building and starting services..."
echo "   Starting: gateway (nginx), supervisor, redis"
echo "   (Add '--profile prod' to include cloudflared for production)"

if docker compose up -d --build gateway supervisor redis; then
    echo "✓ Services started successfully"
else
    echo "❌ Error: Failed to start services"
    exit 1
fi

echo ""
echo "[5/6] Waiting for services to be healthy..."

# Wait for supervisor to be ready
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if curl -sf http://localhost:8080/health > /dev/null 2>&1; then
        echo "✓ Services are healthy and responding"
        break
    fi
    attempt=$((attempt + 1))
    if [ $attempt -eq $max_attempts ]; then
        echo "⚠️  Warning: Services may not be fully ready yet"
        echo "   Check status with: docker compose ps"
        echo "   Check logs with: docker compose logs -f supervisor"
        break
    fi
    sleep 2
done

echo ""
echo "[6/6] Verifying setup..."

# Show running containers
echo ""
echo "Running containers:"
docker compose ps

echo ""
echo "=================================================="
echo "   Setup Complete!"
echo "=================================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Review configuration:"
echo "   cat .env"
echo ""
echo "2. Test the health endpoint:"
echo "   curl http://localhost:8080/health"
echo ""
echo "3. View logs:"
echo "   docker compose logs -f supervisor"
echo ""
echo "4. For production deployment:"
echo "   - Configure Cloudflare Tunnel (see docs/ARCHITECTURE.md)"
echo "   - Update TUNNEL_TOKEN in .env"
echo "   - Set production values for COOKIE_DOMAIN, PUBLIC_BASE_URL"
echo "   - Rotate all secrets (JWT_SECRET, REDIS_PASSWORD, etc.)"
echo ""
echo "5. Admin endpoints (local development):"
echo "   - List tenants: curl http://localhost:8080/tenants"
echo "   - Health check: curl http://localhost:8080/health"
echo ""
echo "Useful commands:"
echo "  make up      - Start services"
echo "  make down    - Stop services"
echo "  make logs    - View supervisor logs"
echo "  make build   - Rebuild all images"
echo ""
echo "For more information, see:"
echo "  - README.md"
echo "  - docs/ARCHITECTURE.md"
echo "  - docs/API.md"
echo "=================================================="
