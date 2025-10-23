package terraform.gcp.network

# CIS GCP Benchmark - Network Security Policies

# Deny overly permissive firewall rules
deny[msg] if {
    some i
    input.resource_changes[i].type == "google_compute_firewall"
    firewall := input.resource_changes[i].change.after
    
    # Check for 0.0.0.0/0 source ranges
    firewall.source_ranges[_] == "0.0.0.0/0"
    
    # Check for dangerous ports
    dangerous_ports := ["22", "3389", "1433", "3306", "5432"]
    firewall.allow[_].ports[_] in dangerous_ports
    
    msg := sprintf("Firewall rule '%s' allows dangerous ports from 0.0.0.0/0", [input.resource_changes[i].address])
}

# Require specific naming convention for VPCs
deny[msg] if {
    some i
    input.resource_changes[i].type == "google_compute_network"
    network := input.resource_changes[i].change.after
    
    # VPC names must follow pattern: {env}-{purpose}-{suffix}
    not regex.match("^(dev|staging|prod)-[a-z0-9-]+-[a-z0-9]+$", network.name)
    
    msg := sprintf("VPC network '%s' name must follow pattern: {env}-{purpose}-{suffix}", [input.resource_changes[i].address])
}

# Require private Google access for subnets
deny[msg] if {
    some i
    input.resource_changes[i].type == "google_compute_subnetwork"
    subnet := input.resource_changes[i].change.after
    
    not subnet.private_ip_google_access == true
    
    msg := sprintf("Subnet '%s' must have private Google access enabled", [input.resource_changes[i].address])
}

# Deny default VPC usage
deny[msg] if {
    some i
    input.resource_changes[i].type == "google_compute_network"
    network := input.resource_changes[i].change.after
    
    network.name == "default"
    
    msg := sprintf("Default VPC network usage is not allowed: '%s'", [input.resource_changes[i].address])
}

# Require proper subnet CIDR ranges
deny[msg] if {
    some i
    input.resource_changes[i].type == "google_compute_subnetwork"
    subnet := input.resource_changes[i].change.after
    
    # Ensure private IP ranges are used
    not regex.match("^(10\\.|172\\.(1[6-9]|2[0-9]|3[01])\\.|192\\.168\\.)", subnet.ip_cidr_range)
    
    msg := sprintf("Subnet '%s' must use private IP ranges (10.x.x.x, 172.16-31.x.x, or 192.168.x.x)", [input.resource_changes[i].address])
}