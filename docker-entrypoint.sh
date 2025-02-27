#!/bin/bash
set -e

if [ -f /akash-cfg/etcd.env ]; then
  set -a
  source /akash-cfg/config.env
  set +a
fi

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

export ETCD_ADVERTISE_CLIENT_URLS="http://${AKASH_INGRESS_HOST}:${AKASH_EXTERNAL_PORT_2379}"

# Load libraries
. /opt/bitnami/scripts/libos.sh
. /opt/bitnami/scripts/libetcd.sh

# Load etcd environment settings
. /opt/bitnami/scripts/etcd-env.sh

am_i_root && ensure_user_exists "$ETCD_DAEMON_USER" --group "$ETCD_DAEMON_GROUP"

chown -R $ETCD_DAEMON_USER $ETCD_VOLUME_DIR

# Call the original entrypoint with all arguments
exec /opt/bitnami/scripts/etcd/entrypoint.sh "$@"
