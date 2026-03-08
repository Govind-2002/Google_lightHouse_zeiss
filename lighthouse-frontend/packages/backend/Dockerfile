# This dockerfile builds an image for the backend package.
# It should be executed with the root of the repo as docker context.

# Stage 1: Build stage with full image for native module compilation
FROM node:20-bookworm AS build

# Set Python interpreter for node-gyp
ENV PYTHON=/usr/bin/python3

# Install system build dependencies required for native node modules
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-dev \
    g++ \
    gcc \
    make \
    build-essential \
    pkg-config \
    git \
    libsqlite3-dev \
    sqlite3 \
    ca-certificates \
    curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Yarn configuration
COPY .yarn ./.yarn
COPY .yarnrc.yml ./
COPY backstage.json ./

# Copy dependency skeleton
COPY yarn.lock package.json packages/backend/dist/skeleton.tar.gz ./

RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz

# Production mode
ENV NODE_ENV=production

# Install dependencies - continue even if optional deps fail to build
RUN --mount=type=cache,target=/root/.cache/yarn,sharing=locked \
    yarn workspaces focus --all --production; \
    yarn cache clean

# Fix ownership for node user
RUN chown -R node:node /app

# Stage 2: Production stage with slim image
FROM node:20-bookworm-slim

# Install only runtime dependencies for native modules
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libsqlite3-0 \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

USER node

WORKDIR /app

# Copy node_modules from build stage (includes compiled native modules)
COPY --from=build --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/package.json ./
COPY --from=build --chown=node:node /app/packages ./packages

# Copy Yarn configuration (needed for workspace resolution)
COPY --chown=node:node .yarn ./.yarn
COPY --chown=node:node .yarnrc.yml ./
COPY --chown=node:node backstage.json ./

# Production mode
ENV NODE_ENV=production

# Required for scaffolder plugin
ENV NODE_OPTIONS="--no-node-snapshot"

# Copy examples (optional)
COPY --chown=node:node examples ./examples

# Copy backend bundle and config
COPY --chown=node:node packages/backend/dist/bundle.tar.gz app-config*.yaml ./

RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
