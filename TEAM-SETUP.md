# 👥 Team Collaboration Setup

## Option 1: Add Collaborator (Easiest)

### Steps for Laasna:
1. Go to: https://github.com/laasna/gcp-opa-policies
2. Click "Settings" → "Collaborators"
3. Click "Add people"
4. Enter Sanjana's GitHub username
5. Select "Write" permission
6. Send invitation

### Steps for Sanjana:
1. Accept email invitation from GitHub
2. Clone the repository:
   ```bash
   git clone https://github.com/laasna/gcp-opa-policies.git
   cd gcp-opa-policies
   ```
3. Start working and pushing changes directly

## Option 2: Fork Repository

### Steps for Sanjana:
1. Go to: https://github.com/laasna/gcp-opa-policies
2. Click "Fork" button (top right)
3. Clone your fork:
   ```bash
   git clone https://github.com/sanjana/gcp-opa-policies.git
   cd gcp-opa-policies
   ```
4. Add original as upstream:
   ```bash
   git remote add upstream https://github.com/laasna/gcp-opa-policies.git
   ```

## Option 3: Organization Repository

### Create Organization:
1. Go to: https://github.com/organizations/new
2. Create organization (e.g., "your-team-name")
3. Transfer repository to organization
4. Add both Laasna and Sanjana as members

## Recommended Workflow

### For Collaborative Development:
```bash
# Sanjana's workflow after getting access:

# 1. Clone the repository
git clone https://github.com/laasna/gcp-opa-policies.git
cd gcp-opa-policies

# 2. Create feature branch
git checkout -b sanjana/new-feature

# 3. Make changes
# ... edit files ...

# 4. Commit and push
git add .
git commit -m "Add new feature"
git push origin sanjana/new-feature

# 5. Create Pull Request on GitHub
```

## Team Demo Preparation

### Both team members can:
1. **Clone the repository**
2. **Run the demo locally:**
   ```powershell
   .\validate.ps1
   .\complete-demo.ps1
   ```
3. **Present together** using the demo guide
4. **Show collaborative development** workflow

## Sharing Project Files

### If Sanjana needs files immediately:

#### Option A: Download ZIP
1. Go to: https://github.com/laasna/gcp-opa-policies
2. Click "Code" → "Download ZIP"
3. Extract and use locally

#### Option B: Email/Slack
- Share the GitHub repository link
- Share specific files if needed
- Share demo commands and instructions

## Demo Coordination

### Suggested Team Demo Flow:
1. **Laasna**: Introduce the project and problem
2. **Sanjana**: Demonstrate policy validation
3. **Laasna**: Show Cloud Build integration
4. **Sanjana**: Explain business value
5. **Both**: Answer questions and discuss implementation

### Demo Commands for Both:
```powershell
# Quick validation demo
.\validate.ps1

# Show policy files
Get-Content policies\security\deny_null_resources.rego
Get-Content policies\gcp\compute_security.rego

# Show infrastructure
Get-Content main.tf
Get-Content infrastructure\gcp-sample.tf

# Show CI/CD pipeline
Get-Content cloudbuild.yaml
```