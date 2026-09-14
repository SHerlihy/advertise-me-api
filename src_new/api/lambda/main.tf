terraform {
  required_version = ">= 1.0, <2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, <7.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

locals {
  http_method = "POST"
}

resource "aws_api_gateway_resource" "route" {
  rest_api_id = var.api_id
  parent_id   = var.root_resource_id
  path_part   = var.route_path
}

resource "aws_api_gateway_method" "route" {
  rest_api_id   = var.api_id
  resource_id   = aws_api_gateway_resource.route.id
  http_method   = local.http_method
  authorization = "NONE"
}

data "archive_file" "handler" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda" {
  name               = var.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

#prefer data way
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# could use fm var
data "aws_iam_policy_document" "query_knowledge_base" {
  policy_id = "${var.stage_uid}QueryKnowledgeBase"
  statement {
    effect = "Allow"
    actions = [
      "bedrock:Retrieve",
      "bedrock:RetrieveAndGenerate"
    ]
    resources = [
      "arn:aws:bedrock:us-east-1:${local.account_id}:knowledge-base/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
			"bedrock:InvokeModel",
      "bedrock:GetFoundationModel"
    ]
    resources = [
      "arn:aws:bedrock:us-east-1::foundation-model/amazon.nova-micro-v1:0"
    ]
  }
}

resource "aws_iam_policy" "query_knowledge_base" {
  policy = data.aws_iam_policy_document.query_knowledge_base.json
}

resource "aws_iam_role_policy_attachment" "query_knowledge_base" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.query_knowledge_base.arn
}

#needs to make dist
resource "null_resource" "build" {
  triggers = {
    src_hash = sha1(join("", [for f in fileset("${path.module}/function", "**") : filesha1("${path.module}/function/${f}")]))
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/create_dist.sh"
  }
}

data "archive_file" "query" {
  depends_on = [null_resource.build]
  type             = "zip"
  source_dir = "${path.module}/dist"
  output_path = "${path.module}/my_deployment_package.zip"
  output_file_mode = "0666"
}

resource "aws_lambda_function" "query" {
  function_name = "${var.stage_uid}-Query"
  filename = "${path.module}/my_deployment_package.zip"
  code_sha256 = data.archive_file.query.output_sha256
  role = aws_iam_role.lambda_exec.arn
  handler = "lambda_function.handler"
  runtime = "python3.12"
  architectures = ["x86_64"]
  timeout = 10
  memory_size      = 128

  environment {
    variables = {
      KB_ID = var.kb_id
    }
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromApiGateway-${var.route_path}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.query.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.execution_arn}/*/${local.http_method}/${var.route_path}"
}

resource "aws_api_gateway_integration" "route" {
  rest_api_id             = var.api_id
  resource_id             = aws_api_gateway_resource.route.id
  http_method             = aws_api_gateway_method.route.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.handler.invoke_arn
}

output "invoke_arn" {
  value = aws_lambda_function.query.invoke_arn
}
