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

module "preflight" {
    source = "./preflight"

    api_bind = var.api_bind
}

module "query" {
    source = "./query"

    api_bind = var.api_bind

    invoke_arn = var.query_invoke_arn
}
