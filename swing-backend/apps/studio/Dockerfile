# Swing Studio Service
# Runs RTMP server + FFmpeg compositor + overlay capture
# Deploy on a VM (not serverless) — needs persistent processes

FROM node:20-slim

# Install FFmpeg and Chromium dependencies for Puppeteer
RUN apt-get update && apt-get install -y \
    ffmpeg \
    chromium \
    fonts-liberation \
    libnss3 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxkbcommon0 \
    libgbm1 \
    libasound2 \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Tell Puppeteer to use installed Chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

WORKDIR /app

# Copy package files and install ALL deps (including devDeps for tsc)
COPY package.json ./
RUN npm install

# Copy source and build
COPY tsconfig.json ./
COPY src/ ./src/
RUN npx tsc -p tsconfig.json

# Remove devDependencies after build
RUN npm prune --omit=dev

# Create temp directories
RUN mkdir -p /tmp/studio-overlays /tmp/studio-media

# Expose port — API and WebSocket share the same port
EXPOSE 4000

CMD ["node", "dist/index.js"]
