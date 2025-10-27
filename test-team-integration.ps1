# Test Team Integration with Sanjana's GCP
param(
    [string]$SanjanaProjectId = "sanjana-project-id"
)

Write-Host "🧪 Testing Team Integration Setup" -ForegroundColor Cyan
Write-Host "Sanjana's Project: $SanjanaProjectId" -ForegroundColor Yellow

Write-Host "`n📋 Checking integration readiness..." -ForegroundColor Green

# Check if files are updated
$checks = @()

# Check infrastructure file
if (Get-Content "infrastructure\gcp-sample.tf" | Select-String $SanjanaProjectId) {
    $checks += "✅ Infrastructure configured for Sanjana's project"
} else {
    $checks += "❌ Infrastructure not updated - run setup script first"
}

# Check cloudbuild file
if (Get-Content "cloudbuild.yaml" | Select-String $SanjanaProjectId) {
    $checks += "✅ Cloud Build configured for Sanjana's project"
} else {
    $checks += "❌ Cloud Build not updated - run setup script first"
}

# Check setup commands exist
if (Test-Path "sanjana-setup-commands.sh") {
    $checks += "✅ Setup commands ready for Sanjana"
} else {
    $checks += "❌ Setup commands missing - run setup script first"
}

# Display results
foreach ($check in $checks) {
    Write-Host $check
}

Write-Host "`n🎯 Demo Readiness:" -ForegroundColor Cyan

if ($checks -match "❌") {
    Write-Host "⚠️  Setup incomplete. Run this first:" -ForegroundColor Yellow
    Write-Host ".\setup-sanjana-gcp.ps1 -SanjanaProjectId 'her-actual-project-id'" -ForegroundColor White
} else {
    Write-Host "🎉 Ready for team demo!" -ForegroundColor Green
    
    Write-Host "`n📝 Demo Flow:" -ForegroundColor Yellow
    Write-Host "1. Sanjana runs: sanjana-setup-commands.sh" -ForegroundColor White
    Write-Host "2. Sanjana connects GitHub in Cloud Build console" -ForegroundColor White
    Write-Host "3. Both test locally: .\validate.ps1" -ForegroundColor White
    Write-Host "4. Push commit to trigger Cloud Build" -ForegroundColor White
    Write-Host "5. Show live policy validation in GCP!" -ForegroundColor White
    
    Write-Host "`n🔗 Key Links:" -ForegroundColor Yellow
    Write-Host "- GitHub: https://github.com/laasna/gcp-opa-policies" -ForegroundColor White
    Write-Host "- Cloud Build: https://console.cloud.google.com/cloud-build/builds?project=$SanjanaProjectId" -ForegroundColor White
}