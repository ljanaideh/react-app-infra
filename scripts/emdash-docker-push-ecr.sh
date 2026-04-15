#!/usr/bin/env bash
# Build EmDash (docker/emdash-demo/Dockerfile) for linux/arm64 and push to ECR.
# Default ECR repo matches environments/dev-emdash (`app_name` = dev-emdash).
#
# Usage (from react-app-infra root):
#   EMDASH_SRC=~/Downloads/emdash-professionals-demo ./scripts/emdash-docker-push-ecr.sh
#
# Optional:
#   ECR_REPOSITORY=dev-emdash
#   AWS_REGION=us-east-1
#   IMAGE_TAG=latest

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCKERFILE="$REPO_ROOT/docker/emdash-demo/Dockerfile"

AWS_REGION="${AWS_REGION:-us-east-1}"
ECR_REPOSITORY="${ECR_REPOSITORY:-dev-emdash}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
PLATFORM="${PLATFORM:-linux/arm64}"

if ! command -v aws >/dev/null 2>&1; then
  echo "error: aws CLI not found" >&2
  exit 1
fi

resolve_src() {
  local raw="${EMDASH_SRC:-}"
  raw="${raw/#\~/$HOME}"
  if [[ -n "$raw" ]]; then
    if [[ ! -d "$raw" ]]; then
      echo "error: EMDASH_SRC is not a directory: ${EMDASH_SRC:-}" >&2
      exit 1
    fi
    echo "$(cd "$raw" && pwd)"
    return
  fi
  local default="$REPO_ROOT/../emdash-professionals-demo"
  if [[ -d "$default" && -f "$default/package.json" ]]; then
    echo "$(cd "$default" && pwd)"
    return
  fi
  echo "error: Set EMDASH_SRC to the emdash-professionals-demo clone root." >&2
  exit 1
}

EMDASH_SRC="$(resolve_src)"
ECR_URI="$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"

if [[ ! -f "$DOCKERFILE" ]]; then
  echo "error: missing $DOCKERFILE" >&2
  exit 1
fi

echo "==> EmDash source:    $EMDASH_SRC"
echo "==> Dockerfile:       $DOCKERFILE"
echo "==> Platform:         $PLATFORM"
echo "==> Push destination: ${ECR_URI}:${IMAGE_TAG}"

aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "$(echo "$ECR_URI" | cut -d/ -f1)"

docker buildx build \
  --platform "$PLATFORM" \
  -f "$DOCKERFILE" \
  -t "${ECR_URI}:${IMAGE_TAG}" \
  --push \
  "$EMDASH_SRC"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Pushed:  ${ECR_URI}:${IMAGE_TAG}"
echo "  Region:  ${AWS_REGION}"
echo "  Next:    aws ecs update-service --cluster dev-emdash-cluster --service dev-emdash-svc --force-new-deployment --region ${AWS_REGION}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
