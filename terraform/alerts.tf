resource "aws_cloudwatch_metric_alarm" "custom_cost_alarm" {
  alarm_name          = "CustomCostAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCost"
  namespace           = "Custom/CostTracker"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0.1
  alarm_description   = "Alarm when custom EstimatedCost metric exceeds $0.10"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
