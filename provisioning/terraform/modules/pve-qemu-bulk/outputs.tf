output "ci_username" {
    value = var.default_user
}

output "ip_addresses" {
    value = [for k,v in var.vm-list : element(split("/", v.network["0"]["cidr"]), 0)]
}

output "default_ipv4" {
    value = [
        for vm in proxmox_vm_qemu.pve_qemu_bulk : vm.default_ipv4_address
    ]
}