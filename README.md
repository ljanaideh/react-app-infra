# react-app-infra

Terraform on AWS for a containerized React app: **VPC**, **ECR**, and **EC2 Spot** (Graviton). Optional **Atlantis** + **GitHub** for GitOps, **GitHub Actions** for image build and EC2 replace.

---

## Documentation (HTML)

Open these in your browser (double-click, or paste `file:///...` into the address bar). They share the same style and are meant to be read together:

| File | What it covers |
|------|----------------|
| [`flow-diagram.html`](flow-diagram.html) | Architecture, tools, GitOps / ngrok flow, setup steps, AWS resources, cost notes |
| [`create-destroy.html`](create-destroy.html) | **Create vs destroy**: S3 + `terraform.tfstate`, Atlantis Docker + ngrok, commands, teardown order |
| [`docs/architecture-flow.html`](docs/architecture-flow.html) | Extra architecture / flow (if you keep it in sync) |

The React app shell is `app/public/index.html`; the files above are **infra documentation**, not the running UI.

---

## Repository layout

```
react-app-infra/
├── app/                    # React source + Dockerfile
├── modules/vpc|ecr|ec2/   # Terraform modules
├── environments/dev/     # Dev stack
├── scripts/               # docker-local-test, docker-push-ecr, replace-ec2-instance
├── .github/workflows/
├── atlantis.yaml
├── flow-diagram.html
├── create-destroy.html
└── README.md
```

---

## Prerequisites

- AWS account, **AWS CLI** configured
- **Terraform** (see `environments/dev/provider.tf`)
- **Docker** (local test + ECR)
- **S3 bucket** for remote state — see `environments/dev/backend.tf` and **create-destroy.html**

---

## Quick commands

| Goal | Where to look |
|------|----------------|
| Local container test | `./scripts/docker-local-test.sh` → http://localhost:8080 |
| Push ARM image to ECR | `./scripts/docker-push-ecr.sh` |
| Replace EC2 (re-bootstrap) | `./scripts/replace-ec2-instance.sh` or workflow **Replace EC2 instance** |
| S3, Atlantis, full apply/destroy | **create-destroy.html** |

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

---

## Git & state

Remote state is in **S3** (`backend.tf`). **`.gitignore`** excludes `.terraform/`, local `*.tfstate`, `node_modules/`, and `*.tfvars`. **Do commit** `environments/dev/.terraform.lock.hcl` so everyone uses the same provider versions.

