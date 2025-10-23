# OPA Policy Validation for GCP Infrastructure
Write-Host "=== GCP OPA Policy Validation ===" -ForegroundColor Cyan

# Test all policy categories
$policies = @(
    @{Name="Security"; Package="terraform.security"},
    @{Name="GCP Compute"; Package="terraform.gcp.compute"},
    @{Name="GCP Storage"; Package="terraform.gcp.storage"},
    @{Name="GCP Network"; Package="terraform.gcp.network"},
    @{Name="GCP IAM"; Package="terraform.gcp.iam"}
)

$violations = @()

foreach ($policy in $policies) {
    Write-Host "Testing $($policy.Name) Policies..." -ForegroundColor Yellow
    $result = & .\opa.exe eval -d policies -i tfplan.json "data.$($policy.Package).deny" --format json 2>$null
    
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
        }
    }
}

if ($violations.Count -gt 0) {
    Write-Host "`nPOLICY VIOLATIONS FOUND:" -ForegroundColor Red
    foreach ($violation in $violations) {
        Write-Host "  - $violation" -ForegroundColor Red
    }
    Write-Host "`nDEPLOYMENT BLOCKED!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`nAll GCP policies passed!" -ForegroundColor Green
    Write-Host "Infrastructure is compliant and ready for deployment." -ForegroundColor Green
}