# Security Policy

- **Edge-first**: Cloudflare Access/WAF; no public Supervisor port.
- **Isolation**: non-root tenants, caps dropped, pids/CPU/RAM limits, dedicated networks/volumes; no Docker socket in tenants.
- **Secrets**: injected at boot; rotate regularly; never baked in images.
- **Identity**: JWT cookie (30m sliding), Redis revocation; tenants trust `X-User-ID` only.
- **Backups**: nightly snapshots of central DB + tenant volumes; test restore monthly.
