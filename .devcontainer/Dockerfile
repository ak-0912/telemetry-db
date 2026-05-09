FROM mcr.microsoft.com/devcontainers/base:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Atlas CLI — https://atlasgo.io (installer often uses ~/.local/bin; normalize to /usr/local/bin)
RUN curl -sSf https://atlasgo.sh | sh \
 && if [ ! -x /usr/local/bin/atlas ] && [ -x /root/.local/bin/atlas ]; then \
      install -m 0755 /root/.local/bin/atlas /usr/local/bin/atlas; \
    fi \
 && test -x /usr/local/bin/atlas

ENV PATH="/usr/local/bin:${PATH}"

USER vscode
RUN atlas version