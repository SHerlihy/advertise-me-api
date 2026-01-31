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

variable "authorizer_id" {
  type = string
}

variable "invoke_arn" {
  type = string
}

module "endpoint" {
  source = "./endpoint"

  api_bind = var.api_bind

  authorizer_id = var.authorizer_id

  invoke_arn = var.invoke_arn
}
