ARG NODE_VERSION=24.13.0-slim

FROM node:${NODE_VERSION} AS infisical-runtime
RUN apt-get update \
    && apt-get install -y --no-install-recommends bash curl ca-certificates \
    && curl -1sLf https://artifacts-cli.infisical.com/setup.deb.sh | bash \
    && apt-get update \
    && apt-get install -y --no-install-recommends infisical \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY entrypoint.sh /usr/local/bin/infisical-entrypoint
# COPY .infisical.json /app/.infisical.json
RUN chmod +x /usr/local/bin/infisical-entrypoint \
    && addgroup --system --gid 1001 nodejs \
    && adduser --system --uid 1001 --ingroup nodejs appuser \
    && chown -R appuser:nodejs /app
ENTRYPOINT ["/usr/local/bin/infisical-entrypoint"]

