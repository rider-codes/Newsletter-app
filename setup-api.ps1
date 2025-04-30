# Set AWS region and account ID
$region = "us-east-1"  # US East region
$accountId = (aws sts get-caller-identity --query "Account" --output text)

# Create IAM role for Lambda
$roleName = "newsletter-lambda-role"
$assumeRolePolicy = '{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"},\"Action\":\"sts:AssumeRole\"}]}'

Write-Host "Creating/updating IAM role..."
try {
    aws iam create-role --role-name $roleName --assume-role-policy-document $assumeRolePolicy
} catch {
    Write-Host "Role already exists, continuing..."
}

Write-Host "Attaching role policy..."
aws iam put-role-policy --role-name $roleName --policy-name newsletter-lambda-policy --policy-document file://lambda-role-policy.json

# Wait for role to be ready
Start-Sleep -Seconds 10

# Create/update Lambda function
Write-Host "Creating/updating Lambda function..."
$roleArn = (aws iam get-role --role-name $roleName | ConvertFrom-Json).Role.Arn

try {
    aws lambda create-function --function-name send-newsletter --runtime python3.9 --handler send_newsletter.lambda_handler --role $roleArn --zip-file fileb://send_newsletter.zip --timeout 300 --memory-size 256
} catch {
    Write-Host "Function already exists, updating code..."
    aws lambda update-function-code --function-name send-newsletter --zip-file fileb://send_newsletter.zip
}

# Create API Gateway if it doesn't exist
Write-Host "Creating API Gateway..."
$api = (aws apigateway create-rest-api --name newsletter-api --description "API for sending newsletters with proper CORS support" | ConvertFrom-Json)
$apiId = $api.id

# Get root resource ID
Write-Host "Getting root resource ID..."
$rootResourceId = (aws apigateway get-resources --rest-api-id $apiId | ConvertFrom-Json).items[0].id

# Create resource
Write-Host "Creating API resource..."
$resourceId = (aws apigateway create-resource --rest-api-id $apiId --parent-id $rootResourceId --path-part "send-newsletter" | ConvertFrom-Json).id

# Create POST method
Write-Host "Creating POST method..."
aws apigateway put-method `
    --rest-api-id $apiId `
    --resource-id $resourceId `
    --http-method POST `
    --authorization-type NONE

# Get Lambda function ARN
Write-Host "Getting Lambda function ARN..."
$lambdaArn = (aws lambda get-function --function-name send-newsletter | ConvertFrom-Json).Configuration.FunctionArn

# Set up Lambda integration for POST
Write-Host "Setting up Lambda integration for POST..."
$uri = "arn:aws:apigateway:${region}:lambda:path/2015-03-31/functions/${lambdaArn}/invocations"
aws apigateway put-integration `
    --rest-api-id $apiId `
    --resource-id $resourceId `
    --http-method POST `
    --type AWS_PROXY `
    --integration-http-method POST `
    --uri $uri

# Create OPTIONS method for CORS
Write-Host "Creating OPTIONS method..."
aws apigateway put-method `
    --rest-api-id $apiId `
    --resource-id $resourceId `
    --http-method OPTIONS `
    --authorization-type NONE

# Set up mock integration for OPTIONS
Write-Host "Setting up mock integration for OPTIONS..."
$requestTemplates = '{"application/json":"{\"statusCode\":200}"}'
aws apigateway put-integration `
    --rest-api-id $apiId `
    --resource-id $resourceId `
    --http-method OPTIONS `
    --type MOCK `
    --request-templates $requestTemplates

# Set up method response for OPTIONS
Write-Host "Setting up method response for OPTIONS..."
$methodResponseParams = '{"method.response.header.Access-Control-Allow-Headers":true,"method.response.header.Access-Control-Allow-Methods":true,"method.response.header.Access-Control-Allow-Origin":true}'
aws apigateway put-method-response `
    --rest-api-id $apiId `
    --resource-id $resourceId `
    --http-method OPTIONS `
    --status-code 200 `
    --response-parameters $methodResponseParams

# Set up integration response for OPTIONS
Write-Host "Setting up integration response for OPTIONS..."
$integrationResponseParams = '{"method.response.header.Access-Control-Allow-Headers":"\"Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Accept\"","method.response.header.Access-Control-Allow-Methods":"\"OPTIONS,POST\"","method.response.header.Access-Control-Allow-Origin":"\"*\""}'
aws apigateway put-integration-response `
    --rest-api-id $apiId `
    --resource-id $resourceId `
    --http-method OPTIONS `
    --status-code 200 `
    --response-parameters $integrationResponseParams

# Set up method response for POST
Write-Host "Setting up method response for POST..."
$postMethodResponseParams = '{"method.response.header.Access-Control-Allow-Origin":true}'
aws apigateway put-method-response `
    --rest-api-id $apiId `
    --resource-id $resourceId `
    --http-method POST `
    --status-code 200 `
    --response-parameters $postMethodResponseParams

# Set up integration response for POST
Write-Host "Setting up integration response for POST..."
$postIntegrationResponseParams = '{"method.response.header.Access-Control-Allow-Origin":"\"*\""}'
aws apigateway put-integration-response `
    --rest-api-id $apiId `
    --resource-id $resourceId `
    --http-method POST `
    --status-code 200 `
    --response-parameters $postIntegrationResponseParams

# Add Lambda permission
Write-Host "Adding Lambda permission..."
$sourceArn = "arn:aws:execute-api:${region}:${accountId}:${apiId}/*/*/send-newsletter"
try {
    aws lambda add-permission `
        --function-name send-newsletter `
        --statement-id "api-gateway-permission-$(Get-Random)" `
        --action lambda:InvokeFunction `
        --principal apigateway.amazonaws.com `
        --source-arn $sourceArn
} catch {
    Write-Host "Error adding Lambda permission, continuing..."
}

# Deploy API
Write-Host "Deploying API..."
$deployment = (aws apigateway create-deployment --rest-api-id $apiId --stage-name prod | ConvertFrom-Json)

Write-Host "`nSetup complete!"
Write-Host "API Gateway URL: https://$apiId.execute-api.$region.amazonaws.com/prod/send-newsletter" 