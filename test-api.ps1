# Test script for the newsletter API
$apiEndpoint = "https://6k4ijo36te.execute-api.us-east-1.amazonaws.com/prod/send-newsletter"

$body = @{
    subject = "Test Newsletter"
    content = "Hello {FirstName}, this is a test newsletter!"
    recipients = @(
        "rahulsr0712@gmail.com"
    )
} | ConvertTo-Json

Write-Host "Sending test request to API..."
Write-Host "Request body:"
Write-Host $body

$headers = @{
    "Content-Type" = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri $apiEndpoint -Method Post -Body $body -Headers $headers
    Write-Host "Response received:"
    $response | ConvertTo-Json
} catch {
    Write-Host "Error occurred:"
    Write-Host $_.Exception.Message
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response body:"
        Write-Host $responseBody
    }
} 