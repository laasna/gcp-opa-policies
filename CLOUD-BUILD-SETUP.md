# 🚀 Cloud Build Setup Guide

## Prerequisites
- GCP Project: `laasna`
- Billing enabled on the project
- GitHub repository: `laasna/gcp-opa-policies`

## Step-by-Step Setup

### 1. Enable Billing (Required)
1. Go to [GCP Billing Console](https://console.cloud.google.com/billing/projects)
2. Select project "laasna"
3. Link to a billing account (Free tier available)

### 2. Enable APIs
```bash
gcloud config set project laasna
gcloud services enable cloudbuild.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable storage.googleapis.com
```

### 3. Set Up Cloud Build Trigger
1. Go to [Cloud Build Triggers](https://console.cloud.google.com/cloud-build/triggers?project=laasna)
2. Click "Connect Repository"
3. Select "GitHub (Cloud Build GitHub App)"
4. Authenticate with GitHub
5. Select repository: `laasna/gcp-opa-policies`
6. Create trigger with these settings:
   - **Name:** `opa-policy-validation`
   - **Event:** Push to a branch
   - **Branch:** `^main$`
   - **Configuration:** Cloud Build configuration file
   - **Location:** Repository - `cloudbuild.yaml`

### 4. Grant Permissions
```bash
PROJECT_NUMBER=$(gcloud projects describe laasna --format="value(projectNumber)")
gcloud projects add-iam-policy-binding laasna \
  --member="serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
  --role="roles/compute.admin"
```

### 5. Test the Pipeline
```bash
# Make a small change and push
echo "# Test change" >> README.md
git add README.md
git commit -m "Test Cloud Build trigger"
git push
```

## Expected Results

### ✅ Successful Build
- All OPA policies pass
- Build completes successfully
- Detailed policy report generated

### ❌ Failed Build (Policy Violations)
- Build fails at policy validation step
- Clear error messages show violations
- Deployment blocked automatically

## Monitoring

### View Build History
- [Cloud Build History](https://console.cloud.google.com/cloud-build/builds?project=laasna)

### View Build Logs
- Click on any build to see detailed logs
- Policy validation results shown clearly
- Error messages guide remediation

## Production Considerations

### Security
- Use least-privilege service accounts
- Store sensitive variables in Secret Manager
- Enable audit logging

### Performance
- Build typically takes 2-3 minutes
- Parallel policy validation
- Cached dependencies for faster builds

### Scaling
- Multiple environments (dev/staging/prod)
- Branch-specific policies
- Automated notifications (Slack/Teams)

## Troubleshooting

### Common Issues
1. **Billing not enabled:** Enable billing in GCP Console
2. **API not enabled:** Run `gcloud services enable` commands
3. **Permission denied:** Check service account permissions
4. **GitHub connection:** Re-authenticate GitHub App

### Support
- Check [Cloud Build Documentation](https://cloud.google.com/build/docs)
- Review build logs for specific errors
- Test policies locally first with `.\validate.ps1`