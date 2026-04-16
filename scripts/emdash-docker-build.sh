#!/usr/bin/env bash
# Build EmDash image using docker/emdash-demo/Dockerfile. Run from react-app-infra root.
# Usage:
#   ./scripts/emdash-docker-build.sh
#   EMDASH_SRC=~/Downloads/emdash-professionals-demo ./scripts/emdash-docker-build.sh
#   PLATFORM=linux/arm64 ./scripts/emdash-docker-build.sh   # Fargate-compatible
#
# Do NOT use a literal "/path/to/..." — set EMDASH_SRC to your real clone directory.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOCKERFILE="$ROOT/docker/emdash-demo/Dockerfile"
IMAGE_TAG="${IMAGE_TAG:-emdash-demo:local}"
PLATFORM="${PLATFORM:-}"

if [[ ! -f "$DOCKERFILE" ]]; then
  echo "Missing $DOCKERFILE" >&2
  exit 1
fi

resolve_src() {
  local raw="${1:-}"
  raw="${raw/#\~/$HOME}"
  if [[ -n "$raw" ]]; then
    if [[ ! -d "$raw" ]]; then
      echo "error: EMDASH_SRC is not a directory: $1" >&2
      echo "  Clone: git clone https://github.com/ljanaideh/emdash-professionals-demo.git" >&2
      echo "  Then:  EMDASH_SRC=\$HOME/Downloads/emdash-professionals-demo $ROOT/scripts/emdash-docker-build.sh" >&2
      exit 1
    fi
    echo "$(cd "$raw" && pwd)"
    return
  fi
  local default="$ROOT/../emdash-professionals-demo"
  if [[ -d "$default" && -f "$default/package.json" ]]; then
    echo "$(cd "$default" && pwd)"
    return
  fi
  echo "error: No EmDash clone found. Set EMDASH_SRC to the repo root (directory with package.json)." >&2
  echo "  Example: EMDASH_SRC=\$HOME/Downloads/emdash-professionals-demo $ROOT/scripts/emdash-docker-build.sh" >&2
  exit 1
}

EMDASH_SRC="$(resolve_src "${EMDASH_SRC:-}")"

echo "==> EmDash source: $EMDASH_SRC"

if [[ -n "$PLATFORM" ]]; then
  echo "==> buildx $IMAGE_TAG (platform=$PLATFORM)"
  docker buildx build --platform "$PLATFORM" -f "$DOCKERFILE" -t "$IMAGE_TAG" --load "$EMDASH_SRC"
else
  echo "==> docker build $IMAGE_TAG"
  docker build -f "$DOCKERFILE" -t "$IMAGE_TAG" "$EMDASH_SRC"
fi

echo "==> Done: $IMAGE_TAG"
echo "    Run: docker run --rm -p 4321:4321 $IMAGE_TAG"
