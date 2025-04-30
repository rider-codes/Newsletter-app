$alarmName = "newsletter-errors"
$description = "Alert when newsletter Lambda has errors"
$metricName = "Errors"
$namespace = "AWS/Lambda"
$dimensions = "Name=FunctionName,Value=send-newsletter"
$topicArn = "arn:aws:sns:us-east-1:442426883606:newsletter-alerts"

aws cloudwatch put-metric-alarm `
    --alarm-name $alarmName `
    --alarm-description $description `
    --metric-name $metricName `
    --namespace $namespace `
    --statistic Sum `
    --period 300 `
    --threshold 1 `
    --comparison-operator GreaterThanOrEqualToThreshold `
    --evaluation-periods 1 `
    --dimensions $dimensions `
    --alarm-actions $topicArn 