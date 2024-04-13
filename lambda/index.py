import logging
import json
LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)
def handler(event, context):
    try:
        LOGGER.info('SQS EVENT: %s', event)
        for sqs_rec in event['Records']:
            s3_event = json.loads(sqs_rec['body'])
            LOGGER.info('S3 EVENT: %s', s3_event)
            # Skipping S3 test event
            if 'Event' in s3_event.keys() and s3_event['Event'] == 's3:TestEvent':
                break
            for s3_rec in s3_event['Records']:
                LOGGER.info('Bucket name: %s', s3_rec['s3']['bucket']['name'])
                LOGGER.info('Object key: %s', s3_rec['s3']['object']['key'])
    except Exception as exception:
        LOGGER.error('Exception: %s', exception)
        raise

# The handler function is the entry point for the Lambda function. It receives the event and context objects as input parameters. The event object contains the details of the event that triggered the Lambda function. In this case, the event object contains the details of the SQS message that triggered the Lambda function. The context object contains the runtime information of the Lambda function.