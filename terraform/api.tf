# Zip the API lambda
data "archive_file" "api_reader_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/api_reader/lambda_function.py"
  output_path = "${path.module}/../lambda/api_reader.zip"
}

resource "aws_lambda_function" "api_reader" {
  filename         = data.archive_file.api_reader_zip.output_path
  function_name    = "cost-api-reader"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256(data.archive_file.api_reader_zip.output_path)

  environment {
    variables = {
      DDB_TABLE = aws_dynamodb_table.cost_logs.name
      REGION    = var.region
    }
  }
}

# API Gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = "cost-tracker-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.api_reader.arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_costs" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /costs"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_reader.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}

