# Terragrunt — dev-emdash (EmDash on ECS Fargate + ALB)

Separate stack from **`dev-fargate`** (React): own **VPC**, **ECR**, **ALB**, and **ECS** service. The container listens on **4321** (EmDash SSR); Terraform sets **`container_port = 4321`**.

## Install tools

- [Terraform](https://www.terraform.io/downloads) &gt;= 1.6
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)

## One-time: S3 state bucket

Same bucket as other envs (`react-app-tfstate-laith` by default). State file:

`environments/dev-emdash/terraform.tfstate`

## Commands

```bash
cd environments/dev-emdash
terragrunt init
terragrunt plan
terragrunt apply
```

Outputs include **app_url** (ALB DNS, HTTP port 80 → tasks on 4321).

## Container image

ECR repository name matches **`app_name`**: **dev-emdash**. Build context is the **emdash-professionals-demo** clone; Dockerfile lives in this repo under **`docker/emdash-demo/`**.

Push **linux/arm64** (Fargate task definition uses ARM64):

```bash
EMDASH_SRC=~/Downloads/emdash-professionals-demo ./scripts/emdash-docker-push-ecr.sh
```

Then force a new deployment if the tag is unchanged:

```bash
aws ecs update-service \
  --cluster dev-emdash-cluster \
  --service dev-emdash-svc \
  --force-new-deployment \
  --region us-east-1
```

## Logs

CloudWatch log group: **`/ecs/dev-emdash`** (ECS task `awslogs` configuration).

## Atlantis (GitOps)

This repo’s [atlantis.yaml](../atlantis.yaml) includes project **`dev-emdash`**. After the server loads [docker/atlantis/repos.yaml](../docker/atlantis/repos.yaml), comment on a PR:

- **`atlantis plan -p dev-emdash`**
- **`atlantis apply -p dev-emdash`**

Local server: [scripts/run-atlantis-local.sh](../scripts/run-atlantis-local.sh) — see [atlantis-local.md](atlantis-local.md).

## Destroy

```bash
cd environments/dev-emdash
terragrunt destroy
```

## Cost

Same class as **`dev-fargate`**: ALB + Fargate + NAT-less public subnets (see **`vpc_ha`**).
