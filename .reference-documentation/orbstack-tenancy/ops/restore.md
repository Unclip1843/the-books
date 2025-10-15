# Restore Playbook

1) Stop Supervisor
```bash
docker compose stop supervisor
```

2) Restore central DB
```bash
docker cp /path/to/central-YYYYMMDD-HHMMSS.db $(docker compose ps -q supervisor):/var/lib/supervisor/central.db
```

3) Restore a tenant volume (example: `vol__app__abcd1234__history`)
```bash
docker run --rm -v vol__app__abcd1234__history:/v -v /path/to/backup:/b busybox sh -c "rm -rf /v/* && tar xzf /b/vol__app__abcd1234__history-YYYYMMDD-HHMMSS.tgz -C /v"
```

4) Start Supervisor and warm the tenant
```bash
docker compose start supervisor
curl -X POST https://backend.xavior.ai/warmup -H 'content-type: application/json' -d '{"user_id":"<user-id>"}'
```
