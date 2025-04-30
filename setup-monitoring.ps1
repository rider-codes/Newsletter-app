# Get AWS account ID
$accountId = aws sts get-caller-identity --query "Account" --output text

Write-Host "Creating SNS topic for alerts..."
# Create SNS Topic for Alarms
$snsTopicArn = aws sns create-topic --name newsletter-alerts --query "TopicArn" --output text

Write-Host "Creating CloudWatch alarms..."
# Create CloudWatch Alarms

# Lambda Alarms
# Error Alarm
aws cloudwatch put-metric-alarm `
    --alarm-name "LambdaErrorsAlarm" `
    --alarm-description "Alarm when Lambda function errors exceed threshold" `
    --metric-name "Errors" `
    --namespace "AWS/Lambda" `
    --dimensions Name=FunctionName,Value=send-newsletter `
    --statistic "Sum" `
    --period 300 `
    --evaluation-periods 1 `
    --threshold 1 `
    --comparison-operator "GreaterThanThreshold" `
    --alarm-actions $snsTopicArn

# Duration Alarm
aws cloudwatch put-metric-alarm `
    --alarm-name "LambdaDurationAlarm" `
    --alarm-description "Alarm when Lambda function duration exceeds threshold" `
    --metric-name "Duration" `
    --namespace "AWS/Lambda" `
    --dimensions Name=FunctionName,Value=send-newsletter `
    --statistic "Average" `
    --period 300 `
    --evaluation-periods 1 `
    --threshold 10000 `
    --comparison-operator "GreaterThanThreshold" `
    --alarm-actions $snsTopicArn

# API Gateway Alarms
# 5XX Error Alarm
aws cloudwatch put-metric-alarm `
    --alarm-name "APIGateway5XXAlarm" `
    --alarm-description "Alarm when API Gateway 5XX errors exceed threshold" `
    --metric-name "5XXError" `
    --namespace "AWS/ApiGateway" `
    --dimensions Name=ApiName,Value=newsletter-api `
    --statistic "Sum" `
    --period 300 `
    --evaluation-periods 1 `
    --threshold 1 `
    --comparison-operator "GreaterThanThreshold" `
    --alarm-actions $snsTopicArn

# Latency Alarm
aws cloudwatch put-metric-alarm `
    --alarm-name "APIGatewayLatencyAlarm" `
    --alarm-description "Alarm when API Gateway latency exceeds threshold" `
    --metric-name "Latency" `
    --namespace "AWS/ApiGateway" `
    --dimensions Name=ApiName,Value=newsletter-api `
    --statistic "Average" `
    --period 300 `
    --evaluation-periods 1 `
    --threshold 5000 `
    --comparison-operator "GreaterThanThreshold" `
    --alarm-actions $snsTopicArn

# SES Alarms
# Bounce Rate Alarm
aws cloudwatch put-metric-alarm `
    --alarm-name "SESBounceRateAlarm" `
    --alarm-description "Alarm when SES bounce rate exceeds threshold" `
    --metric-name "Bounce" `
    --namespace "AWS/SES" `
    --statistic "Average" `
    --period 300 `
    --evaluation-periods 1 `
    --threshold 0.05 `
    --comparison-operator "GreaterThanThreshold" `
    --alarm-actions $snsTopicArn

# Complaint Rate Alarm
aws cloudwatch put-metric-alarm `
    --alarm-name "SESComplaintRateAlarm" `
    --alarm-description "Alarm when SES complaint rate exceeds threshold" `
    --metric-name "Complaint" `
    --namespace "AWS/SES" `
    --statistic "Average" `
    --period 300 `
    --evaluation-periods 1 `
    --threshold 0.001 `
    --comparison-operator "GreaterThanThreshold" `
    --alarm-actions $snsTopicArn

