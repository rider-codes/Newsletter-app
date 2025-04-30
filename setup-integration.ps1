# Create a simple request template
$requestTemplate = '{
    "application/json": "{\"statusCode\": 200}"
}'

# Save the request template to a temporary file
$requestTemplate | Out-File -FilePath "request-template.json" -Encoding UTF8

# Construct the AWS CLI command
$command = "aws apigateway put-integration " +
          "--rest-api-id 2kfyxaf6t5 " +
          "--resource-id oc0wiiybp3 " +
          "--http-method POST " +
          "--type AWS_PROXY " +
          "--integration-http-method POST " +
          "--uri 'arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:442426883606:function:send-newsletter/invocations'"

# Execute the command
Write-Host "Executing command: $command"
Invoke-Expression $command

# Clean up the temporary file
Remove-Item -Path "request-template.json" 