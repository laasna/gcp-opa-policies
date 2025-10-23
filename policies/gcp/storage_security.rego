package terraform.gcp.storage

# CIS GCP Benchmark - Cloud Storage Security Policies

# Deny public buckets
deny[msg] if {
    some i
    input.resource_changes[i].type == "google_storage_bucket"
    bucket := input.resource_changes[i].change.after
    
    # Check for public access prevention
    not bucket.public_access_prevention == "enforced"
    
    msg := sprintf("Storage bucket '%s' must have public access prevention enforced", [input.resource_changes[i].address])
}

# Require uniform bucket-level access
deny[msg] if {
    some i
    input.resource_changes[i].type == "google_storage_bucket"
    bucket := input.resource_changes[i].change.after
    
    some j
    access_config := bucket.uniform_bucket_level_access[j]
    not access_config.enabled == true
    
    msg := sprintf("Storage bucket '%s' must have uniform bucket-level access enabled", [input.resource_changes[i].address])
}

# Require versioning for production buckets
deny[msg] if {
    some i
    input.resource_changes[i].type == "google_storage_bucket"
    bucket := input.resource_changes[i].change.after
    
    # Check if production bucket
    bucket.labels.environment == "prod"
    some j
    versioning_config := bucket.versioning[j]
    not versioning_config.enabled == true
    
    msg := sprintf("Production storage bucket '%s' must have versioning enabled", [input.resource_changes[i].address])
}

# Deny public IAM bindings
deny[msg] if {
    some i
    input.resource_changes[i].type == "google_storage_bucket_iam_binding"
    binding := input.resource_changes[i].change.after
    
    # Check for public members
    public_members := ["allUsers", "allAuthenticatedUsers"]
    binding.members[_] in public_members
    
    msg := sprintf("Storage bucket IAM binding '%s' contains public members", [input.resource_changes[i].address])
}