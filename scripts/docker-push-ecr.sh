#!/usr/bin/env bash
# Build (no cache) for linux/arm64 and push to ECR (Graviton / t4g EC2).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_DIR="$REPO_ROOT/app"

AWS_REGION="${AWS_REGION:-us-east-1}"
ECR_REPOSITORY="${ECR_REPOSITORY:-react-app-dev}"
PLATFORM="${PLATFORM:-linux/arm64}"

if ! command -v aws >/dev/null 2>&1; then
  echo "error: aws CLI not found" >&2
  exit 1
fi

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"

echo "==> ECR destination: ${ECR_URI}:latest"
echo "==> Building (no cache, platform=${PLATFORM}) and pushing"

aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

cd "$APP_DIR"

docker buildx build \
  --no-cache \
  --platform "$PLATFORM" \
  -t "${ECR_URI}:latest" \
  --push \
  .

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Pushed:  ${ECR_URI}:latest"
echo "  Region:  ${AWS_REGION}"
echo "  On EC2, user_data should pull this image (Graviton = arm64)."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
