#!/bin/bash

# Backup script for Alesqui Intelligence
# Creates a timestamped backup of configuration files

# Determine script location and installation directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

BACKUP_DIR="${HOME}/alesqui-backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/alesqui-config-${TIMESTAMP}.tar.gz"

mkdir -p "$BACKUP_DIR"

echo "Creating backup from: $INSTALL_DIR"
cd "$INSTALL_DIR"

tar -czf "$BACKUP_FILE" \
    atlas/.env \
    local/.env \
    .install-info \
    2>/dev/null || true

echo "✅ Backup created: $BACKUP_FILE"
