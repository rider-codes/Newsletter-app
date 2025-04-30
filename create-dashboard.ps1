# Create CloudWatch Dashboard
$dashboardName = "newsletter-monitoring"
$dashboardBody = Get-Content -Path "dashboard.json" -Raw

# Convert the JSON to a single line and escape it properly
$escapedBody = $dashboardBody.Replace('"', '\"')

aws cloudwatch put-dashboard `
    --dashboard-name $dashboardName `
    --dashboard-body "$escapedBody"

Write-Host "Dashboard created successfully!" 