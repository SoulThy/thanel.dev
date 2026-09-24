terraform {
  required_version = "~> 1.16"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.66.0"
    }
  }

  # edit backend.hcl for the backend s3
  # and run terraform init -backend-config=backend.hcl
  backend "s3" {}
}
