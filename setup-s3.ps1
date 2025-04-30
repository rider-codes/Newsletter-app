# Create S3 bucket
Write-Host "Creating S3 bucket..."
aws s3api create-bucket `
    --bucket dsa-email-marketing `
    --region us-east-1

# Upload contacts.csv
Write-Host "Uploading contacts.csv..."
aws s3 cp contacts.csv s3://dsa-email-marketing/contacts.csv

# Upload email template
Write-Host "Uploading email template..."
aws s3 cp email_template.html s3://dsa-email-marketing/email_template.html

Write-Host "S3 setup complete!" 