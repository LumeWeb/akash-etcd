#!/bin/bash
set -e

# Ensure the data directory exists with correct permissions
mkdir -p /bitnami/etcd/data
chmod 700 -R /bitnami/etcd
chown -R 1001:1001 /bitnami/etcd

# Initialize backup system if enabled and environment variables are set
BACKUP_ENABLED=${BACKUP_ENABLED:-true}
if [ "$BACKUP_ENABLED" = "true" ] && [ ! -z "$S3_ENDPOINT" ] && [ ! -z "$S3_ACCESS_KEY" ] && [ ! -z "$S3_SECRET_KEY" ] && [ ! -z "$S3_BUCKET" ]; then
    /usr/local/bin/init-backup.sh
else
    echo "Backup system not enabled or missing required S3 environment variables"
fi

# Call the original entrypoint with all arguments
exec /opt/bitnami/scripts/etcd/entrypoint.sh "$@"
