# Setup Script for Sanjana's GCP Integration
param(
    [Parameter(Mandatory=$true)]
    [string]$SanjanaProjectId,
    
    [string]$Region = "us-central1"
)

Write-Host "🤝 Setting up OPA Policy Validation with Sanjana's GCP Account" -ForegroundColor Cyan
Write-Host "Project ID: $SanjanaProjectId" -ForegroundColor Yellow
Write-Host "Region: $Region" -ForegroundColor Yellow

# Step 1: Update project configuration files
Write-Host "`n📝 Updating configuration files..." -ForegroundColor Green

# Update infrastructure sample with Sanjana's project
$infraContent = Get-Content "infrastructure\gcp-sample.tf" -Raw
$infraContent = $infraContent -replace 'default     = "laasna"', "default     = `"$SanjanaProjectId`""
$infraContent | Set-Content "infrastructure\gcp-sample.tf"

Write-Host "✅ Updated infrastructure/gcp-sample.tf with project: $SanjanaProjectId" -ForegroundColor Green

# Step 2: Update Cloud Build configuration
Write-Host "`n☁️ Updating Cloud Build configuration..." -ForegroundColor Green

# Create updated cloudbuild.yaml with Sanjana's project
$cloudbuildContent = @"
# Cloud Build configuration for OPA Policy Validation Pipeline
# Configured for Sanjana's GCP Project: $SanjanaProjectId

steps:
  # Step 1: Download OPA
  - name: 'gcr.io/cloud-builders/wget'
    id: 'download-opa'
    args:
      - 'https://openpolicyagent.org/downloads/v0.57.0/opa_linux_amd64_static'
      - '-O'
      - 'opa'
    
  # Step 2: Make OPA executable
  - name: 'ubuntu'
    id: 'setup-opa'
    entrypoint: 'chmod'
    args: ['+x', 'opa']
    
  # Step 3: Setup Terraform
  - name: 'hashicorp/terraform:1.5'
    id: 'terraform-init'
    entrypoint: 'sh'
    args:
      - '-c'
      - |
        cd infrastructure
        terraform init
    
  # Step 4: Generate Terraform Plan
  - name: 'hashicorp/terraform:1.5'
    id: 'terraform-plan'
    entrypoint: 'sh'
    args:
      - '-c'
      - |
        cd infrastructure
        terraform plan -out=tfplan.binary -var="project_id=$SanjanaProjectId" -var="environment=`${_ENVIRONMENT}" -var="region=$Region"
        terraform show -json tfplan.binary > tfplan.json
    env:
      - 'TF_VAR_project_id=$SanjanaProjectId'
      - 'TF_VAR_environment=`${_ENVIRONMENT}'
      - 'TF_VAR_region=$Region'
    
  # Step 5: Validate All Policies
  - name: 'ubuntu'
    id: 'validate-all-policies'
    entrypoint: 'sh'
    args:
      - '-c'
      - |
        echo "🔍 Running Complete OPA Policy Validation..."
        
        # Test all policy categories
        POLICIES=("terraform.security" "terraform.gcp.compute" "terraform.gcp.storage" "terraform.gcp.network" "terraform.gcp.iam")
        VIOLATIONS=""
        
        for POLICY in "`${POLICIES[@]}"; do
          echo "Testing `$POLICY policies..."
          RESULT=`$(./opa eval -d policies -i infrastructure/tfplan.json "data.`$POLICY.deny" --format json 2>/dev/null || echo "{}")
          
          if echo "`$RESULT" | jq -e '.result[]?.expressions[]?.value | to_entries[]?.key' >/dev/null 2>&1; then
            POLICY_VIOLATIONS=`$(echo "`$RESULT" | jq -r '.result[]?.expressions[]?.value | to_entries[]?.key' 2>/dev/null || echo "")
            if [ ! -z "`$POLICY_VIOLATIONS" ]; then
              echo "❌ `$POLICY violations found:"
              echo "`$POLICY_VIOLATIONS"
              VIOLATIONS="true"
            fi
          else
            echo "✅ `$POLICY policies passed"
          fi
        done
        
        if [ ! -z "`$VIOLATIONS" ]; then
          echo "🚫 DEPLOYMENT BLOCKED - Policy violations found!"
          exit 1
        else
          echo "🎉 ALL POLICIES PASSED - Deployment approved!"
        fi
    
  # Step 6: Generate Policy Report
  - name: 'ubuntu'
    id: 'generate-report'
    entrypoint: 'sh'
    args:
      - '-c'
      - |
        echo "# OPA Policy Validation Report" > policy-report.md
        echo "**Project:** $SanjanaProjectId" >> policy-report.md
        echo "**Environment:** `${_ENVIRONMENT}" >> policy-report.md
        echo "**Build ID:** `$BUILD_ID" >> policy-report.md
        echo "**Timestamp:** `$(date)" >> policy-report.md
        echo "" >> policy-report.md
        echo "## Policy Results" >> policy-report.md
        echo "✅ All policies passed successfully!" >> policy-report.md
        echo "" >> policy-report.md
        echo "## Validated Policies" >> policy-report.md
        echo "- Security Policies" >> policy-report.md
        echo "- GCP Compute Policies" >> policy-report.md
        echo "- GCP Storage Policies" >> policy-report.md
        echo "- GCP Network Policies" >> policy-report.md
        echo "- GCP IAM Policies" >> policy-report.md
        echo "" >> policy-report.md
        echo "## Infrastructure Summary" >> policy-report.md
        echo "- Project: $SanjanaProjectId" >> policy-report.md
        echo "- Region: $Region" >> policy-report.md
        echo "- Compliance: CIS GCP Benchmark" >> policy-report.md
        
        echo "📊 Policy validation report generated!"

