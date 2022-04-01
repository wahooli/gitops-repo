output "node_ssh_password" {
    value = random_password.vm_password.result
    sensitive = true
}

output "node_ssh_username" {
    value = local.node_config.ssh_username
}

output "ansible_hosts" {
    value = {
        "hosts" = {for vm in proxmox_vm_qemu.k3s_agent_node : vm.default_ipv4_address => null}
    }
}

output "ansible_roles" {
    value = local.ansible_roles
}

output "ip_addresses" {
    value = [
        for vm in proxmox_vm_qemu.k3s_agent_node : vm.default_ipv4_address
    ]
}

output "hostnames" {
    value = local.hostnames
}