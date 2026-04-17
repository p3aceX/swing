FROM node:20-bookworm-slim AS base
WORKDIR /app

FROM base AS deps
COPY package.json package-lock.json ./
# Copy workspace package.json files
COPY apps/api/package.json apps/api/package.json
COPY apps/studio/package.json apps/studio/package.json
# Copy all internal packages to ensure local dependencies are available for npm ci
COPY packages/ packages/
RUN npm install && npm cache clean --force

FROM deps AS build
COPY . .
RUN npm run db:generate
RUN npx turbo build --filter='!@swing/studio'

FROM node:20-bookworm-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN apt-get update -y && apt-get install -y openssl ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/package-lock.json ./package-lock.json
COPY --from=build /app/node_modules ./node_modules
# Copy built apps and packages (including dist folders)
COPY --from=build /app/apps ./apps
COPY --from=build /app/packages ./packages
COPY --from=build /app/docker-entrypoint.sh ./docker-entrypoint.sh

RUN chmod +x ./docker-entrypoint.sh

EXPOSE 3000

CMD ["./docker-entrypoint.sh"]
