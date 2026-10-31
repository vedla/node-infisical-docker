ARG NODE_VERSION=24.13.0-slim

FROM node:${NODE_VERSION} AS infisical-runtime

RUN apt-get update \
    && apt-get install -y --no-install-recommends bash curl wget ca-certificates tini \
    && curl -1sLf https://artifacts-cli.infisical.com/setup.deb.sh | bash \
    && apt-get update \
    && apt-get install -y --no-install-recommends infisical \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY entrypoint.sh /usr/local/bin/infisical-entrypoint

# /app stays owned by root: images built on this one copy their app in as root and make only the
# directories it writes to writable by appuser, so a compromised process cannot change its code.
RUN chmod +x /usr/local/bin/infisical-entrypoint \
    && addgroup --system --gid 1001 nodejs \
    && adduser --system --uid 1001 --ingroup nodejs appuser

ENV TURBO_TELEMETRY_DISABLED=1
ENV NEXT_TELEMETRY_DISABLED=1
ENV TELEMETRY_DISABLED=1

# tini runs as PID 1, passes SIGTERM on to the app, and reaps zombie processes.
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/infisical-entrypoint"]

