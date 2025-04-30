# Set region
$region = "us-east-1"

# Create API Gateway
Write-Host "Creating API Gateway..."
$api = (aws apigateway create-rest-api --name "newsletter-api" --description "API for sending newsletters with CORS support" | ConvertFrom-Json)
$apiId = $api.id

# Get root resource ID
Write-Host "Getting root resource ID..."
$rootResourceId = (aws apigateway get-resources --rest-api-id $apiId | ConvertFrom-Json).items[0].id

# Create resource
Write-Host "Creating /send-newsletter resource..."
$resource = (aws apigateway create-resource --rest-api-id $apiId --parent-id $rootResourceId --path-part "send-newsletter" | ConvertFrom-Json)
$resourceId = $resource.id

# Create POST method
Write-Host "Creating POST method..."
aws apigateway put-method `
    --rest-api-id $apiId `
    --resource-id $resourceId `
    --http-method POST `
    --authorization-type NONE

# Get Lambda ARN and set up integration
Write-Host "Setting up Lambda integration..."
$lambdaArn = (aws lambda get-function --function-name send-newsletter | ConvertFrom-Json).Configuration.FunctionArn
aws apigateway put-integration `
    --rest-api-id $apiId `
    --resource-id $resourceId `
    --http-method POST `
    --type AWS_PROXY `
    --integration-http-method POST `
    --uri "arn:aws:apigateway:$region:lambda:path/2015-03-31/functions/$lambdaArn/invocations"

# Create OPTIONS method
Write-Host "Creating OPTIONS method..."
aws apigateway put-method `
    --rest-api-id $apiId `
    --resource-id $resourceId `
    --http-method OPTIONS `
    --authorization-type NONE

# Set up OPTIONS mock integration
Write-Host "Setting up OPTIONS mock integration..."
aws apigateway put-integration `
    --rest-api-id $apiId `
    --resource-id $resourceId `
    --http-method OPTIONS `
    --type MOCK `
    --request-templates '{"application/json":"{\"statusCode\":200}"}'

# Configure OPTIONS method response
Write-Host "Configuring OPTIONS method response..."
aws apigateway put-method-response `
    --rest-api-id $apiId `
    --resource-id $resourceId `
    --http-method OPTIONS `
    --status-code 200 `
    --response-parameters '{
        "method.response.header.Access-Control-Allow-Headers":true,
        "method.response.header.Access-Control-Allow-Methods":true,
        "method.response.header.Access-Control-Allow-Origin":true
    }'

# Configure OPTIONS integration response
Write-Host "Configuring OPTIONS integration response..."
aws apigateway put-integration-response `
    --rest-api-id $apiId `
    --resource-id $resourceId `
    --http-method OPTIONS `
    --status-code 200 `
    --response-parameters '{
        "method.response.header.Access-Control-Allow-Headers":"\"Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Accept\"",
        "method.response.header.Access-Control-Allow-Methods":"\"OPTIONS,POST\"",
        "method.response.header.Access-Control-Allow-Origin":"\"*\""
    }'

# Add Lambda permission
Write-Host "Adding Lambda permission..."
$accountId = (aws sts get-caller-identity --query "Account" --output text)
$random = Get-Random
aws lambda add-permission `
    --function-name send-newsletter `
    --statement-id "api-gateway-permission-$random" `
    --action lambda:InvokeFunction `
    --principal apigateway.amazonaws.com `
    --source-arn "arn:aws:execute-api:$region:$accountId:$apiId/*/*/send-newsletter"

# Deploy API
Write-Host "Deploying API..."
aws apigateway create-deployment `
    --rest-api-id $apiId `
    --stage-name prod

# Output the API endpoint
Write-Host "`nSetup complete!"
Write-Host "API endpoint: https://$apiId.execute-api.$region.amazonaws.com/prod/send-newsletter" 