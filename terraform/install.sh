#!/bin/bash
set -e

echo "Starting VM bootstrap..."

# Update system
apt-get update -y
apt-get upgrade -y

# Install dependencies
apt-get install -y docker.io docker-compose git

# Enable Docker
systemctl enable docker
systemctl start docker

# Add azureuser to docker group
usermod -aG docker azureuser

# Move to home directory
cd /home/azureuser

# Clone Lighthouse Audit Service if not already cloned
if [ ! -d "lighthouse-audit-service" ]; then
  git clone https://github.com/spotify/lighthouse-audit-service.git
fi

# Clone Backstage if not already cloned
if [ ! -d "backstage-app" ]; then
  git clone https://github.com/YOUR_USERNAME/backstage-app.git
fi

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
    build: ./backstage-app
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