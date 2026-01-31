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

variable "execution_arn" {
  type = string
}

variable "kb_id" {
  type = string
}

variable "source_id" {
  type = string
}

data "archive_file" "sync" {
  type             = "zip"
  source_dir = "${path.module}/dist"
  output_path = "${path.module}/my_deployment_package.zip"
  output_file_mode = "0666"
}

resource "aws_lambda_function" "sync" {
  filename = "${path.module}/my_deployment_package.zip"
  code_sha256 = data.archive_file.sync.output_sha256

  function_name = "${var.stage_uid}Sync"
  handler = "lambda_function.handler"

  runtime = "python3.14"
  architectures = ["x86_64"]

  role = aws_iam_role.lambda_exec.arn
  timeout = 60

  environment {
    variables = {
      KB_ID = var.kb_id
      SOURCE_ID = var.source_id
    }
  }
}

resource "aws_cloudwatch_log_group" "sync" {
  name = "/aws/lambda/${aws_lambda_function.sync.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.stage_uid}SyncLambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# could use fm var
data "aws_iam_policy_document" "sync_knowledge_base" {
  policy_id = "${var.stage_uid}SyncKnowledgeBase"
  statement {
    effect = "Allow"
    actions = [
      "bedrock:StartIngestionJob"
    ]
    resources = [
      "arn:aws:bedrock:us-east-1:139161572996:knowledge-base/${var.kb_id}"
    ]
  }
}

resource "aws_iam_policy" "sync_knowledge_base" {
  policy = data.aws_iam_policy_document.sync_knowledge_base.json
}

resource "aws_iam_role_policy_attachment" "sync_knowledge_base" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.sync_knowledge_base.arn
}

resource "aws_lambda_permission" "gateway_sync" {
  statement_id  = "${var.stage_uid}AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.sync.id}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.execution_arn}/*/*"
}

output "invoke_arn" {
  value = aws_lambda_function.sync.invoke_arn
}
