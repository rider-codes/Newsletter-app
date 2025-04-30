import json
import boto3
import csv
from io import StringIO
from botocore.exceptions import ClientError
import re

def is_valid_email(email):
    # Basic email validation
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))

def lambda_handler(event, context):
    # CORS headers
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Accept',
        'Access-Control-Allow-Methods': 'OPTIONS,POST'
    }
    
    # Handle preflight request
    if event.get('httpMethod') == 'OPTIONS':
        return {
            'statusCode': 200,
            'headers': headers,
            'body': json.dumps('Preflight request successful')
        }
    
    try:
        # Initialize AWS services
        s3 = boto3.client('s3')
        ses = boto3.client('ses')
        
        # Get email template from S3
        try:
            print("Fetching email template...")
            template_response = s3.get_object(Bucket='dsa-email-marketing', Key='email_template.html')
            email_template = template_response['Body'].read().decode('utf-8')
            print("Email template fetched successfully")
        except ClientError as e:
            print(f"Error fetching email template: {str(e)}")
            return {
                'statusCode': 500,
                'headers': headers,
                'body': json.dumps({
                    'message': f'Error accessing email template: {str(e)}'
                })
            }

        # Check if we have direct API input
        if event.get('body'):
            try:
                body = json.loads(event['body'])
                subject = body.get('subject', 'Master the Array Mystery - AlgoQuest Weekly')
                content = body.get('content')
                recipients = body.get('recipients', [])
                
                if not recipients:
                    return {
                        'statusCode': 400,
                        'headers': headers,
                        'body': json.dumps({
                            'message': 'No recipients provided'
                        })
                    }
                
                # Convert recipients to the same format as CSV data
                all_rows = []
                for recipient in recipients:
                    if isinstance(recipient, dict):
                        # If recipient is already a dictionary with FirstName and Email
                        all_rows.append(recipient)
                    else:
                        # If recipient is just an email string
                        all_rows.append({'FirstName': 'Subscriber', 'Email': recipient})
            except Exception as e:
                return {
                    'statusCode': 400,
                    'headers': headers,
                    'body': json.dumps({
                        'message': f'Invalid request body: {str(e)}'
                    })
                }
        else:
            # Get contacts from S3
            try:
                print("Fetching contacts.csv...")
                contacts_response = s3.get_object(Bucket='dsa-email-marketing', Key='contacts.csv')
                csv_content = contacts_response['Body'].read().decode('utf-8')
                
                # Remove BOM if present
                if csv_content.startswith('\ufeff'):
                    csv_content = csv_content[1:]
                
                # Parse CSV
                csv_file = StringIO(csv_content)
                csv_reader = csv.DictReader(csv_file)
                all_rows = list(csv_reader)
                
                if not all_rows:
                    return {
                        'statusCode': 400,
                        'headers': headers,
                        'body': json.dumps({
                            'message': 'No contacts found in CSV'
                        })
                    }
                
            except Exception as e:
                return {
                    'statusCode': 500,
                    'headers': headers,
                    'body': json.dumps({
                        'message': f'Error processing contacts: {str(e)}'
                    })
                }
        
        emails_sent = 0
        errors = []
        
        # Process each recipient
        for row in all_rows:
            current_email = row['Email'].strip() if 'Email' in row else None
            try:
                if not current_email or not is_valid_email(current_email):
                    errors.append(f"Invalid email: {current_email if current_email else 'No email provided'}")
                    continue
                
                first_name = row.get('FirstName', '').strip() or 'Subscriber'
                personalized_content = email_template.replace('{{FirstName}}', first_name)
                
                # Send email
                response = ses.send_email(
                    Source='rahulsrivastava4143@gmail.com',
                    Destination={
                        'ToAddresses': [current_email]
                    },
                    Message={
                        'Subject': {
                            'Data': 'Master the Array Mystery - AlgoQuest Weekly'
                        },
                        'Body': {
                            'Html': {
                                'Data': personalized_content
                            }
                        }
                    }
                )
                print(f"Email sent successfully to {current_email}")
                emails_sent += 1
                
            except Exception as e:
                error_msg = f"Error sending to {current_email if current_email else 'unknown recipient'}: {str(e)}"
                print(error_msg)
                errors.append(error_msg)
        
        result = {
            'emails_sent': emails_sent,
            'errors': errors if errors else None
        }
        
        return {
            'statusCode': 200,
            'headers': headers,
            'body': json.dumps(result)
        }
        
    except Exception as e:
        error_msg = f"Fatal error: {str(e)}"
        print(error_msg)
        return {
            'statusCode': 500,
            'headers': headers,
            'body': json.dumps({
                'message': error_msg
            })
        } 
