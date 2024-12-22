ARG ETCD_VERSION=3.5
ARG SUPERCRONIC_VERSION=0.2.33

FROM docker.io/bitnami/etcd:${ETCD_VERSION}

# Switch to root user
USER root

# Install required packages
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install minio client
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc && \
    chmod +x /usr/local/bin/mc

# Install supercronic
RUN wget https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-amd64 -O /usr/local/bin/supercronic && \
    chmod +x /usr/local/bin/supercronic

VOLUME ["/bitnami/etcd"]

# Copy backup scripts directly to /usr/local/bin
COPY backup/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

# Copy our custom entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Use our custom entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/opt/bitnami/scripts/etcd/run.sh"]
