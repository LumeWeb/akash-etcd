#!/bin/bash
set -e

# Validate backup is enabled
BACKUP_ENABLED=${BACKUP_ENABLED:-true}
if [ "$BACKUP_ENABLED" != "true" ]; then
    echo "Backup system is disabled via BACKUP_ENABLED=false"
    exit 0
fi

# Configure mc client
mc alias set s3 $S3_ENDPOINT $S3_ACCESS_KEY $S3_SECRET_KEY

# Create crontab file
echo "0 0 * * * /usr/local/bin/backup-etcd.sh" > /etc/crontab

# Start supercronic in background
/usr/local/bin/supercronic /etc/crontab &

echo "Backup system initialized successfully"
