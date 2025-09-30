resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "EstimatedChargesAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 300
  statistic           = "Maximum"
  threshold           = 1.0
  alarm_description   = "Alarm when estimated charges exceed $1"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    Currency = "USD"
  }
}
