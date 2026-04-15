# Terragrunt — dev-fargate (ECS Fargate + ALB)

## Install tools

- [Terraform](https://www.terraform.io/downloads) &gt;= 1.6
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)

## One-time: S3 state bucket

Same bucket as `dev` (`react-app-tfstate-laith` by default). Terragrunt writes state at:

`environments/dev-fargate/terraform.tfstate`

Source is **`modules//fargate_env`** so sibling modules (**`ecr`**, **`vpc_ha`**, **`fargate_app`**) load correctly under Terragrunt.

## Commands

```bash
cd environments/dev-fargate
terragrunt init
terragrunt plan
terragrunt apply
```

Outputs include **app_url** (ALB DNS).

## Container image

ECR repository name matches `app_name`: **react-app-dev-fargate**. Push **linux/arm64** (Fargate task is ARM):

```bash
export ECR_REPOSITORY=react-app-dev-fargate
./scripts/docker-push-ecr.sh
```

Then force new deployment if tag unchanged:

```bash
aws ecs update-service --cluster react-app-dev-fargate-cluster --service react-app-dev-fargate-svc --force-new-deployment --region us-east-1
```

## Destroy

```bash
cd environments/dev-fargate
terragrunt destroy
```

## Cost

ALB + Fargate is **more expensive** than the single EC2 `dev` stack.
