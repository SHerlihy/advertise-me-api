terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  profile = "advertise"
}

variable "stage_uid" {
  type = string
}

variable "api_id" {
  type = string
}

resource "aws_api_gateway_deployment" "advertise" {
  rest_api_id = var.api_id 

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "advertise" {
  rest_api_id = var.api_id
  deployment_id = aws_api_gateway_deployment.advertise.id
  stage_name    = var.stage_uid
}

output "api_path" {
    value = aws_api_gateway_stage.advertise.invoke_url
}
