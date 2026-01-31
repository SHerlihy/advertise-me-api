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

resource "aws_api_gateway_resource" "phrases" {
  rest_api_id   = var.api_bind.api_id
  parent_id   = var.api_bind.resource_id
  path_part   = "phrases"
}

locals {
  resource_id = aws_api_gateway_resource.phrases.id
}

module "upload" {
  source = "./upload"

  bucket = var.bucket

  api_bind = {
    api_id = var.api_bind.api_id
    resource_id = local.resource_id
  }

  authorizer_id = var.authorizer_id
}
