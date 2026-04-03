ARG ANYTHINGLLM_VERSION=1.12.0
FROM mintplexlabs/anythingllm:${ANYTHINGLLM_VERSION}

USER root

RUN chgrp -R 0 /app && \
    chmod -R g+rwX /app && \
    mkdir -p /app/server/storage /app/collector/hotdir && \
    chgrp -R 0 /usr/local/bin && \
    chmod -R g+rwX /usr/local/bin

RUN cd /app/server && CHECKPOINT_DISABLE=1 npx prisma generate --schema=./prisma/schema.prisma 2>&1 || true

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod 755 /usr/local/bin/docker-entrypoint.sh && \
    chgrp 0 /usr/local/bin/docker-entrypoint.sh && \
    chmod g+rx /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/bin/bash", "/usr/local/bin/docker-entrypoint.sh"]

ENV STORAGE_DIR=/app/server/storage \
    SERVER_PORT=3000
