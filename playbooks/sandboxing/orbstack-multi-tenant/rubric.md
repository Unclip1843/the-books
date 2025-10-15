# Rubric — OrbStack Multi-Tenant

Confirm these items before offering the sandbox to others.

## Isolation

- [ ] Tenants receive dedicated container/VM namespaces with no shared volumes.
- [ ] Network segmentation enforced (per-tenant VLAN/subnet or firewall rules).
- [ ] Default credentials removed; secrets injected per tenant.

## Provisioning

- [ ] `make` or script-based bootstrap completes on a clean macOS host.
- [ ] Idempotent reruns (no duplicate containers, handles partial failures).
- [ ] Teardown cleans tenant resources without affecting others.

## Exposure

- [ ] Ingress routes (Nginx/Cloudflare) issue TLS certificates automatically.
- [ ] Access control (Basic Auth, OAuth, or mTLS) configured per tenant.
- [ ] Observability for ingress (logs, request metrics) in place.

## Operations

- [ ] Monitoring alerts on resource exhaustion (CPU, disk, RAM).
- [ ] Backup/restore path defined for tenant data.
- [ ] Runbook for rotating tenant secrets and revoking access.
