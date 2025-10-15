# Architecture

- Cloudflare Access/Tunnel is the public edge (TLS, WAF).
- nginx is a **thin guard**: rate-limit, size caps, access logs.
- Supervisor does **authZ + JWT issuance/refresh**, **reverse proxy with X-User-ID**, **warmup/idle reaper**, **admin APIs**, and **summary ingest**.
- Each user maps to a **tenant**: dedicated Docker network + two volumes (files & history), container runs **non-root** with caps dropped & resource limits.
- Central DB is **SQLite (WAL)**; per-tenant **SQLite** for history.

## Lifecycle
- First hit when sleeping → `401` with `X-Wake-Required: 1`.
- Frontend shows “Waking…” and `POST /warmup {user_id}`.
- Supervisor creates/starts tenant; waits HEALTHY (≤45s).
- Proxy injects `X-User-ID` to tenant for every request.
- No traffic for 20 minutes → Supervisor stops tenant.
