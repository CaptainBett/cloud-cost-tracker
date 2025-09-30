import boto3
import os
import json
from boto3.dynamodb.conditions import Key

table_name = os.environ.get("DDB_TABLE")
region = os.environ.get("REGION")

dynamodb = boto3.resource("dynamodb", region_name=region)
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    try:
        resp = table.scan(Limit=10)
        items = resp.get("Items", [])
        # Sort by timestamp descending
        items = sorted(items, key=lambda x: x["timestamp"], reverse=True)
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps(items)
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": str(e)
        }
