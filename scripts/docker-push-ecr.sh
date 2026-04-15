#!/usr/bin/env bash
# Build the app image and push to ECR. Repo name must match Terragrunt `app_name` (ECR module).
#
# Usage:
#   DEPLOY=fargate ./scripts/docker-push-ecr.sh   # default — environments/dev-fargate, linux/arm64
#   DEPLOY=ec2 ./scripts/docker-push-ecr.sh      # environments/dev (t3.small amd64), linux/amd64
# Optional overrides: ECR_REPOSITORY=... PLATFORM=linux/arm64 AWS_REGION=us-east-1

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_DIR="$REPO_ROOT/app"

AWS_REGION="${AWS_REGION:-us-east-1}"
DEPLOY="${DEPLOY:-fargate}"

case "$DEPLOY" in
  fargate)
    : "${ECR_REPOSITORY:=react-app-dev-fargate}"
    : "${PLATFORM:=linux/arm64}"
    ;;
  ec2)
    : "${ECR_REPOSITORY:=react-app-dev}"
    : "${PLATFORM:=linux/amd64}"
    ;;
  *)
    echo "error: DEPLOY must be 'fargate' or 'ec2' (got: ${DEPLOY})" >&2
    exit 1
    ;;
esac

if ! command -v aws >/dev/null 2>&1; then
  echo "error: aws CLI not found" >&2
  exit 1
fi

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"

echo "==> DEPLOY=${DEPLOY}  ECR_REPOSITORY=${ECR_REPOSITORY}  PLATFORM=${PLATFORM}"
echo "==> Destination: ${ECR_URI}:latest"
echo "==> Building (no cache) and pushing"

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
echo "  Next:    ECS — update service / force new deployment if tasks still fail to pull."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
