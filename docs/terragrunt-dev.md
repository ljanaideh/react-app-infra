# Terragrunt — dev (EC2 Spot + ECR)

## Install

- [Terraform](https://www.terraform.io/downloads) &gt;= 1.6
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)

## Remote state

Same S3 bucket as Fargate (default `react-app-tfstate-laith` via `TF_STATE_BUCKET`). State path:

`environments/dev/terraform.tfstate`

Terragrunt uses **`modules//dev_env`** (see `environments/dev/terragrunt.hcl`) so the whole **`modules/`** tree is the Terraform package; sibling modules like **`ecr`** and **`vpc_ha`** resolve correctly.

## Commands

```bash
cd environments/dev
terragrunt init
terragrunt plan
terragrunt apply
```

Outputs include **app_url** (HTTP on the instance public DNS). The EC2 user data installs Docker, pulls `${ecr_repository_url}:${image_tag}`, and runs the container on port **80**.

Push an image first (repo name matches `app_name`, e.g. **react-app-dev**):

```bash
DEPLOY=ec2 ./scripts/docker-push-ecr.sh
```

The instance retries `docker pull` until the image exists.

## Destroy

```bash
cd environments/dev
terragrunt destroy
```

## Cost

EC2 Spot + NAT-less public subnet is typically **cheaper** than ALB + Fargate (`dev-fargate`).