Write-Host "Creating CloudWatch dashboard..."
# Create CloudWatch Dashboard
$dashboardBody = @{
    widgets = @(
        @{
            height = 6
            width = 12
            y = 0
            x = 0
            type = "metric"
            properties = @{
                view = "timeSeries"
                stacked = $false
                metrics = @(
                    @("AWS/Lambda", "Invocations", "FunctionName", "send-newsletter")
                    @(".", "Errors", ".", ".")
                    @(".", "Duration", ".", ".")
                    @(".", "ConcurrentExecutions", ".", ".")
                )
                region = "us-east-1"
                title = "Lambda Function Metrics"
                period = 300
                stat = "Average"
            }
        }
        @{
            height = 6
            width = 12
            y = 0
            x = 12
            type = "metric"
            properties = @{
                view = "timeSeries"
                stacked = $false
                metrics = @(
                    @("AWS/ApiGateway", "Count", "ApiName", "newsletter-api")
                    @(".", "4XXError", ".", ".")
                    @(".", "5XXError", ".", ".")
                    @(".", "Latency", ".", ".")
                )
                region = "us-east-1"
                title = "API Gateway Metrics"
                period = 300
                stat = "Average"
            }
        }
        @{
            height = 6
            width = 12
            y = 6
            x = 0
            type = "metric"
            properties = @{
                view = "timeSeries"
                stacked = $false
                metrics = @(
                    @("AWS/SES", "Send", "Type", "Delivery")
                    @(".", "Bounce", ".", ".")
                    @(".", "Complaint", ".", ".")
                    @(".", "Reject", ".", ".")
                )
                region = "us-east-1"
                title = "SES Email Metrics"
                period = 300
                stat = "Sum"
            }
        }
        @{
            height = 6
            width = 12
            y = 6
            x = 12
            type = "metric"
            properties = @{
                view = "timeSeries"
                stacked = $false
                metrics = @(
                    @("AWS/S3", "NumberOfObjects", "BucketName", "newsletter-templates")
                    @(".", "BucketSizeBytes", ".", ".")
                    @(".", "GetRequests", ".", ".")
                    @(".", "PutRequests", ".", ".")
                )
                region = "us-east-1"
                title = "S3 Bucket Metrics"
                period = 300
                stat = "Average"
            }
        }
    )
}

$dashboardJson = $dashboardBody | ConvertTo-Json -Depth 10 -Compress
aws cloudwatch put-dashboard --dashboard-name "NewsletterServicesDashboard" --dashboard-body "$dashboardJson"

Write-Host "Setting up email notifications..."
# Get the email address for notifications
$notificationEmail = "rahulsrivastava4143@gmail.com"

# Subscribe email to SNS topic
aws sns subscribe `
    --topic-arn $snsTopicArn `
    --protocol email `
    --notification-endpoint $notificationEmail

Write-Host "Setup complete! Dashboard created: NewsletterServicesDashboard"
Write-Host "Please check your email $notificationEmail to confirm the SNS subscription"

Write-Host "`nMonitoring Overview:"
Write-Host "1. Lambda Alarms:"
Write-Host "   - Errors: Triggers when errors occur"
Write-Host "   - Duration: Triggers when function takes longer than 10 seconds"
Write-Host "2. API Gateway Alarms:"
Write-Host "   - 5XX Errors: Triggers on server errors"
Write-Host "   - Latency: Triggers when latency exceeds 5 seconds"
Write-Host "3. SES Alarms:"
Write-Host "   - Bounce Rate: Triggers when bounce rate exceeds 5%"
Write-Host "   - Complaint Rate: Triggers when complaint rate exceeds 0.1%"
Write-Host "`nDashboard Widgets:"
Write-Host "1. Lambda Metrics: Invocations, Errors, Duration, Concurrent Executions"
Write-Host "2. API Gateway Metrics: Request Count, 4XX/5XX Errors, Latency"
Write-Host "3. SES Metrics: Sends, Bounces, Complaints, Rejects"
Write-Host "4. S3 Metrics: Object Count, Bucket Size, Get/Put Requests" 