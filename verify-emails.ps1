# Verify sender email
Write-Host "Verifying sender email..."
aws ses verify-email-identity --email-address rahulsrivastava4143@gmail.com

# Verify recipient email
Write-Host "Verifying recipient email..."
aws ses verify-email-identity --email-address rahulsr0712@gmail.com

Write-Host "Email verification requests sent. Please check your email to confirm the verifications." 