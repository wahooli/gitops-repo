terraform {
    experiments = [module_variable_optional_attrs]
}

locals {
    node_config = defaults(var.node, {
        cpus                = 1
        bridge              = "vmbr0"
        memory_mb           = 2048
        os_disk_storage     = "local"
        os_disk_size        = "15G"
        ssh_username        = "debian"
        name_prefix         = "k3s-agent-"
        nameserver          = "1.1.1.1 1.0.0.1"
    })

    full_clone              = true
    clone                   = "debian-11-cloudinit"
    bios                    = "ovmf"
    network_model           = "virtio"
    qemu_os                 = "l26" # for some reason this always defaults to other, whatever the value is
    agent                   = 1 # has qemu-guest-agent
    os_type                 = "cloud-init"
    scsihw                  = "virtio-scsi-single"
    tablet                  = false
    onboot                  = true
    disk_type               = "virtio"
    cpu                     = "host"
    cpuflags                = "+pdpe1gb;+aes"
    node_id                 = range(1, (var.node_count+1))
    ipconfig0               = {for i, d in var.node_ip_addresses : i => local.node_config.default_gateway != null && local.node_config.default_gateway != "" ? "ip=${d},gw=${local.node_config.default_gateway}" : null}
    macaddr                 = {for i, d in var.node_ip_macaddr : i => d}
    os_disk                 = [{
        type        = local.disk_type
        storage     = local.node_config.os_disk_storage
        size        = local.node_config.os_disk_size
        format      = "raw"
        ssd         = local.disk_type != "virtio" ? 1 : 0
        discard     = "on"
    }]
    disk = (local.node_config.disk_size != null && local.node_config.disk_storage != null && local.node_config.disk_size != "" && local.node_config.disk_storage != "") ? concat(local.os_disk,
    [{
        type        = local.disk_type
        storage     = var.node.disk_storage
        size        = var.node.disk_size
        format      = "raw"
        ssd         = local.disk_type != "virtio" ? 1 : 0
        discard     = "on"
    }]) : local.os_disk

    ansible_roles = compact([
        var.mount_longhorn_disk == true && length(local.disk) > 1 ? "k3s/mount-longhorn-storage" : "",
        "k3s/worker",
    ])

    hostnames = formatlist("${local.node_config.name_prefix}%02s", local.node_id)
}

resource "random_password" "vm_password" {
    length           = 16
    special          = true
    override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "proxmox_vm_qemu" "k3s_agent_node" {
    for_each        = toset(formatlist("%s", local.node_id))
    target_node     = element(var.proxmox_hosts, each.key - 1)
    ciuser          = local.node_config.ssh_username
    cipassword      = random_password.vm_password.result
    onboot          = local.onboot
    tablet          = local.tablet
    agent           = local.agent
    clone           = local.clone
    full_clone      = local.full_clone
    bios            = local.bios
    qemu_os         = local.qemu_os # linux
    searchdomain    = local.node_config.searchdomain
    nameserver      = local.node_config.nameserver
    os_type         = local.os_type
    scsihw          = local.scsihw
    cpu             = "${local.cpu},flags=${local.cpuflags}"
    ipconfig0       = lookup(local.ipconfig0, each.key - 1, null)
    name            = "${format("${local.node_config.name_prefix}%02s", each.key)}"
    vmid            = local.node_config.vmid_start != null && local.node_config.vmid_start != 0 ? (local.node_config.vmid_start + (each.key -1)) : null
    cores           = local.node_config.cpus
    memory          = local.node_config.memory_mb
    sshkeys         = local.node_config.ssh_public_keys
    dynamic "disk" {
        for_each = {for i, d in local.disk : i => d}

        content {
            type        = disk.value["type"]
            storage     = disk.value["storage"]
            size        = disk.value["size"]
            format      = disk.value["format"]
            ssd         = disk.value["ssd"]
            discard     = disk.value["discard"]
        }
    }

    network {
        model = local.network_model
        firewall = false
        mtu = 9000
        bridge = local.node_config.bridge
        macaddr = lookup(local.macaddr, each.key - 1, null)
    }

    serial {
        id          = 0
        type        = "socket"
    }
    vga {
        memory      = 0
        type        = "serial0"
    }

    timeouts {
        create = "60m"
        delete = "5m"
    }

    lifecycle {
        ignore_changes = [
            network,
            disk[0].format,
            disk[1].format
        ]
    }
}