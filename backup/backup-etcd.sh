#!/bin/bash
set -e

# Configure mc client if not already configured
if [ ! -f /root/.mc/config.json ]; then
    mc alias set s3 $S3_ENDPOINT $S3_ACCESS_KEY $S3_SECRET_KEY
fi

# Create backup directory if it doesn't exist
BACKUP_DIR="/backup"
mkdir -p $BACKUP_DIR

# Create backup with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="etcd-backup-${TIMESTAMP}.db"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

# Create ETCD snapshot
etcdctl snapshot save $BACKUP_PATH

# Compress backup
gzip $BACKUP_PATH

# Upload to S3
mc cp "${BACKUP_PATH}.gz" "s3/$S3_BUCKET/"

# Clean up local backup
rm -f "${BACKUP_PATH}.gz"

# Clean up old backups in S3
RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-7}  # Default to 7 days if not set
mc rm --force --recursive --older-than "${RETENTION_DAYS}d" "s3/$S3_BUCKET/"

echo "Backup completed successfully at $(date)"
