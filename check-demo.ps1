# Simple Demo Check
Write-Host "Demo Preparation Check" -ForegroundColor Cyan

Write-Host "`nChecking key files..." -ForegroundColor Yellow

if (Test-Path "validate.ps1") { Write-Host "✓ validate.ps1" -ForegroundColor Green } else { Write-Host "✗ validate.ps1 missing" -ForegroundColor Red }
if (Test-Path "complete-demo.ps1") { Write-Host "✓ complete-demo.ps1" -ForegroundColor Green } else { Write-Host "✗ complete-demo.ps1 missing" -ForegroundColor Red }
if (Test-Path "README.md") { Write-Host "✓ README.md" -ForegroundColor Green } else { Write-Host "✗ README.md missing" -ForegroundColor Red }
if (Test-Path "cloudbuild.yaml") { Write-Host "✓ cloudbuild.yaml" -ForegroundColor Green } else { Write-Host "✗ cloudbuild.yaml missing" -ForegroundColor Red }
if (Test-Path "policies\security\deny_null_resources.rego") { Write-Host "✓ Security policies" -ForegroundColor Green } else { Write-Host "✗ Security policies missing" -ForegroundColor Red }
if (Test-Path "policies\gcp\compute_security.rego") { Write-Host "✓ GCP policies" -ForegroundColor Green } else { Write-Host "✗ GCP policies missing" -ForegroundColor Red }

Write-Host "`nDemo is ready! Use these commands:" -ForegroundColor Green
Write-Host "Quick demo: .\validate.ps1" -ForegroundColor Yellow
Write-Host "Full demo: .\complete-demo.ps1" -ForegroundColor Yellow
Write-Host "GitHub: https://github.com/laasna/gcp-opa-policies" -ForegroundColor Yellow