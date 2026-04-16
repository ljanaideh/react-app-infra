# Remote state for all Terragrunt children (e.g. environments/dev, dev-fargate, dev-emdash).
# Bucket must exist; key is unique per env folder.

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket  = get_env("TF_STATE_BUCKET", "react-app-tfstate-laith")
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = get_env("AWS_DEFAULT_REGION", "us-east-1")
    encrypt = true
    # S3-native locking (no DynamoDB) — requires Terraform >= 1.10. Uncomment when
    # ATLANTIS_DEFAULT_TF_VERSION (or local Terraform) is 1.10+:
    # use_lockfile = true
  }
}
