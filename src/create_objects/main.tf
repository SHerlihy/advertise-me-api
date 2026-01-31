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

variable "bucket_name" {
  type = string
}

variable "gateway_access_bucket_role" {
  type = string
}

locals {
  api_bind = {
    api_id = var.api_id
    resource_id = var.root_id
  }

  bucket = {
    bucket_name = var.bucket_name
    bucket_access_role = var.gateway_access_bucket_role
  }
}

output "api_bind" {
    value = local.api_bind
}

output "bucket" {
  value = local.bucket
}


