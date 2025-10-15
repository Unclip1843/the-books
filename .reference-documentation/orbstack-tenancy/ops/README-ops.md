# Ops Guide

- Nightly backups: add a cron on the host to run `ops/backup.sh` to your desired directory.
- Rotate `TENANT_NAMESPACE_KEY` carefully; keep old key if you need stable tenant names.
- Update base images monthly; pin image digests for reproducibility.
- Logs: use Supervisor `/tenants/:id/logs?tail=1000` for quick triage.
