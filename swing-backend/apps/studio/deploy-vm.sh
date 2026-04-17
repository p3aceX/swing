#!/bin/bash
# Deploy Studio service to GCP VM
# Usage: ./deploy-vm.sh

PROJECT_ID="project-0e62f040-2f77-4498-abd"
ZONE="asia-south1-b"
VM="swing-studio"
IMAGE="asia-south1-docker.pkg.dev/${PROJECT_ID}/swing/studio:latest"

echo "=== Deploying Swing Studio to VM ==="

gcloud compute ssh ${VM} --zone=${ZONE} --command="
    # Auth Docker to Artifact Registry
    sudo gcloud auth configure-docker asia-south1-docker.pkg.dev --quiet 2>/dev/null

    # Pull latest image
    echo 'Pulling latest image...'
    sudo docker pull ${IMAGE}

    # Stop existing container
    sudo docker stop swing-studio 2>/dev/null || true
    sudo docker rm swing-studio 2>/dev/null || true

    # Get external IP
    EXTERNAL_IP=\$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H 'Metadata-Flavor: Google')

    # Run new container
    echo 'Starting container...'
    sudo docker run -d \\
        --name swing-studio \\
        --restart unless-stopped \\
        -p 4000:4000 \\
        -e STUDIO_PORT=4000 \\
        -e WS_BASE_URL=ws://\${EXTERNAL_IP}:4000 \\
        -e ADMIN_BASE_URL=https://admin.swingcricketapp.com \\
        -e API_BASE_URL=https://swing-backend-1007730655118.asia-south1.run.app \\
        -e 'REDIS_URL=rediss://default:gQAAAAAAAS5VAAIncDJjZjU5M2M1MDYxODc0MzcyODliNTg3OWE1MmJiMjJiN3AyNzczOTc@true-cowbird-77397.upstash.io:6379' \\
        ${IMAGE}

    sleep 3
    echo '=== Container status ==='
    sudo docker ps --filter name=swing-studio
    echo '=== Logs ==='
    sudo docker logs swing-studio 2>&1 | tail -20
"

echo "=== Done ==="
echo "Studio API + WebSocket: http://34.47.234.51:4000"
echo ""
echo "NOTE: For WSS (required when camera page is served over HTTPS),"
echo "set up nginx/caddy TLS termination on the VM and update WS_BASE_URL"
echo "to wss://<your-studio-domain> in this script."
