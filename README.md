# 🛡️ GCP OPA Policy Validation System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OPA](https://img.shields.io/badge/OPA-Policy%20Engine-blue)](https://www.openpolicyagent.org/)
[![GCP](https://img.shields.io/badge/GCP-Cloud%20Platform-red)](https://cloud.google.com/)

Automated infrastructure pipeline that validates Terraform code against Open Policy Agent (OPA) policies for Google Cloud Platform, preventing non-compliant deployments from reaching production.

## 🎯 Features

- ✅ **Automated Policy Validation** - Blocks non-compliant Terraform deployments
- ✅ **GCP Security Policies** - Based on CIS GCP Benchmark standards  
- ✅ **Cloud Build Integration** - Ready-to-use CI/CD pipeline
- ✅ **Clear Feedback** - Detailed violation messages with remediation guidance
- ✅ **Multi-Environment Support** - Different rules for dev/staging/prod

## 🚀 Quick Start

### Prerequisites
- Terraform installed
- OPA binary (included in repo)
- PowerShell (for Windows) or Bash (for Linux/Mac)

### Test the System
```powershell
# Clone this repository
git clone https://github.com/laasna/gcp-opa-policies.git
cd gcp-opa-policies

# Run validation on sample infrastructure
.\validate.ps1
```

Expected output:
```
=== GCP OPA Policy Validation ===
Testing Security Policies...
POLICY VIOLATIONS FOUND:
  - Null resources are not allowed. Found: null_resource.demo
DEPLOYMENT BLOCKED!
```

## 📁 Project Structure

```
├── policies/                   # OPA Policy Library
│   ├── security/              # General security policies
│   │   └── deny_null_resources.rego
│   └── gcp/                   # GCP-specific policies
│       ├── compute_security.rego
│       └── storage_security.rego
├── infrastructure/            # Sample GCP Terraform code
│   └── gcp-sample.tf
├── cloudbuild.yaml           # Google Cloud Build pipeline
├── validate.ps1              # Quick validation script
└── README.md
```

## 🔧 Policy Categories

### Security Policies
- **Null Resources**: Blocks null resources in all environments
- **Resource Naming**: Enforces naming conventions
- **Environment Tagging**: Requires proper environment labels

### GCP Compute Policies
- **Public IP Restrictions**: No public IPs in production
- **Machine Type Controls**: Approved instance types only
- **Disk Encryption**: Mandatory encryption for all disks

### GCP Storage Policies
- **Public Access Prevention**: Enforced on all buckets
- **Uniform Bucket Access**: Required for security
- **Versioning**: Mandatory for production buckets
- **IAM Controls**: No public IAM bindings

## 🏗️ Cloud Build Integration

### Setup Cloud Build Trigger
```bash
gcloud builds triggers create github \
  --repo-name="gcp-opa-policies" \
  --repo-owner="laasna" \
  --branch-pattern="^main$" \
  --build-config="cloudbuild.yaml"
```

### Pipeline Stages
1. **Terraform Init & Plan** - Generate infrastructure plan
2. **OPA Policy Validation** - Run all security checks
3. **Report Generation** - Create detailed validation report
4. **Conditional Deploy** - Apply only if all policies pass

## 🧪 Testing

### Manual Testing
```powershell
# Test individual policies
.\opa.exe eval -d policies -i tfplan.json "data.terraform.security.deny"

# Test GCP compute policies
.\opa.exe eval -d policies -i infrastructure\tfplan.json "data.terraform.gcp.compute.deny"
```

### Adding New Policies
1. Create new `.rego` file in appropriate directory
2. Follow package naming: `terraform.{category}.{subcategory}`
3. Test with sample infrastructure
4. Update validation scripts

## 📊 Example Policy Violations

### ❌ Blocked Deployment
```
POLICY VIOLATIONS FOUND:
  - GCE instance 'google_compute_instance.web' has public IP in production environment
  - Storage bucket 'google_storage_bucket.data' must have public access prevention enforced
DEPLOYMENT BLOCKED!
```

### ✅ Approved Deployment
```
All GCP policies passed!
Infrastructure is compliant and ready for deployment.
```

## 🔐 Security Best Practices

- **Policy as Code**: All policies version controlled
- **Least Privilege**: Minimal required permissions
- **Audit Trail**: All policy decisions logged
- **Regular Updates**: Policies updated with new threats

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-policy`)
3. Add your policy with tests
4. Commit changes (`git commit -am 'Add new GCP policy'`)
5. Push to branch (`git push origin feature/new-policy`)
6. Create Pull Request

## 📈 Roadmap

- [ ] Additional GCP resource policies (Cloud SQL, GKE, etc.)
- [ ] Policy testing framework
- [ ] Slack/Teams integration for notifications
- [ ] Policy exception workflow
- [ ] Advanced reporting dashboard

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.txt) file for details.

## 🆘 Support

- Create an [Issue](https://github.com/laasna/gcp-opa-policies/issues) for bug reports
- Start a [Discussion](https://github.com/laasna/gcp-opa-policies/discussions) for questions
- Check [Wiki](https://github.com/laasna/gcp-opa-policies/wiki) for detailed documentation

---

**Built with ❤️ for secure GCP infrastructure**