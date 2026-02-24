#!/bin/bash
set -e

echo "Starting VM bootstrap..."

export DEBIAN_FRONTEND=noninteractive

LIGHTHOUSE_REPO_URL=${LIGHTHOUSE_REPO_URL:-"https://github.com/spotify/lighthouse-audit-service.git"}
#BACKSTAGE_REPO_URL=${BACKSTAGE_REPO_URL:-""}
#BACKSTAGE_DIR=${BACKSTAGE_DIR:-"backstage-app"}

# Update system
apt-get update -y
apt-get upgrade -y

# Install dependencies
apt-get install -y docker.io docker-compose git #curl ca-certificates

# Tooling needed for some Node native dependencies (e.g. isolated-vm)
#apt-get install -y build-essential python3 python3-setuptools python-is-python3 make g++ pkg-config libatomic1

# Install Node.js LTS (includes npm + corepack/yarn)
# Note: Backstage's current dependency tree pulls in isolated-vm@6.x which requires newer V8 APIs.
#curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
#apt-get install -y nodejs

#corepack enable
#corepack prepare yarn@stable --activate

# Enable Docker
systemctl enable docker
systemctl start docker

# Add azureuser to docker group
usermod -aG docker azureuser

# Move to home directory
cd /home/azureuser

# Clone Lighthouse Audit Service if not already cloned
if [ ! -d "lighthouse-audit-service" ]; then
  git clone "$LIGHTHOUSE_REPO_URL"
fi

# Clone Backstage if not already cloned
#if [ ! -d "$BACKSTAGE_DIR" ]; then
 # if [ -z "$BACKSTAGE_REPO_URL" ]; then
  #  echo "BACKSTAGE_REPO_URL is not set."
  #  echo "Set it to your Backstage repo URL, e.g.:"
  #  echo "  export BACKSTAGE_REPO_URL=https://github.com/<org>/<repo>.git"
  #  echo "Or create a Backstage app manually (npx @backstage/create-app) and copy it into /home/azureuser/$BACKSTAGE_DIR."
  #  exit 1
#  fi
#  git clone "$BACKSTAGE_REPO_URL" "$BACKSTAGE_DIR"
#fi

# Create docker-compose.yml
cat <<EOF > docker-compose.yml
version: '3.8'

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

  lighthouse:
    build: ./lighthouse-audit-service
    container_name: lighthouse
    ports:
      - "4008:3003"
    environment:
      PGHOST: postgres
      PGUSER: lighthouse
      PGPASSWORD: lighthouse
      PGDATABASE: lighthouse
      PORT: 3003
    depends_on:
      - postgres
    restart: unless-stopped

  backstage:
    build: ./${BACKSTAGE_DIR}
    container_name: backstage
    ports:
      - "3000:3000"
    depends_on:
      - lighthouse
    restart: unless-stopped

volumes:
  pgdata:
EOF

# Build and start containers
docker-compose up -d --build

echo "Installation complete." 