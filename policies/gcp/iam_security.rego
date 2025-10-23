package terraform.gcp.iam

# CIS GCP Benchmark - IAM Security Policies

# Deny overly permissive service account roles
deny[msg] if {
    some i
    input.resource_changes[i].type == "google_project_iam_binding"
    binding := input.resource_changes[i].change.after
    
    # Dangerous roles that should not be assigned broadly
    dangerous_roles := [
        "roles/owner",
        "roles/editor", 
        "roles/iam.securityAdmin",
        "roles/iam.serviceAccountAdmin",
        "roles/resourcemanager.projectIamAdmin"
    ]
    
    binding.role in dangerous_roles
    count(binding.members) > 2
    
    msg := sprintf("IAM binding '%s' assigns dangerous role '%s' to too many members (%d)", [
        input.resource_changes[i].address,
        binding.role,
        count(binding.members)
    ])
}

# Deny service accounts without proper naming
deny[msg] if {
    some i
    input.resource_changes[i].type == "google_service_account"
    sa := input.resource_changes[i].change.after
    
    # Service accounts must follow naming pattern: {env}-{purpose}-sa-{suffix}
    not regex.match("^(dev|staging|prod)-[a-z0-9-]+-sa-[a-z0-9]+$", sa.account_id)
    
    msg := sprintf("Service account '%s' must follow naming pattern: {env}-{purpose}-sa-{suffix}", [input.resource_changes[i].address])
}

# Require service account descriptions
deny[msg] if {
    some i
    input.resource_changes[i].type == "google_service_account"
    sa := input.resource_changes[i].change.after
    
    not sa.description
    
    msg := sprintf("Service account '%s' must have a description", [input.resource_changes[i].address])
}

# Deny primitive roles in production
deny[msg] if {
    some i
    input.resource_changes[i].type == "google_project_iam_binding"
    binding := input.resource_changes[i].change.after
    
    # Check if any member has environment tag indicating production
    primitive_roles := ["roles/owner", "roles/editor", "roles/viewer"]
    binding.role in primitive_roles
    
    # This is a simplified check - in real scenarios you'd check project labels or other indicators
    contains(binding.role, "owner")
    
    msg := sprintf("Primitive role '%s' should not be used in production environments", [binding.role])
}

# Deny service account keys (prefer workload identity)
deny[msg] if {
    some i
    input.resource_changes[i].type == "google_service_account_key"
    
    msg := sprintf("Service account keys are discouraged. Use Workload Identity instead: '%s'", [input.resource_changes[i].address])
}

# Require least privilege for compute service accounts
deny[msg] if {
    some i
    input.resource_changes[i].type == "google_compute_instance"
    instance := input.resource_changes[i].change.after
    
    # Check service account scopes
    some j
    sa_config := instance.service_account[j]
    "https://www.googleapis.com/auth/cloud-platform" in sa_config.scopes
    
    msg := sprintf("Compute instance '%s' uses overly broad 'cloud-platform' scope. Use specific scopes instead", [input.resource_changes[i].address])
}