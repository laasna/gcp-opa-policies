# Setup Cloud Build for GCP OPA Policy Validation
param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectId,
    
    [string]$Region = "us-central1"
)

Write-Host "🚀 Setting up Cloud Build for OPA Policy Validation" -ForegroundColor Cyan
Write-Host "Project ID: $ProjectId" -ForegroundColor Yellow

# Step 1: Set the project
Write-Host "`n1. Setting GCP project..." -ForegroundColor Green
gcloud config set project $ProjectId

# Step 2: Enable required APIs
Write-Host "`n2. Enabling required APIs..." -ForegroundColor Green
gcloud services enable cloudbuild.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable storage.googleapis.com

# Step 3: Grant Cloud Build permissions
Write-Host "`n3. Granting Cloud Build permissions..." -ForegroundColor Green
$projectNumber = gcloud projects describe $ProjectId --format="value(projectNumber)"
gcloud projects add-iam-policy-binding $ProjectId --member="serviceAccount:$projectNumber@cloudbuild.gserviceaccount.com" --role="roles/compute.admin"
gcloud projects add-iam-policy-binding $ProjectId --member="serviceAccount:$projectNumber@cloudbuild.gserviceaccount.com" --role="roles/storage.admin"

# Step 4: Connect to GitHub repository
Write-Host "`n4. Setting up GitHub connection..." -ForegroundColor Green
Write-Host "Please follow these steps in the GCP Console:" -ForegroundColor Yellow
Write-Host "1. Go to: https://console.cloud.google.com/cloud-build/triggers?project=$ProjectId"
Write-Host "2. Click 'Connect Repository'"
Write-Host "3. Select 'GitHub (Cloud Build GitHub App)'"
Write-Host "4. Authenticate and select repository: laasna/gcp-opa-policies"
Write-Host "5. Create a trigger with these settings:"
Write-Host "   - Name: opa-policy-validation"
Write-Host "   - Event: Push to a branch"
Write-Host "   - Branch: ^main$"
Write-Host "   - Configuration: Cloud Build configuration file (yaml or json)"
Write-Host "   - Location: Repository - cloudbuild.yaml"

Write-Host "`n✅ Setup complete!" -ForegroundColor Green
Write-Host "Your Cloud Build pipeline is ready to validate OPA policies!" -ForegroundColor Cyan