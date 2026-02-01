terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

module "query" {
    source = "./query"

    stage_uid = var.stage_uid
    
    execution_arn = var.execution_arn

    kb_id = var.kb_id
}

output "query_invoke_arn" {
  value = module.query.invoke_arn
}
