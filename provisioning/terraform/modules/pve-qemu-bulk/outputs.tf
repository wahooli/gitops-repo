output "ci_username" {
    value = var.default_user
}

output "ip_addresses" {
    value = [for k,v in var.vm-list : element(split("/", v.network["0"]["cidr"]), 0)]
}