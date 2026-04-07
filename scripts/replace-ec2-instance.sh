#!/usr/bin/env bash
# Force-recreate the EC2 Spot instance via Terraform (new instance runs user_data,
# pulls :latest from ECR). Push a new image to ECR first, then run this.
#
# Usage: from repo root: ./scripts/replace-ec2-instance.sh
# Requires: terraform, AWS creds for state + apply (same as local terraform apply).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TF_DIR="$REPO_ROOT/environments/dev"
REPLACE_TARGET="module.ec2.aws_spot_instance_request.app"

cd "$TF_DIR"

echo "==> terraform init ($TF_DIR)"
terraform init -input=false

echo "==> terraform apply -replace=$REPLACE_TARGET"
echo "    (destroys current Spot request + instance, creates a new one)"
terraform apply -replace="$REPLACE_TARGET" -auto-approve

echo ""
echo "==> Outputs"
terraform output -no-color 2>/dev/null || true
echo ""
IP="$(terraform output -raw public_ip 2>/dev/null || true)"
if [[ -n "${IP:-}" && "$IP" != "null" ]]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  New instance public IP: $IP"
  echo "  App (after boot):       http://$IP"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi
