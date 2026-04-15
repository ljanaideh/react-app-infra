# react-app-infra

Terraform on AWS: **VPC + ECR + EC2 Spot** (`environments/dev`) and **VPC (2 AZ) + ECR + ECS Fargate + ALB** (`environments/dev-fargate`). Both environments use **Terragrunt** for remote state and CLI/Atlantis. GitOps with **Atlantis** + GitHub; **GitHub Actions** for Docker/ECR.

---

## Documentation (HTML)

| File | Purpose |
|------|---------|
| [flow-diagram.html](flow-diagram.html) | Architecture, GitOps flow, setup |
| [create-destroy.html](create-destroy.html) | S3 state, create/destroy, Atlantis Docker |
| [docs/architecture-flow.html](docs/architecture-flow.html) | Extra diagrams (optional) |

---

## Environments

| Path | Tool | Stack |
|------|------|--------|
| `environments/dev/` | **Terragrunt** | EC2 Spot, Docker from ECR, 2 public subnets (`vpc_ha`), ECR |
| `environments/dev-fargate/` | **Terragrunt** | 2 AZ public subnets, ECR, Fargate behind ALB |

**Terragrunt** root config: [terragrunt.hcl](terragrunt.hcl). State keys: `environments/dev/terraform.tfstate` and `environments/dev-fargate/terraform.tfstate` in the same S3 bucket (see `TF_STATE_BUCKET`).

| Docs | |
|------|---|
| Dev (EC2) | [docs/terragrunt-dev.md](docs/terragrunt-dev.md) |
| Fargate | [docs/terragrunt-dev-fargate.md](docs/terragrunt-dev-fargate.md) |
| Local Atlantis + ngrok | [docs/atlantis-local.md](docs/atlantis-local.md) |

Install [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/), then:

**dev (EC2 Spot)**

```bash
cd environments/dev
terragrunt init
terragrunt plan
terragrunt apply
```

Push **amd64** images to ECR repo **`react-app-dev`** (matches `app_name`):

```bash
ECR_REPOSITORY=react-app-dev ./scripts/docker-push-ecr.sh
```

**dev-fargate**

```bash
cd environments/dev-fargate
terragrunt init
terragrunt plan
terragrunt apply
```

Push **linux/arm64** to **`react-app-dev-fargate`**:

```bash
ECR_REPOSITORY=react-app-dev-fargate ./scripts/docker-push-ecr.sh
```

**Atlantis:** [atlantis.yaml](atlantis.yaml) runs **`terragrunt plan` / `terragrunt apply`** for both projects. Use **[docker/atlantis/Dockerfile](docker/atlantis/Dockerfile)** (Atlantis + Terragrunt) or another image that includes **Terragrunt**. Local run: [docs/atlantis-local.md](docs/atlantis-local.md), **[scripts/run-atlantis-local.sh](scripts/run-atlantis-local.sh)** (`--with-ngrok`, optional **`--update-github-webhook`**), secrets in **`scripts/.env.atlantis.local`** (copy from [scripts/.env.atlantis.example](scripts/.env.atlantis.example)).

---

## Scripts

| Script | Purpose |
|--------|---------|
| [scripts/verify-infra.sh](scripts/verify-infra.sh) | `terraform fmt -check`, `terraform validate` on modules, optional `terragrunt validate` per env |
| [scripts/run-atlantis-local.sh](scripts/run-atlantis-local.sh) | Build/run Atlantis + Terragrunt locally (see [docs/atlantis-local.md](docs/atlantis-local.md)) |
| `scripts/docker-local-test.sh` | Local amd64 build + http://localhost:8080 |
| `scripts/docker-push-ecr.sh` | Build + push to ECR (`ECR_REPOSITORY` override) |
| `scripts/replace-ec2-instance.sh` | Terraform replace EC2 (dev) |

---

## Prerequisites

- AWS CLI, credentials
- Terraform &ge; 1.6
- Docker (build/push)
- S3 bucket for remote state (see `create-destroy.html`)
- **Terragrunt** for `dev` and `dev-fargate`

---

## Git & ignores

`.terraform/`, `.terragrunt-cache/`, `*.tfstate`, `node_modules/`, and **`scripts/.env.atlantis.local`** are ignored. After the first successful `terragrunt init`, commit **`.terraform.lock.hcl`** from each environment directory if Terragrunt generates one there.
