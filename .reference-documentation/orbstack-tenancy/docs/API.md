# Supervisor API

## Public
- `POST /auth/login` → sets JWT cookie; returns profile
- `POST /auth/logout` → revokes token (Redis); clears cookie
- `GET /session/status` → `{ valid, userId, email, plan, onboarding_completed }`
- `POST /warmup {user_id}` → `{ tenant, state:'running' }`
- `GET /status?user_id=...` → `{ tenant, running }`
- `POST /admin/ingest-summary` → 204

## Admin
- `GET /tenants` → list
- `GET /tenants/:id/logs?tail=1000`
- `POST /tenants/:id/stop`
