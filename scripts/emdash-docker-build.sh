#!/usr/bin/env bash
# Build EmDash image using docker/emdash-demo/Dockerfile. Run from react-app-infra root.
# Usage:
#   EMDASH_SRC=../emdash-professionals-demo ./scripts/emdash-docker-build.sh
#   PLATFORM=linux/arm64 ./scripts/emdash-docker-build.sh   # Fargate-compatible

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOCKERFILE="$ROOT/docker/emdash-demo/Dockerfile"
IMAGE_TAG="${IMAGE_TAG:-emdash-demo:local}"
PLATFORM="${PLATFORM:-}"

if [[ ! -f "$DOCKERFILE" ]]; then
  echo "Missing $DOCKERFILE" >&2
  exit 1
fi

if [[ -n "${EMDASH_SRC:-}" ]]; then
  EMDASH_SRC="$(cd "$EMDASH_SRC" && pwd)"
else
  EMDASH_SRC="$(cd "$ROOT/../emdash-professionals-demo" 2>/dev/null && pwd)" || EMDASH_SRC=""
fi

if [[ ! -d "${EMDASH_SRC}" ]] || [[ ! -f "${EMDASH_SRC}/package.json" ]]; then
  echo "Set EMDASH_SRC to your emdash-professionals-demo clone root (needs package.json)." >&2
  echo "Example: EMDASH_SRC=~/src/emdash-professionals-demo $0" >&2
  exit 1
fi

if [[ -n "$PLATFORM" ]]; then
  echo "==> buildx $IMAGE_TAG (platform=$PLATFORM)"
  docker buildx build --platform "$PLATFORM" -f "$DOCKERFILE" -t "$IMAGE_TAG" --load "$EMDASH_SRC"
else
  echo "==> docker build $IMAGE_TAG"
  docker build -f "$DOCKERFILE" -t "$IMAGE_TAG" "$EMDASH_SRC"
fi

echo "==> Done: $IMAGE_TAG"
