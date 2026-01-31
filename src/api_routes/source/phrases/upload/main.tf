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

data "aws_region" "current" {}

locals {
  region = data.aws_region.current.region
}

resource "aws_api_gateway_method" "bucket_put" {
  rest_api_id   = var.api_bind.api_id
  resource_id   = var.api_bind.resource_id
  http_method   = "PUT"

  authorization = "CUSTOM"
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_integration" "bucket_put" {
  rest_api_id = var.api_bind.api_id
  resource_id   = var.api_bind.resource_id
  http_method = aws_api_gateway_method.bucket_put.http_method

  type        = "AWS"
  integration_http_method = "PUT"
  uri         = "arn:aws:apigateway:${local.region}:s3:path/${var.bucket.bucket_name}/phrases"
  credentials = var.bucket.bucket_access_role

  passthrough_behavior    = "WHEN_NO_TEMPLATES"
}

resource "aws_api_gateway_method_response" "bucket_put" {
  depends_on = [
    aws_api_gateway_method.bucket_put,
    aws_api_gateway_integration.bucket_put
  ]

  rest_api_id = var.api_bind.api_id
  resource_id   = var.api_bind.resource_id
  http_method = aws_api_gateway_method.bucket_put.http_method
  status_code = "200"

  response_models = {
    "application/xml" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "bucket_put" {
  depends_on = [
    aws_api_gateway_method.bucket_put,
    aws_api_gateway_integration.bucket_put
  ]

  rest_api_id = var.api_bind.api_id
  resource_id   = var.api_bind.resource_id
  http_method = aws_api_gateway_method.bucket_put.http_method
  status_code = aws_api_gateway_method_response.bucket_put.status_code

  selection_pattern = ""

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}
