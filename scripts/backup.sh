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

# Build list of files to backup
FILES_TO_BACKUP=""
[ -f "atlas/.env" ] && FILES_TO_BACKUP="$FILES_TO_BACKUP atlas/.env"
[ -f "local/.env" ] && FILES_TO_BACKUP="$FILES_TO_BACKUP local/.env"
[ -f ".install-info" ] && FILES_TO_BACKUP="$FILES_TO_BACKUP .install-info"

if [ -z "$FILES_TO_BACKUP" ]; then
    echo "⚠️  No configuration files found to backup"
    exit 1
fi

tar -czf "$BACKUP_FILE" $FILES_TO_BACKUP

echo "✅ Backup created: $BACKUP_FILE"
echo ""
echo "Backed up files:"
for file in $FILES_TO_BACKUP; do
    echo "  - $file"
done
