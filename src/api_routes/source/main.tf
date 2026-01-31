terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  profile = "kbaas"
}

module "source" {
  source = "./list"

  api_bind = var.api_bind
    authorizer_id = var.authorizer_id

  bucket = var.bucket
}

module "phrases" {
  source = "./phrases"

  api_bind = var.api_bind
    authorizer_id = var.authorizer_id

  bucket = var.bucket
}
