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

variable "stage_uid" {
  type = string
}

variable "execution_arn" {
    type = string
}

variable "kb_id" {
  type = string
}

module "handler" {
  source = "./handler"

  stage_uid = var.stage_uid

  kb_id = var.kb_id
  execution_arn = var.execution_arn
}

output "invoke_arn" {
  value = module.handler.invoke_arn
}
