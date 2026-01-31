import os

def handler(event, context):
    AUTH_KEY = os.environ.get('AUTH_KEY')
    USER_ID = "testUser"
    
    try:
        # Get the auth token from query parameters
        query_params = event.get('queryStringParameters', {}) or {}
        req_key = query_params.get('authKey')
        
        if not req_key:
            print('No authKey provided in query parameters')
            return generateDeny(USER_ID, event.get('methodArn', ''))
        
        if req_key != AUTH_KEY:
            print('Invalid auth key provided')
            return generateDeny(USER_ID, event.get('methodArn', ''))
        
        print('Authorization successful')
        return generateAllow(USER_ID, event.get('methodArn', ''))
        
    except Exception as e:
        print(f"Error in authorizer: {str(e)}")
        return generateDeny(USER_ID, event.get('methodArn', ''))

def generatePolicy(principalId, effect, resource):
    authResponse = {
        'principalId': principalId,
        'policyDocument': {
            'Version': '2012-10-17',
            'Statement': [
                {
                    'Action': 'execute-api:Invoke',
                    'Effect': effect,
                    'Resource': resource
                }
            ]
        },
        'context': {
            'message': effect
        }
    }
    return authResponse

def generateAllow(principalId, resource):
    return generatePolicy(principalId, 'Allow', resource)


def generateDeny(principalId, resource):
    return generatePolicy(principalId, 'Deny', resource)
