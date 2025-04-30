$jsonParams = @{
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Accept,Origin,Referer,User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
}

Write-Host "Setting up integration response for /send-newsletter endpoint..."

# Create the integration response without JSON conversion
$params = "method.response.header.Access-Control-Allow-Headers='Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Accept,Origin,Referer,User-Agent',method.response.header.Access-Control-Allow-Methods='GET,POST,PUT,DELETE,OPTIONS',method.response.header.Access-Control-Allow-Origin='*'"

$command = "aws apigateway put-integration-response --rest-api-id raitfis6p7 --resource-id 9tig6a --http-method POST --status-code 200 --response-parameters '$params'"
Write-Host "Executing command:"
Write-Host $command
Invoke-Expression $command 