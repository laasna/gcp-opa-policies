package terraform.security

# Deny null resources in production environments
deny[msg] if {
    some i
    input.resource_changes[i].type == "null_resource"
    input.resource_changes[i].change.actions[_] == "create"
    
    msg := sprintf("Null resources are not allowed. Found: %s", [input.resource_changes[i].address])
}