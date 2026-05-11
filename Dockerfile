FROM debian:bookworm-slim AS atlas

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSf https://atlasgo.sh | sh \
    && if [ ! -x /usr/local/bin/atlas ] && [ -x /root/.local/bin/atlas ]; then \
        install -m 0755 /root/.local/bin/atlas /usr/local/bin/atlas; \
    fi \
    && test -x /usr/local/bin/atlas

FROM debian:bookworm-slim AS telemetry-db

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        make \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/*

COPY --from=atlas /usr/local/bin/atlas /usr/local/bin/atlas

WORKDIR /app

COPY atlas.hcl schema.hcl Makefile ./
COPY migrations ./migrations

RUN atlas version

CMD ["make", "db-apply"]
