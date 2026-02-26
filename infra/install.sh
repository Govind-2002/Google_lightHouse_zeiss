#!/bin/bash
set -e

echo "Starting VM bootstrap..."

export DEBIAN_FRONTEND=noninteractive

LIGHTHOUSE_REPO_URL="https://github.com/spotify/lighthouse-audit-service.git"
LIGHTHOUSE_REPO_REF="master"

# -----------------------------
# System Update
# -----------------------------
apt-get update -y
apt-get upgrade -y

#install utilities
apt-get install -y jq

# -----------------------------
# Install Docker + Compose
# -----------------------------
apt-get install -y docker.io git
apt-get install -y docker-compose-plugin || apt-get install -y docker-compose

systemctl enable docker
systemctl start docker

usermod -aG docker azureuser

# -----------------------------
# Move to Home
# -----------------------------
cd /home/azureuser

# -----------------------------
# Clone or Refresh Repo
# -----------------------------
if [ ! -d "lighthouse-audit-service/.git" ]; then
  rm -rf lighthouse-audit-service
  git clone --branch "$LIGHTHOUSE_REPO_REF" --single-branch "$LIGHTHOUSE_REPO_URL" lighthouse-audit-service
else
  git -C lighthouse-audit-service fetch --all --prune
  git -C lighthouse-audit-service checkout "$LIGHTHOUSE_REPO_REF"
  git -C lighthouse-audit-service reset --hard "origin/$LIGHTHOUSE_REPO_REF"
  git -C lighthouse-audit-service clean -fdx
fi

echo "Using commit: $(git -C lighthouse-audit-service rev-parse --short HEAD)"

# -----------------------------
# Overwrite Dockerfile (Stable Build)
# -----------------------------
cat <<EOF > lighthouse-audit-service/Dockerfile
FROM node:22

WORKDIR /app

# Install build tools + Chromium dependencies
RUN apt-get update && apt-get install -y \
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
  xdg-utils

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

EXPOSE 4008

CMD ["node", "cjs/run.js"]
EOF

# -----------------------------
# Create docker-compose.yml
# -----------------------------
cat <<EOF > docker-compose.yml

services:
  postgres:
    image: postgres:15
    container_name: postgres
    environment:
      POSTGRES_USER: lighthouse
      POSTGRES_PASSWORD: lighthouse
      POSTGRES_DB: lighthouse
    volumes:
      - pgdata:/var/lib/postgresql/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U lighthouse"]
      interval: 5s
      timeout: 5s
      retries: 5

  lighthouse:
    build: ./lighthouse-audit-service
    container_name: lighthouse
    ports:
      - "4008:4008"
    environment:
      PGHOST: postgres
      PGUSER: lighthouse
      PGPASSWORD: lighthouse
      PGDATABASE: lighthouse
      LAS_PORT: 4008
      LAS_HOST: 0.0.0.0
    depends_on:
      postgres:
        condition: service_healthy
    restart: unless-stopped

volumes:
  pgdata:
EOF

# -----------------------------
# Detect Compose Command
# -----------------------------
if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD="docker-compose"
else
  echo "ERROR: Docker Compose not found"
  exit 1
fi

# -----------------------------
# Build and Start
# -----------------------------
$COMPOSE_CMD down || true
$COMPOSE_CMD up -d --build --force-recreate

echo "Installation complete."