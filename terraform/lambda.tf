# Zip up the Lambda code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/cost_logger/"
  output_path = "${path.module}/../lambda/cost_logger.zip"
}

resource "aws_lambda_function" "cost_logger" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "cost-logger"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)

  environment {
    variables = {
      DDB_TABLE = aws_dynamodb_table.cost_logs.name
      REGION    = var.region
    }
  }
}
