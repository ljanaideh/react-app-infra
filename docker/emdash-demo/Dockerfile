# EmDash "simple" demo — production SSR image.
# Build context MUST be the root of emdash-professionals-demo (clone of the app repo), e.g.:
#   cd /path/to/emdash-professionals-demo
#   docker build -f /path/to/react-app-infra/docker/emdash-demo/Dockerfile -t emdash-demo:local .
#
# Fargate (ARM64): docker buildx build --platform linux/arm64 ...

FROM node:20-bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    python3 \
    make \
    g++ \
  && rm -rf /var/lib/apt/lists/*

RUN corepack enable && corepack prepare pnpm@10.28.0 --activate

WORKDIR /app

COPY . .

RUN pnpm install --frozen-lockfile

RUN pnpm run build

RUN pnpm --filter emdash-demo build

WORKDIR /app/demos/simple

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=4321

EXPOSE 4321

CMD ["node", "./dist/server/entry.mjs"]
