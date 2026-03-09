# syntax=docker/dockerfile:1.7
FROM node:22-bookworm AS build

ARG NPM_CA_CERT_B64=

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    build-essential \
    pkg-config \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Optional: trust corporate/intercepting CA for package downloads.
RUN if [ -n "${NPM_CA_CERT_B64}" ]; then \
    echo "${NPM_CA_CERT_B64}" | base64 -d > /usr/local/share/ca-certificates/npm-registry-ca.crt; \
    update-ca-certificates; \
    fi

ENV HUSKY=0 \
    YARN_ENABLE_IMMUTABLE_INSTALLS=false \
    NODE_OPTIONS=--no-node-snapshot

COPY lighthouse-frontend/ ./

RUN corepack enable && \
    if [ -f /usr/local/share/ca-certificates/npm-registry-ca.crt ]; then \
    export NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/npm-registry-ca.crt; \
    fi && \
    yarn install && \
    yarn build:all

FROM node:22-bookworm-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /app ./

# Backstage backend build outputs a bundled archive; extract it for runtime.
RUN tar xzf /app/packages/backend/dist/bundle.tar.gz -C /app && \
    rm -f /app/packages/backend/dist/bundle.tar.gz

EXPOSE 7007

ENV NODE_ENV=production \
    NODE_OPTIONS=--no-node-snapshot

CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
