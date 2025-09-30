resource "aws_dynamodb_table" "cost_logs" {
  name         = var.ddb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  range_key    = "timestamp"  
  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  tags = {
    Project = "CloudCostTracker"
  }
}