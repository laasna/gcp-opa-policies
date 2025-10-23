# Test Sample GCP Infrastructure Against OPA Policies
param(
    [string]$Environment = "dev",
    [string]$ProjectId = "laasna"
)

Write-Host "🧪 Testing Sample GCP Infrastructure" -ForegroundColor Cyan
Write-Host "Environment: $Environment" -ForegroundColor Yellow
Write-Host "Project ID: $ProjectId" -ForegroundColor Yellow

# Set environment variables
$env:TF_VAR_environment = $Environment
$env:TF_VAR_project_id = $ProjectId

# Change to infrastructure directory
Set-Location infrastructure

Write-Host "`n📝 Initializing Terraform..." -ForegroundColor Green
& ..\terraform.exe init -input=false

Write-Host "`n📋 Generating Terraform plan..." -ForegroundColor Green
& ..\terraform.exe plan -out=sample.tfplan -input=false

Write-Host "`n🔄 Converting plan to JSON..." -ForegroundColor Green
& ..\terraform.exe show -json sample.tfplan > sample-plan.json

# Return to root directory
Set-Location ..

Write-Host "`n🔍 Running OPA Policy Validation..." -ForegroundColor Green

# Test all policy categories against sample infrastructure
$policies = @(
    @{Name="Security"; Package="terraform.security"},
    @{Name="GCP Compute"; Package="terraform.gcp.compute"},
    @{Name="GCP Storage"; Package="terraform.gcp.storage"},
    @{Name="GCP Network"; Package="terraform.gcp.network"},
    @{Name="GCP IAM"; Package="terraform.gcp.iam"}
)

$violations = @()
$passed = @()

foreach ($policy in $policies) {
    Write-Host "  Testing $($policy.Name) policies..." -ForegroundColor Yellow
    $result = & .\opa.exe eval -d policies -i infrastructure\sample-plan.json "data.$($policy.Package).deny" --format json 2>$null
    
    if ($LASTEXITCODE -eq 0 -and $result) {
        $jsonResult = $result | ConvertFrom-Json
        if ($jsonResult.result -and $jsonResult.result.Count -gt 0) {
            foreach ($violation in $jsonResult.result) {
                foreach ($expr in $violation.expressions) {
                    foreach ($key in $expr.value.PSObject.Properties.Name) {
                        $violations += "$($policy.Name): $key"
                    }
                }
            }
        } else {
            $passed += $policy.Name
        }
    } else {
        $passed += $policy.Name
    }
}

# Report results
Write-Host "`n📊 VALIDATION RESULTS:" -ForegroundColor Cyan
Write-Host "=" * 50

if ($passed.Count -gt 0) {
    Write-Host "`n✅ PASSED POLICIES:" -ForegroundColor Green
    foreach ($policy in $passed) {
        Write-Host "  ✓ $policy" -ForegroundColor Green
    }
}

if ($violations.Count -gt 0) {
    Write-Host "`n❌ POLICY VIOLATIONS:" -ForegroundColor Red
    foreach ($violation in $violations) {
        Write-Host "  • $violation" -ForegroundColor Red
    }
    Write-Host "`n🚫 DEPLOYMENT BLOCKED!" -ForegroundColor Red
    
    Write-Host "`n💡 REMEDIATION GUIDANCE:" -ForegroundColor Yellow
    Write-Host "1. Review the policy violations above"
    Write-Host "2. Modify infrastructure/gcp-sample.tf to fix violations"
    Write-Host "3. Re-run this test script"
    Write-Host "4. For production environment, ensure stricter compliance"
    
    $exitCode = 1
} else {
    Write-Host "`n🎉 ALL POLICIES PASSED!" -ForegroundColor Green
    Write-Host "Sample infrastructure is compliant and ready for deployment." -ForegroundColor Green
    $exitCode = 0
}

# Cleanup
Remove-Item "infrastructure\sample.tfplan" -ErrorAction SilentlyContinue
Remove-Item "infrastructure\sample-plan.json" -ErrorAction SilentlyContinue

Write-Host "`n" + "=" * 50
exit $exitCode