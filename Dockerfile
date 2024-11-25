ARG ETCD_VERSION=3.5

FROM docker.io/bitnami/etcd:${ETCD_VERSION}

# Switch to root user
USER root

VOLUME ["/bitnami/etcd"]

# Copy our custom entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Use our custom entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/opt/bitnami/scripts/etcd/run.sh"]

