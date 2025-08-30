terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # HCP Terraform setting
  /*
  cloud {
    organization = "tmaeda-hashicorp"
    hostname     = "app.terraform.io"

    workspaces {
      name = "aws-verification-github"
    }
  }
  */
}

provider "aws" {
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
  region = "ap-northeast-1"
}
module "vpc" {
  source = "./resource/vpc"
}


module "eks" {
  source     = "./resource/eks"
  subnet_ids = module.vpc.subnet_ids
}