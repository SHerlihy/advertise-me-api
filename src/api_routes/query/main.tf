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

variable "invoke_arn" {
  type = string
}

module "endpoint" {
  source = "./endpoint"

  api_bind = var.api_bind

  invoke_arn = var.invoke_arn
}
