import boto3
import datetime
import os
import uuid


CLOUDWATCH_REGION = "us-east-1"
DDB_TABLE = os.environ.get("DDB_TABLE")
AWS_REGION = os.environ.get("REGION")

cw = boto3.client("cloudwatch", region_name=CLOUDWATCH_REGION)
dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
table = dynamodb.Table(DDB_TABLE)

def get_estimated_charges(currency="USD"):
    end = datetime.datetime.utcnow()
    start = end - datetime.timedelta(hours=7)  
    resp = cw.get_metric_statistics(
        Namespace="AWS/Billing",
        MetricName="EstimatedCharges",
        Dimensions=[{"Name": "Currency", "Value": currency}],
        StartTime=start,
        EndTime=end,
        Period=21600,  
        Statistics=["Maximum"]
    )
    dps = resp.get("Datapoints", [])
    if not dps:
        return None
    latest = sorted(dps, key=lambda x: x["Timestamp"])[-1]
    return float(latest.get("Maximum", 0.0))

def lambda_handler(event, context):
    val = get_estimated_charges("USD")
    item = {
        "id": str(uuid.uuid4()),
        "timestamp": datetime.datetime.utcnow().isoformat(),
        "estimated_charges": str(val if val is not None else 0.0),
        "currency": "USD"
    }
    table.put_item(Item=item)
    return {"status": "ok", "value": val}
