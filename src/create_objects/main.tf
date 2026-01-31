terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

variable "api_id" {
  type = string
}

variable "root_id" {
  type = string
}

locals {
  api_bind = {
    api_id = var.api_id
    resource_id = var.root_id
  }
}

output "api_bind" {
    value = local.api_bind
}
