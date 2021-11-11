output "ci_username" {
    value = var.default_user
}

output "ip_addresses" {
    value = [for k,v in var.vm-list : element(split("/", v.net_cidr), 0)]
}