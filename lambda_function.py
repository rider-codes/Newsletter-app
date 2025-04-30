import json
import boto3
import csv
from io import StringIO
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    try:
        # Initialize AWS services
        s3 = boto3.client('s3')
        ses = boto3.client('ses')
        
        # Get contacts from S3
        bucket_name = 'dsa-email-marketing'
        file_key = 'contacts.csv'
        
        try:
            response = s3.get_object(Bucket=bucket_name, Key=file_key)
            csv_content = response['Body'].read().decode('utf-8')
        except ClientError as e:
            return {
                'statusCode': 500,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Accept,Origin,Referer,User-Agent',
                    'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS,HEAD,PATCH',
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'message': f'Error accessing contacts file: {str(e)}'
                })
            }
        
        # Parse CSV
        csv_file = StringIO(csv_content)
        csv_reader = csv.reader(csv_file)
        next(csv_reader)  # Skip header row
        
        emails_sent = 0
        errors = []
        
        # Send emails to all contacts
        for row in csv_reader:
            try:
                email = row[0]  # Assuming email is in the first column
                
                # Send email using SES
                ses.send_email(
                    Source='your-verified-email@domain.com',  # Replace with your verified SES email
                    Destination={
                        'ToAddresses': [email]
                    },
                    Message={
                        'Subject': {
                            'Data': 'Your Newsletter'
                        },
                        'Body': {
                            'Text': {
                                'Data': 'Your newsletter content here'
                            }
                        }
                    }
                )
                emails_sent += 1
            except Exception as e:
                errors.append(f'Error sending to {email}: {str(e)}')
        
        result = {
            'emails_sent': emails_sent,
            'errors': errors if errors else None
        }
        
        # Return response with CORS headers
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Accept,Origin,Referer,User-Agent',
                'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS,HEAD,PATCH',
                'Content-Type': 'application/json'
            },
            'body': json.dumps(result)
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Accept,Origin,Referer,User-Agent',
                'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS,HEAD,PATCH',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': str(e)
            })
        } 