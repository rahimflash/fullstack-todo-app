#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="mongodb_backup_${TIMESTAMP}"

echo "Starting MongoDB backup..."

mkdir -p "$BACKUP_DIR"
docker exec todo-mongodb mkdir -p /backup
docker exec todo-mongodb mongodump --out="/backup/${BACKUP_NAME}"
docker cp "todo-mongodb:/backup/${BACKUP_NAME}" "${BACKUP_DIR}/"

cd "$BACKUP_DIR"
tar -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"
rm -rf "${BACKUP_NAME}"

echo "Backup completed: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"

# Clean up old backups if directory still exists
if [ -d "$BACKUP_DIR" ]; then
    find "$BACKUP_DIR" -name "mongodb_backup_*.tar.gz" -mtime +7 -delete
else
    echo "Backup directory not found — skipping cleanup"
fi