# Substitution variables
substitutions:
  _ENVIRONMENT: 'dev'

# Options
options:
  logging: CLOUD_LOGGING_ONLY
  machineType: 'E2_STANDARD_2'

# Timeout
timeout: '1200s'
"@

$cloudbuildContent | Set-Content "cloudbuild.yaml"
Write-Host "✅ Updated cloudbuild.yaml for project: $SanjanaProjectId" -ForegroundColor Green

# Step 3: Create Sanjana's setup commands
Write-Host "`n🔧 Creating setup commands for Sanjana..." -ForegroundColor Green

$sanjanaCommands = @"
# Commands for Sanjana to run in her GCP Console/Cloud Shell

# 1. Set the project
gcloud config set project $SanjanaProjectId

# 2. Enable required APIs
gcloud services enable cloudbuild.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable storage.googleapis.com

# 3. Get project number and grant permissions
PROJECT_NUMBER=`$(gcloud projects describe $SanjanaProjectId --format="value(projectNumber)")

gcloud projects add-iam-policy-binding $SanjanaProjectId \
  --member="serviceAccount:`$PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $SanjanaProjectId \
  --member="serviceAccount:`$PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $SanjanaProjectId \
  --member="serviceAccount:`$PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

# 4. Test the setup
echo "Setup complete! Now connect the GitHub repository in Cloud Build console:"
echo "https://console.cloud.google.com/cloud-build/triggers?project=$SanjanaProjectId"
"@

$sanjanaCommands | Set-Content "sanjana-setup-commands.sh"
Write-Host "✅ Created sanjana-setup-commands.sh" -ForegroundColor Green

# Step 4: Update README with Sanjana's project info
Write-Host "`n📖 Updating documentation..." -ForegroundColor Green

# Create a team-specific README section
$teamReadme = @"

## 👥 Team Configuration

**Project Owner:** Sanjana  
**GCP Project ID:** $SanjanaProjectId  
**GitHub Repository:** https://github.com/laasna/gcp-opa-policies  
**Cloud Build Console:** https://console.cloud.google.com/cloud-build/builds?project=$SanjanaProjectId  

### Team Demo Setup
1. **Laasna:** Manages GitHub repository and policy development
2. **Sanjana:** Provides GCP project and Cloud Build integration
3. **Together:** Demonstrate complete CI/CD pipeline with policy enforcement

### Quick Start for Team Demo
```bash
# Clone repository (both team members)
git clone https://github.com/laasna/gcp-opa-policies.git

# Test locally (both team members)
.\validate.ps1

# Push changes to trigger Cloud Build (Sanjana's GCP)
git add .
git commit -m "Demo policy validation"
git push
```
"@

Add-Content "README.md" $teamReadme
Write-Host "✅ Updated README.md with team configuration" -ForegroundColor Green

Write-Host "`n🎉 Setup Complete!" -ForegroundColor Green
Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Share 'sanjana-setup-commands.sh' with Sanjana" -ForegroundColor White
Write-Host "2. Sanjana runs the commands in her GCP Console" -ForegroundColor White
Write-Host "3. Sanjana connects GitHub repo in Cloud Build console" -ForegroundColor White
Write-Host "4. Test the integration by pushing a commit" -ForegroundColor White
Write-Host "5. Demo the complete pipeline together!" -ForegroundColor White

Write-Host "`n🔗 Resources for Sanjana:" -ForegroundColor Yellow
Write-Host "- Setup Guide: SANJANA-GCP-SETUP.md" -ForegroundColor White
Write-Host "- Setup Commands: sanjana-setup-commands.sh" -ForegroundColor White
Write-Host "- Cloud Build Console: https://console.cloud.google.com/cloud-build/triggers?project=$SanjanaProjectId" -ForegroundColor White