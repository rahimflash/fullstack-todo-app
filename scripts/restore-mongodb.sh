#!/bin/bash
set -euo pipefail

# MongoDB Restore Script
if [ -z "${1:-}" ]; then
    echo "Usage: $0 <backup-file.tar.gz>"
    exit 1
fi

BACKUP_FILE="$1"
TEMP_DIR="/tmp/mongodb_restore_$$"
CONTAINER_NAME="todo-mongodb"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: File '$BACKUP_FILE' does not exist."
    exit 1
fi

echo "Starting MongoDB restore from $BACKUP_FILE..."

mkdir -p "$TEMP_DIR"
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"

BACKUP_DIR=$(find "$TEMP_DIR" -name "mongodb_backup_*" -type d | head -n 1)

if [ -z "$BACKUP_DIR" ]; then
    echo "Error: No valid backup directory found in archive"
    rm -rf "$TEMP_DIR"
    exit 1
fi

docker cp "$BACKUP_DIR" "${CONTAINER_NAME}:/restore"

echo "Restoring backup inside container..."
docker exec "${CONTAINER_NAME}" mongorestore \
    --drop \
    "/restore/$(basename "$BACKUP_DIR")"

# Cleanup
rm -rf "$TEMP_DIR"
docker exec "${CONTAINER_NAME}" rm -rf /restore

echo "Restore completed successfully from $BACKUP_FILE"
