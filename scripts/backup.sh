#!/bin/bash

# Backup script for Alesqui Intelligence
# Creates a timestamped backup of configuration files

BACKUP_DIR="${HOME}/alesqui-backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/alesqui-config-${TIMESTAMP}.tar.gz"

mkdir -p "$BACKUP_DIR"

echo "Creating backup..."
tar -czf "$BACKUP_FILE" \
    atlas/.env \
    local/.env \
    .install-info \
    2>/dev/null || true

echo "✅ Backup created: $BACKUP_FILE"
