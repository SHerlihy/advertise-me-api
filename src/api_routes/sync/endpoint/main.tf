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

resource "aws_api_gateway_resource" "sync" {
  rest_api_id = var.api_bind.api_id
  parent_id   = var.api_bind.resource_id
  path_part   = "sync"
}

resource "aws_api_gateway_method" "sync" {
  rest_api_id   = var.api_bind.api_id
  resource_id   = aws_api_gateway_resource.sync.id
  http_method   = "PATCH"

  authorization = "CUSTOM"
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_integration" "sync" {
  rest_api_id   = var.api_bind.api_id
  resource_id   = aws_api_gateway_resource.sync.id

  http_method          = aws_api_gateway_method.sync.http_method
  integration_http_method = "POST"
  type                 = "AWS_PROXY"

  uri = var.invoke_arn
}

resource "aws_api_gateway_method_response" "sync" {
  depends_on = [
aws_api_gateway_resource.sync,
aws_api_gateway_method.sync
  ]

  rest_api_id   = var.api_bind.api_id
  resource_id   = aws_api_gateway_resource.sync.id

  http_method = aws_api_gateway_method.sync.http_method
  status_code = 200
}
