terraform { 
	required_providers {
		proxmox = {
			source = "telmate/proxmox"
			version = ">=2.9.0"
		}
	}
	required_version = ">= 1.0.0"
	experiments = [module_variable_optional_attrs]
}

locals {
	full_clone              = true
	nameserver              = "10.0.0.1 10.0.1.1"
	searchdomain            = "absolutist.it"
	clone                   = var.clone_from
	default_image_password  = var.default_user
	default_image_username  = var.default_user_password
    bios                    = "ovmf"
    qemu_os                 = "l26" # for some reason this always defaults to other, whatever the value is
    agent                   = 1 # has qemu-guest-agent
    os_type                 = "cloud-init"
    scsihw                  = "virtio-scsi-single"
    tablet                  = false
    onboot                  = true
    disk_type               = "virtio"
    sshkeys                 = var.ssh_public_keys
}

resource "proxmox_vm_qemu" "pve-qemu-bulk" {
    onboot          = local.onboot
    tablet          = local.tablet
    agent           = local.agent
    clone           = local.clone
    full_clone      = local.full_clone 
    bios            = local.bios
    qemu_os         = local.qemu_os # linux
   	ciuser          = local.default_image_username
	cipassword      = local.default_image_password
    searchdomain    = local.searchdomain
    nameserver      = local.nameserver
    os_type         = local.os_type
    scsihw          = local.scsihw 

    timeouts {
        create = "60m"
        delete = "5m"
    }
    for_each = var.vm-list

    name            = each.key
    boot            = "order=${local.disk_type}0;ide2;net0"
    bootdisk        = "${local.disk_type}0"
    vmid            = each.value.id

    target_node     = each.value.target_node

    cores           = each.value.cores
    memory          = each.value.memory
    desc            = each.value.desc
    ipconfig0       = "ip=${each.value.net_cidr},gw=${each.value.net_gw}"
    ipconfig1       = "ip=${each.value.storage_cidr}"
    sshkeys         = local.sshkeys
    # define_connection_info = true
    # default_ipv4_address = element(split("/", each.value.net_cidr), 0)
    # ssh_host = element(split("/", each.value.net_cidr), 0)
    # ssh_port = 22

    serial {
        id          = 0
        type        = "socket"
    }
    vga {
        memory      = 0
        type        = "serial0"
    }
    network {
        model       = "virtio"
        bridge      = each.value.net_bridge
        tag         = each.value.net_vlan
    }
    network {
        model       = "virtio"
        bridge      = each.value.storage_bridge
        tag         = each.value.storage_vlan
    }
    disk {
        type        = local.disk_type
        storage     = each.value.disk_storage
        size        = each.value.disk_size
        format      = "raw"
        ssd         = local.disk_type != "virtio" ? 1 : 0
        discard     = "on"
    }
    
    lifecycle {
		ignore_changes = [
			network
		]
	}

    // Clear existing records (if exists) from known_hosts to prevent possible ssh connection issues
    provisioner "local-exec" {
        command = "ssh-keygen -f ~/.ssh/known_hosts -R ${element(split("/", each.value.net_cidr), 0)}"
    }

}
