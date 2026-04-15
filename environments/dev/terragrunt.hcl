include "root" {
  path = find_in_parent_folders()
}

terraform {
  # Use modules//dev_env so Terraform's root package is modules/ (sibling modules ecr, vpc_ha resolve).
  source = "${dirname(find_in_parent_folders())}/modules//dev_env"
}

inputs = {
  app_name      = "react-app-dev"
  aws_region    = "us-east-1"
  image_tag     = "latest"
  instance_type = "t3.small"
}
