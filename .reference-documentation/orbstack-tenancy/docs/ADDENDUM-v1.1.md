# v1.1 Addendum — Complete Operational Spec

## Global
- `IDLE_MINUTES=20`, `COOKIE_TTL_MINUTES=30`, `SLIDING_REFRESH_WINDOW_MINUTES=10`
- Warmup timeout: 45s; retries with jitter; anti-stampede controls.
- nginx guards: `client_max_body_size 10m`, `limit_req` for `/` and `/warmup`.

## JWT + Redis
- Cookie: HttpOnly, Secure, SameSite=Strict, Domain configured.
- Claims: `{ sub, email, plan, onboarding_completed, jti, iat, exp }`.
- Sliding refresh when ≤10 minutes to expiry; Redis `jwt:revoked:<jti>` on logout.

## Sleep/Wake
- Activity updates last-seen; idle reaper stops after 20m.
- Warmup debounced per-user via Redis `SETNX` key with TTL.

## Routing
- Supervisor reverse-proxies to tenant by container IP; injects `X-User-ID`.

## Admin
- `/tenants`, `/tenants/:id/status`, `/tenants/:id/stop`, `/tenants/:id/logs?tail=N`.

## Data
- Central SQLite (WAL) holds users and aggregate summaries from tenants; per-tenant history stays local.
