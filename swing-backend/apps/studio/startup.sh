#!/bin/bash
set -e

echo "=== Swing Studio VM Startup ==="

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker
    systemctl start docker
fi

# Install docker-compose if not present
if ! command -v docker-compose &> /dev/null; then
    echo "Installing docker-compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Create app directory
mkdir -p /opt/swing-studio
cd /opt/swing-studio

# Clone or pull the repo
if [ -d ".git" ]; then
    git pull origin main
else
    git clone https://github.com/p3aceX/swing-backend.git .
fi

# Build and run the Studio service
cd apps/studio
docker build -t swing-studio .

# Stop existing container if running
docker stop swing-studio 2>/dev/null || true
docker rm swing-studio 2>/dev/null || true

# Run the container
docker run -d \
    --name swing-studio \
    --restart unless-stopped \
    -p 4000:4000 \
    -p 1935:1935 \
    -p 8888:8888 \
    -e PUBLIC_HOST="$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H 'Metadata-Flavor: Google')" \
    -e API_BASE_URL="https://swing-backend-nbid5gga4q-el.a.run.app" \
    -e REDIS_URL="rediss://default:gQAAAAAAAS5VAAIncDJjZjU5M2M1MDYxODc0MzcyODliNTg3OWE1MmJiMjJiN3AyNzczOTc@true-cowbird-77397.upstash.io:6379" \
    -e STUDIO_PORT=4000 \
    -e RTMP_PORT=1935 \
    -e RTMP_HTTP_PORT=8888 \
    swing-studio

echo "=== Studio service started ==="
docker logs swing-studio
