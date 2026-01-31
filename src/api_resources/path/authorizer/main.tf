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

variable "stage_uid" {
  type = string
}

variable "api_id" {
  type = string
}

variable "execution_arn" {
  type = string
}

variable "auth_key" {
  sensitive = true
  default = "allow"
  type = string
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.stage_uid}ServerlessLambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_log" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

}

data "archive_file" "authorizer" {
  type             = "zip"
  source_file      = "${path.module}/handler.py"
  output_path      = "${path.module}/handler.zip"
  output_file_mode = "0666"
}

resource "aws_lambda_function" "authorizer" {
  filename          = "${path.module}/handler.zip"
  code_sha256 = data.archive_file.authorizer.output_sha256
  function_name     = "${var.stage_uid}GatewayAuthorizer"
  role              = aws_iam_role.lambda_exec.arn
  handler           = "handler.handler"
  runtime           = "python3.14"
  
  source_code_hash = data.archive_file.authorizer.output_base64sha256

  environment {
    variables = {
      AUTH_KEY = var.auth_key
    }
  }
}

resource "aws_lambda_permission" "allow_api" {
  statement_id  = "${var.stage_uid}AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "${var.execution_arn}/*"
}

data "aws_iam_policy_document" "invocation_assume_role" {
  policy_id = "${var.stage_uid}InvocationAssumeRole"
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "invocation_role" {
  name               = "${var.stage_uid}GatewayAuthInvocation"
  assume_role_policy = data.aws_iam_policy_document.invocation_assume_role.json
}

data "aws_iam_policy_document" "invocation_policy" {
  policy_id = "${var.stage_uid}AuthInvocation"
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.authorizer.arn]
  }
}

resource "aws_iam_role_policy" "invocation_policy" {
  name   = "${var.stage_uid}ApiAuthorizer"
  role   = aws_iam_role.invocation_role.id
  policy = data.aws_iam_policy_document.invocation_policy.json
}

locals {
  auth_uri = "${aws_lambda_function.authorizer.invoke_arn}"
}

resource "aws_api_gateway_authorizer" "kbaas" {
  name                   = "${var.stage_uid}kbaas"
  rest_api_id            = var.api_id
  authorizer_uri         = local.auth_uri
  type = "REQUEST"
  identity_source                  = "method.request.querystring.authKey"
  authorizer_credentials = aws_iam_role.invocation_role.arn
  authorizer_result_ttl_in_seconds = 0
}

output "id" {
  value = aws_api_gateway_authorizer.kbaas.id
}
