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
    bucket = "state-bucket-5c8c1de056e072d9bc764e0c2b"
    key    = "advertise_me_api/terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  profile = "sherlihydtcom"
}

locals {
  stage_name  = "prod"
  kb_id       = "J1HDISM9SM"
  api_name    = "advertise-me"
  route_path  = "query"
  http_method = "POST"
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
  version = "0.0.3"

  api_name = local.api_name
  tags     = {}
}

module "lambda" {
  source = "./lambda"

  api_id           = module.draft_api.api_id
  root_resource_id = module.draft_api.root_resource_id
  execution_arn    = module.draft_api.execution_arn
  route_path       = local.route_path
  http_method      = local.http_method
  kb_id            = local.kb_id
}

module "deploy_api" {
  depends_on = [module.lambda]
  source  = "SHerlihy/deploy-api-public-quota/aws"
  version = "0.0.4"

  api_id     = module.draft_api.api_id
  stage_name = local.stage_name
  quota      = local.quota
  throttle   = local.throttle

  path_to_settings = local.path_to_settings

  tags = {}
}

output "endpoint_obj" {
  value = {
    endpoint : "${module.deploy_api.endpoint}/${local.route_path}",
    method : local.http_method,
    api_key : module.deploy_api.api_key
  }
}
