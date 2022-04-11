output "node_user_password" {
    value = local.node_config.user_password
    sensitive = true
}

output "node_ssh_username" {
    value = local.node_config.ssh_username
}

output "ansible_hosts" {
    depends_on = [
        # null_resource.cloud_init_ready,
        time_sleep.wait_after_cloudinit
    ]
    value = {
        "hosts" = {for vm in proxmox_vm_qemu.k3s_agent_node : vm.default_ipv4_address => null}
    }
}

output "ansible_roles" {
    value = local.ansible_roles
}

output "ip_addresses" {
    depends_on = [
        # null_resource.cloud_init_ready,
        time_sleep.wait_after_cloudinit
    ]
    value = [
        for vm in proxmox_vm_qemu.k3s_agent_node : vm.default_ipv4_address
    ]
}

output "hostnames" {
    value = local.hostnames
}