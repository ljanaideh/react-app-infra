#!/usr/bin/env bash
# Quick checks: terraform fmt + validate modules (no AWS plan).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== terraform fmt (check) =="
terraform fmt -check -recursive modules environments || {
  echo "Run: terraform fmt -recursive modules environments" >&2
  exit 1
}

echo "== terraform validate: modules/dev_env =="
(cd "$ROOT/modules/dev_env" && terraform init -backend=false -input=false >/dev/null && terraform validate)

echo "== terraform validate: modules/fargate_env =="
(cd "$ROOT/modules/fargate_env" && terraform init -backend=false -input=false >/dev/null && terraform validate)

if command -v terragrunt >/dev/null 2>&1; then
  echo "== terragrunt validate: environments/dev =="
  (cd "$ROOT/environments/dev" && terragrunt validate --terragrunt-non-interactive)
  echo "== terragrunt validate: environments/dev-fargate =="
  (cd "$ROOT/environments/dev-fargate" && terragrunt validate --terragrunt-non-interactive)
else
  echo "== terragrunt not in PATH; skip env validate (install Terragrunt or use CI) =="
fi

echo "OK — all checks passed."
