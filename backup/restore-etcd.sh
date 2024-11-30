#!/bin/bash
set -e

# Configure mc client if not already configured
if [ ! -f /root/.mc/config.json ]; then
    mc alias set s3 $S3_ENDPOINT $S3_ACCESS_KEY $S3_SECRET_KEY
fi

# Create temporary directory for restore
RESTORE_DIR="/backup/restore"
mkdir -p $RESTORE_DIR

# Get latest backup from S3
LATEST_BACKUP=$(mc ls s3/$S3_BUCKET/ | sort -r | head -n1 | awk '{print $5}')
if [ -z "$LATEST_BACKUP" ]; then
    echo "No backup found in S3"
    exit 1
fi

# Download and extract backup
mc cp "s3/$S3_BUCKET/$LATEST_BACKUP" "$RESTORE_DIR/"
gunzip "$RESTORE_DIR/$LATEST_BACKUP"
BACKUP_FILE="${RESTORE_DIR}/${LATEST_BACKUP%.*}"

# Stop ETCD service (if running)
pkill etcd || true
sleep 5

# Restore from snapshot
etcdctl snapshot restore "$BACKUP_FILE" \
    --data-dir /bitnami/etcd/data

# Fix permissions
chmod 700 -R /bitnami/etcd
chown -R 1001:1001 /bitnami/etcd

# Clean up
rm -rf $RESTORE_DIR

echo "Restore completed successfully at $(date)"
