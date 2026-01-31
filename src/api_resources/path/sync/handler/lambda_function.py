import json
import os
from datetime import datetime

import boto3

session = boto3.Session()
agent = session.client('bedrock-agent')

# not using ingest_knowledge_base_documents as source sync after will override
def handler(event, context):
    response = {
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
                },
            'statusCode': 500,
            'body': 'Error on init'
        }

    KB_ID = os.environ.get('KB_ID')
    SOURCE_ID = os.environ.get('SOURCE_ID')

    ingestion = None
    try:
        ingest_response = agent.start_ingestion_job(
            knowledgeBaseId=KB_ID,
            dataSourceId=SOURCE_ID,
            description=str(datetime.now(tz=None))
        )
        
        ingestion = ingest_response["ingestionJob"]
    except Exception as err:
        print(err)
        response["headers"]["X-Amzn-ErrorType"] = f"{type(err)}"
        response["statusCode"] = 500
        response["body"] = "KB error"
        return response
    
    if ingestion["status"] == "FAILED":
        response["statusCode"] = 500
        response["body"] = json.dumps(ingestion["failureReasons"])
        return response

    response["statusCode"] = 200
    response["body"] = "ingestion started"
    return response
