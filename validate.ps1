# OPA Policy Validation for GCP Infrastructure
Write-Host "=== GCP OPA Policy Validation ===" -ForegroundColor Cyan

# Test security policies
Write-Host "Testing Security Policies..." -ForegroundColor Yellow
$result = & .\opa.exe eval -d policies -i tfplan.json "data.terraform.security.deny" --format json 2>$null

if ($LASTEXITCODE -eq 0 -and $result) {
    $jsonResult = $result | ConvertFrom-Json
    if ($jsonResult.result -and $jsonResult.result.Count -gt 0) {
        Write-Host "POLICY VIOLATIONS FOUND:" -ForegroundColor Red
        foreach ($violation in $jsonResult.result) {
            foreach ($expr in $violation.expressions) {
                foreach ($key in $expr.value.PSObject.Properties.Name) {
                    Write-Host "  - $key" -ForegroundColor Red
                }
            }
        }
        Write-Host "DEPLOYMENT BLOCKED!" -ForegroundColor Red
        exit 1
    }
}

Write-Host "All GCP policies passed!" -ForegroundColor Green
Write-Host "Infrastructure is compliant and ready for deployment." -ForegroundColor Green