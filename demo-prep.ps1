# Demo Preparation Script
Write-Host "🎯 GCP OPA Policy Demo - Preparation Check" -ForegroundColor Cyan

Write-Host "`n📋 Checking Demo Requirements..." -ForegroundColor Yellow

# Check if key files exist
$requiredFiles = @(
    "validate.ps1",
    "complete-demo.ps1", 
    "policies\security\deny_null_resources.rego",
    "policies\gcp\compute_security.rego",
    "infrastructure\gcp-sample.tf",
    "cloudbuild.yaml",
    "README.md"
)

$allGood = $true

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ $file - MISSING!" -ForegroundColor Red
        $allGood = $false
    }
}

# Check OPA executable
if (Test-Path "opa.exe") {
    Write-Host "✅ opa.exe" -ForegroundColor Green
} else {
    Write-Host "❌ opa.exe - MISSING!" -ForegroundColor Red
    $allGood = $false
}

# Test basic validation
Write-Host "`n🧪 Testing Policy Validation..." -ForegroundColor Yellow
$testResult = & .\validate.ps1 2>&1
if ($LASTEXITCODE -eq 1) {
    Write-Host "✅ Policy validation working - correctly blocking violations" -ForegroundColor Green
} else {
    Write-Host "❌ Policy validation not working as expected" -ForegroundColor Red
    $allGood = $false
}

Write-Host "`n📊 Demo Readiness Status:" -ForegroundColor Cyan
if ($allGood) {
    Write-Host "🎉 ALL SYSTEMS GO! Your demo is ready!" -ForegroundColor Green
    Write-Host "`n🚀 To start your demo:" -ForegroundColor Yellow
    Write-Host "   Option 1 (Full): .\complete-demo.ps1" -ForegroundColor White
    Write-Host "   Option 2 (Quick): .\validate.ps1" -ForegroundColor White
    Write-Host "`n📖 Demo guide: DEMO-GUIDE.md" -ForegroundColor Yellow
    Write-Host "🔗 GitHub repo: https://github.com/laasna/gcp-opa-policies" -ForegroundColor Yellow
} else {
    Write-Host "⚠️  Some issues found. Please fix before demo." -ForegroundColor Red
}

Write-Host "`n" + "=" * 50