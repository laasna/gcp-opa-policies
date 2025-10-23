package terraformdeny

deny if {
    some i
    input.resource_changes[i].type == "null_resource"
    input.resource_changes[i].change.actions[_] == "create"
}
