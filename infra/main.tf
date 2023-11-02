provider "aws" {
  region = var.region
}

data "aws_cognito_user_pools" "mikes-user-pool" {
  name = "mikes-user-pool"
}

output "mikes-user-pool" {
  value = data.aws_cognito_user_pools.mikes-user-pool.id
}

data "aws_cognito_user_pool_clients" "mikes-cognito-app-client" {
  user_pool_id = data.aws_cognito_user_pools.mikes-user-pool.id
}

output "mikes-cognito-app-client" {
  value = data.aws_cognito_user_pool_clients.mikes-cognito-app-client.client_ids
}

resource "aws_iam_role" "mikes_lambda_authorizer_role" {
  name               = "mikes_lambda_authorizer_role"
  assume_role_policy = file("policy/lambda_assume_role_policy.json")
}

resource "aws_lambda_function" "mikes_lambda_authorizer" {
  function_name = "mikes_lambda_authorizer"
  handler       = "app/lambda_function.handler"
  runtime       = "python3.11"
  role          = aws_iam_role.mikes_lambda_authorizer_role.arn

  filename = "lambda_function.zip"

  source_code_hash = filebase64sha256("lambda_function.zip")

  depends_on = [
    aws_iam_role.mikes_lambda_authorizer_role
  ]

  environment {
    variables = {
      COGNITO_CLIENT_ID    = aws_ssm_parameter.cognito_client_id.value,
      COGNITO_USER_POOL_ID = aws_ssm_parameter.cognito_user_pool_id.value
    }
  }
}

resource "aws_ssm_parameter" "cognito_user_pool_id" {
  name        = "/mikes_lambda_authorizer/cognito_user_pool_id"
  description = "Cognito User Pool ID"
  type        = "SecureString"
  value       = data.aws_cognito_user_pools.mikes-user-pool.id
}

resource "aws_ssm_parameter" "cognito_client_id" {
  name        = "/mikes_lambda_authorizer/cognito_client_id"
  description = "Cognito Client ID"
  type        = "SecureString"
  value       = data.aws_cognito_user_pool_clients.mikes-cognito-app-client.client_ids[0]
}