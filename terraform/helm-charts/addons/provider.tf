terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.1.0"
    }

    helm = {
      source = "hashicorp/helm"
      version = "2.10.1"
    }
  }
  backend "s3" {}
  required_version = ">= 1.4.6"
}

provider "aws" {
  region = data.terraform_remote_state.infra.outputs.aws_region
}

provider "helm" {
   kubernetes {
    host = data.terraform_remote_state.infra.outputs.cluster_endpoint 
    config_path = "~/.kube/config"
  }
}
