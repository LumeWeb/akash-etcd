#!/bin/bash
set -e

# Ensure the data directory exists with correct permissions
mkdir -p /bitnami/etcd/data
chmod 700 -R /bitnami/etcd
chown -R 1000:1000 /bitnami/etcd

# Call the original entrypoint with all arguments
exec /opt/bitnami/scripts/etcd/entrypoint.sh "$@"
