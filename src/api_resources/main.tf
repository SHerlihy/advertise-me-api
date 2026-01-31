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

module "api_role" {
  source = "./api_role"

  stage_uid = var.stage_uid

  bucket_access_policy = var.bucket_access_policy
}

module "paths" {
  source = "./path"

  stage_uid = var.stage_uid

  execution_arn = var.execution_arn

  kb_id = var.kb_id
}

output "gateway_access_bucket_role" {
  value = module.api_role.gateway_role_arn
}

output "query_invoke_arn" {
  value = module.paths.query_invoke_arn
}
