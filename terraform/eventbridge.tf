resource "aws_cloudwatch_event_rule" "cost_logger_schedule" {
  name                = "cost-logger-schedule"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "cost_logger_target" {
  rule      = aws_cloudwatch_event_rule.cost_logger_schedule.name
  target_id = "costLoggerLambda"
  arn       = aws_lambda_function.cost_logger.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_logger.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cost_logger_schedule.arn
}
