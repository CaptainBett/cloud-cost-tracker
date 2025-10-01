import boto3
import datetime
import os
import uuid

REGION = os.environ.get("REGION", "us-east-1")
DDB_TABLE = os.environ.get("DDB_TABLE")

dynamodb = boto3.resource("dynamodb", region_name=REGION)
table = dynamodb.Table(DDB_TABLE)
ce = boto3.client("ce", region_name="us-east-1")   # Cost Explorer only works in us-east-1
cw = boto3.client("cloudwatch", region_name="us-east-1")

def get_cost_estimate_days(days=1):
    today = datetime.date.today()
    start = (today - datetime.timedelta(days=days)).strftime("%Y-%m-%d")
    end = today.strftime("%Y-%m-%d")
    resp = ce.get_cost_and_usage(
        TimePeriod={"Start": start, "End": end},
        Granularity="DAILY",
        Metrics=["UnblendedCost"]
    )
    total = 0.0
    for r in resp.get("ResultsByTime", []):
        amt = r["Total"].get("UnblendedCost", {}).get("Amount", "0")
        total += float(amt)
    return total

def lambda_handler(event, context):
    estimate = get_cost_estimate_days(1)

    # Write to DynamoDB
    item = {
        "id": str(uuid.uuid4()),
        "timestamp": datetime.datetime.utcnow().isoformat(),
        "estimated_charges": str(estimate),
        "currency": "USD"
    }
    table.put_item(Item=item)

    # Publish to CloudWatch custom metric
    cw.put_metric_data(
        Namespace="Custom/CostTracker",
        MetricData=[{
            "MetricName": "EstimatedCost",
            "Timestamp": datetime.datetime.utcnow(),
            "Value": estimate,
            "Unit": "None"
        }]
    )

    return {"status": "ok", "value": estimate}
