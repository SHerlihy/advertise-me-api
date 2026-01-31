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

resource "aws_api_gateway_resource" "source_list" {
  rest_api_id   = var.api_bind.api_id
  parent_id   = var.api_bind.resource_id
  path_part   = "list"
}

locals {
  resource_id = aws_api_gateway_resource.source_list.id
}

resource "aws_api_gateway_method" "source_list" {
  rest_api_id   = var.api_bind.api_id
  resource_id   = local.resource_id
  http_method   = "GET"

  authorization = "CUSTOM"
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_integration" "source_list" {
  rest_api_id = var.api_bind.api_id
  resource_id   = local.resource_id
  http_method = aws_api_gateway_method.source_list.http_method

  type        = "AWS"
  integration_http_method = "GET"
  uri         = "arn:aws:apigateway:${local.region}:s3:path/${var.bucket.bucket_name}"
  credentials = var.bucket.bucket_access_role
}

#response not in guide
#https://registry.terraform.io/providers/hashicorp/aws/2.33.0/docs/guides/serverless-with-aws-lambda-and-api-gateway
##cors stuff is v2
##https://docs.aws.amazon.com/lambda/latest/dg/services-apigateway.html
resource "aws_api_gateway_method_response" "source_list" {
  depends_on = [
    aws_api_gateway_method.source_list,
    aws_api_gateway_integration.source_list
  ]

  rest_api_id = var.api_bind.api_id
  resource_id   = local.resource_id
  http_method = aws_api_gateway_method.source_list.http_method
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

resource "aws_api_gateway_integration_response" "source_list" {
  depends_on = [
    aws_api_gateway_method.source_list,
    aws_api_gateway_integration.source_list
  ]

  rest_api_id = var.api_bind.api_id
  resource_id   = local.resource_id
  http_method = aws_api_gateway_method.source_list.http_method
  status_code = aws_api_gateway_method_response.source_list.status_code

  selection_pattern = ""

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}
