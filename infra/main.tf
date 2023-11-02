provider "aws" {
  region = var.region
}

data "aws_cognito_user_pools" "mikes-user-pool" {
  name = "mikes-user-pool"
}

data "aws_cognito_user_pool_clients" "mikes-user-pool-app-client" {
  user_pool_id = data.aws_cognito_user_pools.mikes-user-pool.ids[0]
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
      COGNITO_CLIENT_ID    = data.aws_cognito_user_pools.mikes-user-pool.id,
      COGNITO_USER_POOL_ID = data.aws_cognito_user_pool_clients.mikes-user-pool-app-client.client_ids[0]
    }
  }
}