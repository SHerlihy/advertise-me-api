terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  profile = "sherlihydtcom"
}

resource "aws_api_gateway_rest_api" "advertise" {
  name        = "advertise"
}

output "root" {
  value = {
    api_id = aws_api_gateway_rest_api.advertise.id
    root_id   = aws_api_gateway_rest_api.advertise.root_resource_id
    execution_arn   = aws_api_gateway_rest_api.advertise.execution_arn
  }
}
