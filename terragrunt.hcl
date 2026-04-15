# Remote state for all Terragrunt children (e.g. environments/dev, environments/dev-fargate).
# Bucket must exist; key is unique per env folder.

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = get_env("TF_STATE_BUCKET", "react-app-tfstate-laith")
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = get_env("AWS_DEFAULT_REGION", "us-east-1")
    encrypt        = true
    use_lockfile   = true
  }
}
