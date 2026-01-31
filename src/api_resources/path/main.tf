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

module "authorizer" {
    source = "./authorizer"

    stage_uid = var.stage_uid
    
    api_id = var.api_bind.api_id
    execution_arn = var.execution_arn

    auth_key = var.auth_key
}

module "query" {
    source = "./query"

    stage_uid = var.stage_uid
    
    execution_arn = var.execution_arn

    kb_id = var.kb_id
}

module "sync" {
    source = "./sync"
    
    stage_uid = var.stage_uid

    execution_arn = var.execution_arn

    kb_id = var.kb_id
    source_id = var.source_id
}

output "authorizer_id" {
  value = module.authorizer.id
}

output "query_invoke_arn" {
  value = module.query.invoke_arn
}

output "sync_invoke_arn" {
  value = module.sync.invoke_arn
}
