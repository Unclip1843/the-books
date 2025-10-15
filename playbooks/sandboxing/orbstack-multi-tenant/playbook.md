# OrbStack Multi-Tenant Playbook

## Overview

Provision reproducible, isolated sandboxes on macOS using OrbStack, Nginx, and Cloudflare tunnels so multiple tenants can run workloads safely.

## Rubric

Use `rubric.md` once the implementation lands to ensure tenancy isolation and operational hygiene.

## Implementation (TODO)

- [ ] Verify OrbStack version compatibility (`orbstack --version`).
- [ ] Audit existing `orbstack-tenancy` repo copy for secrets or upstream git metadata.
- [ ] Document prerequisite tooling (Homebrew, Docker Compose, cloudflared).
- [ ] Step-by-step provisioning (Makefile targets, bootstrap scripts).
- [ ] Tenant lifecycle management (create, snapshot, destroy).
- [ ] Network exposure (per-tenant hostnames, TLS, auth).
- [ ] Monitoring & logging (supervisor configs, alerts).

## Scripts

- Place automation (bootstrap, teardown, health checks) inside `scripts/`.

## Implementation Assets

- Sync sanitized configs from `orbstack-tenancy/` into `implementation/` as they are reviewed.

Once validated, link each step back to the scripts in `orbstack-tenancy/` and include sample `.env` templates.
