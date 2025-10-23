package terraform.gcp.compute

# CIS GCP Benchmark - Compute Engine Security Policies

# Deny GCE instances with public IPs in production
deny[msg] if {
    some i
    input.resource_changes[i].type == "google_compute_instance"
    instance := input.resource_changes[i].change.after
    
    # Check if this is production environment
    instance.tags.environment == "prod"
    
    # Check for public IP access config
    some j
    instance.network_interface[j].access_config
    
    msg := sprintf("GCE instance '%s' has public IP in production environment", [input.resource_changes[i].address])
}

# Require specific machine types for production
deny[msg] if {
    some i
    input.resource_changes[i].type == "google_compute_instance"
    instance := input.resource_changes[i].change.after
    
    # Check if this is production
    instance.tags.environment == "prod"
    
    # Only allow specific machine types in prod
    allowed_types := ["e2-standard-2", "e2-standard-4", "n2-standard-2", "n2-standard-4"]
    not instance.machine_type in allowed_types
    
    msg := sprintf("GCE instance '%s' uses disallowed machine type '%s' in production", [
        input.resource_changes[i].address, 
        instance.machine_type
    ])
}

# Require disk encryption
deny[msg] if {
    some i
    input.resource_changes[i].type == "google_compute_instance"
    instance := input.resource_changes[i].change.after
    
    # Check boot disk encryption
    some j
    boot_disk := instance.boot_disk[j]
    not boot_disk.disk_encryption_key_raw
    not boot_disk.kms_key_self_link
    
    msg := sprintf("GCE instance '%s' boot disk must be encrypted", [input.resource_changes[i].address])
}