terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
  }

  backend "s3" {
    bucket = ""
    key    = "advertise_me_api/terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  profile = "sherlihydtcom"
  region  = "us-east-1"
}

locals {
  kb_id = "J1HDISM9SM"
  api_name = "advertise-me"
  route_path = "query"
  path_to_settings = {
    "*/*" : {
      burst_limit = 999
      rate_limit  = 99
    }
  }

  quota = {
    limit : 9999
    period : "DAY"
  }
  throttle = {
    burst : 999
    rate : 99
  }
}

module "draft_api" {
  source  = "SHerlihy/draft-cors-api/aws"
  version = "0.0.2"

  api_name = local.api_name
  tags     = {}
}

module "lambda" {
  source = "./lambda"

  api_id           = module.draft_api.api_id
  root_resource_id = module.draft_api.root_resource_id
  execution_arn    = module.draft_api.execution_arn
  route_path = local.route_path
  kb_id = local.kb_id
}

module "deploy_api" {
  source  = "SHerlihy/deploy-api-public-quota/aws"
  version = "0.0.4"

  api_id     = module.draft_api.api_id
  stage_name = "prod"
  quota      = local.quota
  throttle   = local.throttle

  path_to_settings = local.path_to_settings

  tags = {}
}

output "access_logs_api_url" {
  value = module.deploy_api.endpoint
}

output "access_logs_api_key" {
  value = module.deploy_api.api_key
}
