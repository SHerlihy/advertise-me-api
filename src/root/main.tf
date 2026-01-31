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

resource "aws_api_gateway_rest_api" "kbaas" {
  name        = "kbaas"
  
  binary_media_types = [
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "application/msword"
  ]
}

output "root" {
  value = {
    api_id = aws_api_gateway_rest_api.kbaas.id
    root_id   = aws_api_gateway_rest_api.kbaas.root_resource_id
    execution_arn   = aws_api_gateway_rest_api.kbaas.execution_arn
  }
}
