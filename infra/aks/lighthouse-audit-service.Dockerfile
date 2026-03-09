# syntax=docker/dockerfile:1.7
FROM node:22-slim

WORKDIR /app

ARG NPM_LOGLEVEL=warn
ARG NPM_CA_CERT_B64=

ENV NODE_ENV=production \
    npm_config_update_notifier=false \
    npm_config_loglevel=${NPM_LOGLEVEL}

# Install build tools and Chromium runtime dependencies required by Lighthouse.
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    python3 \
    make \
    g++ \
    build-essential \
    pkg-config \
    libatomic1 \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgbm1 \
    libgcc1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    lsb-release \
    wget \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Optional: trust a corporate/intercepting CA for npm registry TLS.
RUN if [ -n "${NPM_CA_CERT_B64}" ]; then \
    echo "${NPM_CA_CERT_B64}" | base64 -d > /usr/local/share/ca-certificates/npm-registry-ca.crt; \
    update-ca-certificates; \
    fi

COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    --mount=type=cache,target=/root/.cache/node-gyp \
    if [ -f /usr/local/share/ca-certificates/npm-registry-ca.crt ]; then \
    export NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/npm-registry-ca.crt; \
    export NPM_CONFIG_CAFILE=/usr/local/share/ca-certificates/npm-registry-ca.crt; \
    npm config set cafile /usr/local/share/ca-certificates/npm-registry-ca.crt; \
    npm config set strict-ssl true; \
    fi; \
    if [ -f package-lock.json ]; then \
    npm ci --include=dev --no-audit --no-fund --foreground-scripts --loglevel=${NPM_LOGLEVEL}; \
    else \
    npm install --include=dev --no-audit --no-fund --foreground-scripts --loglevel=${NPM_LOGLEVEL}; \
    fi

COPY . .
RUN npm run build
RUN npm prune --omit=dev --no-audit --no-fund

EXPOSE 4008
CMD ["node", "cjs/run.js"]
