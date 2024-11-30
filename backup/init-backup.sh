#!/bin/bash
set -e

# Validate backup is enabled
BACKUP_ENABLED=${BACKUP_ENABLED:-true}
if [ "$BACKUP_ENABLED" != "true" ]; then
    echo "Backup system is disabled via BACKUP_ENABLED=false"
    exit 0
fi

# Install crontab
crontab /backup/crontab

# Start crond in background
/usr/sbin/crond

# Configure mc client
mc alias set s3 $S3_ENDPOINT $S3_ACCESS_KEY $S3_SECRET_KEY

echo "Backup system initialized successfully"
