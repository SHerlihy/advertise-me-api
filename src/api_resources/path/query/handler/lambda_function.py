import json
import os

import boto3

session = boto3.Session()
bedrock = session.client('bedrock')
agent = session.client('bedrock-agent-runtime')

def handler(event, context) -> Respose:
    response = {
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
                },
            'statusCode': 500,
            'body': 'Error on init'
        }

    answer = ""
    try:
        query_kb = Query_KB()
        answer = query_kb.query(event["body"])

    except Exception as err:
        print(err.response)
        response["headers"]["X-Amzn-ErrorType"] = f"{type(err)}"
        response["statusCode"] = 500
        response["body"] = "KB error"
        return response

    response["statusCode"] = 200
    response["body"] = answer
    return response

class Query_KB():
    def __init__(self):
        self.KB_ID = os.environ.get('KB_ID')

        self.agent_profile ="You want to advertise Steven Herlihy as a highly competent and fun software engineer that specialises in web development. \
        The following text, enclosed in square brackets, includes Steven Herlihy's CV / resume [$search_results$]. \
        The following text, enclosed in square brackets, is the question about Steven Herlihy that you must answer [$query$]."
        
        model_id = "amazon.nova-micro-v1:0"
        fm_res = bedrock.get_foundation_model(
            modelIdentifier=model_id
        )

        self.fm_arn = fm_res['modelDetails']['modelArn']

    def query(self, question):
        inference = agent.retrieve_and_generate(
            input={
                'text': question
            },
            retrieveAndGenerateConfiguration={
                'type': 'KNOWLEDGE_BASE',
                'knowledgeBaseConfiguration': {
                    'knowledgeBaseId': self.KB_ID,
                    'modelArn': self.fm_arn,
                    'retrievalConfiguration': {
                        'vectorSearchConfiguration': {
                            'numberOfResults': 5,
                            'overrideSearchType': 'SEMANTIC',
                        }
                    },
                    'generationConfiguration': {
                        'promptTemplate': {
                            'textPromptTemplate': self.agent_profile,
                        },
                        'inferenceConfig': {
                            'textInferenceConfig': {
                                'temperature': 0.8,
                                'topP': 0.1,
                                'maxTokens': 512,
                                'stopSequences': []
                            }
                        },
                        'performanceConfig': {
                            'latency': 'standard'
                        }
                    }
                }
            }
        )
    
        return inference['output']['text']
