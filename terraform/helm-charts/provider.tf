terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.1.0"
    }

  }
  required_version = ">= 1.4.6"
}

provider "aws" {
  region = data.terraform_remote_state.infra.outputs.aws_region
}
