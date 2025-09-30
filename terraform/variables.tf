variable "region" {
  description = "AWS region for primary resources"
  type        = string
  default     = "us-east-1"
}

variable "alert_email" {
  description = "Email address to receive SNS billing alerts"
  type        = string
}

variable "ddb_table_name" {
  description = "Name of DynamoDB table to store cost logs"
  type        = string
  default     = "cost-tracker-logs"
}
