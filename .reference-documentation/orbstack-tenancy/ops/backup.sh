#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR=${1:-/mnt/data/backups}
mkdir -p "$BACKUP_DIR"
DATE=$(date +%Y%m%d-%H%M%S)

echo "[*] Backing up central DB"
docker cp $(docker compose ps -q supervisor):/var/lib/supervisor/central.db "$BACKUP_DIR/central-$DATE.db"

echo "[*] Backing up tenant volumes (history + files)"
for vol in $(docker volume ls -q | grep -E '^vol__.*__(history|files)$'); do
  TAR="$BACKUP_DIR/${vol}-$DATE.tgz"
  echo "    - $vol → $TAR"
  docker run --rm -v "$vol":/v -v "$BACKUP_DIR":/b busybox sh -c "tar czf /b/$(basename $TAR) -C /v ."
done

echo "[*] Done. Files in $BACKUP_DIR"
