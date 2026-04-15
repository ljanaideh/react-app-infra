#!/usr/bin/env bash
# Build (no cache) and run the React/nginx image locally for amd64 laptops.
# Prints the URL to open when the container is up.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_DIR="$REPO_ROOT/app"

IMAGE_NAME="${IMAGE_NAME:-react-app-dev-local}"
CONTAINER_NAME="${CONTAINER_NAME:-react-app-local-test}"
PORT="${PORT:-8080}"
PLATFORM="${PLATFORM:-linux/amd64}"

cd "$APP_DIR"

echo "==> Building image (no cache, platform=${PLATFORM})"
docker buildx build \
  --no-cache \
  --platform "$PLATFORM" \
  -t "$IMAGE_NAME" \
  --load \
  .

if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  echo "==> Removing existing container: $CONTAINER_NAME"
  docker rm -f "$CONTAINER_NAME" >/dev/null
fi

echo "==> Starting container on port ${PORT}"
docker run -d --rm \
  --name "$CONTAINER_NAME" \
  -p "${PORT}:80" \
  "$IMAGE_NAME"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Local app URL:  http://localhost:${PORT}"
echo "  Container:      ${CONTAINER_NAME}"
echo "  Stop:           docker stop ${CONTAINER_NAME}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
