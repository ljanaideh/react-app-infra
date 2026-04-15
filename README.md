# react-app-infra

Terraform on AWS: **VPC**, **ECR**, **EC2 Spot** (`environments/dev`), **ECS Fargate + ALB** for the React app (`environments/dev-fargate`), and a separate **EmDash** Fargate stack (`environments/dev-emdash`). All use **Terragrunt** for remote state and **Atlantis** for GitOps; **GitHub Actions** can build and push images.

---

## Documentation (HTML)

| File | Purpose |
|------|---------|
| [flow-diagram.html](flow-diagram.html) | Architecture, GitOps flow, setup |
| [create-destroy.html](create-destroy.html) | S3 state, create/destroy, Atlantis Docker |
| [docs/architecture-flow.html](docs/architecture-flow.html) | Extra diagrams (optional) |

Open these in a browser (or `file:///...`). The React app shell is under `app/`; the HTML files are **infra documentation**, not the running UI.

---

## Environments

| Path | Tool | Stack |
|------|------|--------|
| `environments/dev/` | **Terragrunt** | EC2 Spot, Docker from ECR, `vpc_ha`, ECR |
| `environments/dev-fargate/` | **Terragrunt** | 2 AZ, ECR, Fargate behind ALB (React, port 80) |
| `environments/dev-emdash/` | **Terragrunt** | Same pattern, **EmDash** SSR (port **4321**), own VPC + ECR |

**Terragrunt** root: [terragrunt.hcl](terragrunt.hcl). State keys: `environments/dev/terraform.tfstate`, `environments/dev-fargate/terraform.tfstate`, `environments/dev-emdash/terraform.tfstate` (see `TF_STATE_BUCKET`).

| Docs | |
|------|---|
| Dev (EC2) | [docs/terragrunt-dev.md](docs/terragrunt-dev.md) |
| Fargate (React) | [docs/terragrunt-dev-fargate.md](docs/terragrunt-dev-fargate.md) |
| Fargate (EmDash) | [docs/terragrunt-dev-emdash.md](docs/terragrunt-dev-emdash.md) |
| EmDash local (phase 1) | [docs/emdash-local-phase1.md](docs/emdash-local-phase1.md) |
| EmDash Docker (phase 2) | [docker/emdash-demo/README.md](docker/emdash-demo/README.md) |
| Local Atlantis | [docs/atlantis-local.md](docs/atlantis-local.md) |

Install [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/), then:

**dev (EC2)**

```bash
cd environments/dev
terragrunt init
terragrunt plan
terragrunt apply
```

Push **amd64** images to ECR repo **`react-app-dev`** (matches `app_name`):

```bash
DEPLOY=ec2 ./scripts/docker-push-ecr.sh
```

**dev-fargate**

```bash
cd environments/dev-fargate
terragrunt init
terragrunt plan
terragrunt apply
```

Push **linux/arm64** to **`react-app-dev-fargate`** (default):

```bash
./scripts/docker-push-ecr.sh
# same as: DEPLOY=fargate ./scripts/docker-push-ecr.sh
```

**dev-emdash** (EmDash image — build context is the **emdash-professionals-demo** clone)

```bash
cd environments/dev-emdash
terragrunt init
terragrunt plan
terragrunt apply
```

Push **linux/arm64** to ECR repo **`dev-emdash`** (matches `app_name`):

```bash
EMDASH_SRC=~/Downloads/emdash-professionals-demo ./scripts/emdash-docker-push-ecr.sh
```

**Atlantis:** [atlantis.yaml](atlantis.yaml) defines projects **`dev`**, **`dev-fargate`**, and **`dev-emdash`**; **Terragrunt** runs via **server-side** [docker/atlantis/repos.yaml](docker/atlantis/repos.yaml) (`workflows.default`). On PRs: e.g. **`atlantis plan -p dev-emdash`** / **`atlantis apply -p dev-emdash`**. Hosted Atlantis **must** load that repo config (`--repo-config`) and have **`terragrunt` installed** — otherwise checks run **`terraform plan`** in env dirs that only contain `terragrunt.hcl` and plans fail (see [docs/atlantis-local.md](docs/atlantis-local.md)). Local Docker: [scripts/run-atlantis-local.sh](scripts/run-atlantis-local.sh).

---

## Repository layout

```
react-app-infra/
├── app/                      # React source + Dockerfile (if present)
├── modules/                  # vpc_ha, ecr, dev_env, fargate_*, …
├── environments/dev/         # Terragrunt
├── environments/dev-fargate/
├── environments/dev-emdash/
├── scripts/
├── docker/atlantis/          # Dockerfile + server repos.yaml
├── docker/emdash-demo/       # EmDash app image (build context = emdash-professionals-demo clone)
├── atlantis.yaml
├── flow-diagram.html
├── create-destroy.html
└── README.md
```

---

## Scripts

| Script | Purpose |
|--------|---------|
| [scripts/verify-infra.sh](scripts/verify-infra.sh) | `terraform fmt -check`, `validate` modules, optional `terragrunt validate` |
| [scripts/run-atlantis-local.sh](scripts/run-atlantis-local.sh) | Local Atlantis + Terragrunt ([docs/atlantis-local.md](docs/atlantis-local.md)) |
| `scripts/docker-local-test.sh` | Local amd64 build + http://localhost:8080 |
| `scripts/docker-push-ecr.sh` | Build + push to ECR (`DEPLOY=ec2` \| `fargate`, or `ECR_REPOSITORY`) |
| [scripts/emdash-docker-build.sh](scripts/emdash-docker-build.sh) | Build EmDash image locally ([docker/emdash-demo](docker/emdash-demo)) |
| [scripts/emdash-docker-push-ecr.sh](scripts/emdash-docker-push-ecr.sh) | Build EmDash **linux/arm64** and push to ECR (`dev-emdash`) |
| `scripts/replace-ec2-instance.sh` | Replace EC2 (dev) |

---

## Prerequisites

- AWS CLI, credentials
- Terraform ≥ 1.6
- Docker (build/push)
- S3 bucket for remote state (see **create-destroy.html**)
- **Terragrunt** for `dev`, `dev-fargate`, and `dev-emdash`

---

## Git & ignores

`.terraform/`, `.terragrunt-cache/`, `*.tfstate`, `node_modules/`, `scripts/.env.atlantis.local`, and common Terraform/React ignores per [.gitignore](.gitignore). Commit **`.terraform.lock.hcl`** under environments and modules where generated.
