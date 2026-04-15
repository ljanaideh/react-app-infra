include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${dirname(find_in_parent_folders())}/modules//fargate_env"
}

inputs = {
  app_name        = "react-app-dev-fargate"
  aws_region      = "us-east-1"
  image_tag       = "latest"
  desired_count   = 2
}
