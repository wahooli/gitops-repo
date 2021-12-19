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
    default_image_password  = var.default_user_password
    default_image_username  = var.default_user
    bios                    = "ovmf"
    network_model           = "virtio"
    qemu_os                 = "l26" # for some reason this always defaults to other, whatever the value is
    agent                   = 1 # has qemu-guest-agent
    os_type                 = "cloud-init"
    scsihw                  = "virtio-scsi-single"
    tablet                  = false
    onboot                  = true
    disk_type               = "virtio"
    sshkeys                 = var.ssh_public_keys
    cpu                     = "host"
    cpuflags                = "+pdpe1gb;+aes"
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
    cpu             = "${local.cpu},flags=${local.cpuflags}"
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

    # less ugly than below but, still ugly.
    ipconfig0       = each.value.network[0] == null ? "" : format("%s%s", "ip=${each.value.network[0].cidr}",
        each.value.network[0].gw != null ? ",gw=${each.value.network[0].gw}" : "")

    ipconfig1       = element(each.value.network, 1) != null ? "" : format("%s%s", "ip=${each.value.network[1].cidr}",
        each.value.network[1].gw != null ? ",gw=${each.value.network[1].gw}" : "")

    ipconfig2       = element(each.value.network, 2) != null ? "" : format("%s%s", "ip=${each.value.network[2].cidr}",
         each.value.network[2].gw != null ? ",gw=${each.value.network[2].gw}" : "")

    ipconfig3       = element(each.value.network, 3) != null ? "" : format("%s%s", "ip=${each.value.network[3].cidr}",
        each.value.network[3].gw != null ? ",gw=${each.value.network[3].gw}" : "")
    
    # ugly as hell, but it works lol
    # ipconfig0       = lookup(each.value.network, "0", null) == null ? "" : format("%s%s", 
    #     "ip=${each.value.network["0"]["cidr"]}",
    #     each.value.network["0"]["gw"] != null ? ",gw=${each.value.network["0"]["gw"]}" : "")

    # ipconfig1       = lookup(each.value.network, "1", null) == null ? "" : format("%s%s", 
    #     "ip=${each.value.network["1"]["cidr"]}",
    #     each.value.network["1"]["gw"] != null ? ",gw=${each.value.network["1"]["gw"]}" : "")
    
    # ipconfig2       = lookup(each.value.network, "2", null) == null ? "" : format("%s%s", 
    #     "ip=${each.value.network["2"]["cidr"]}",
    #     each.value.network["2"]["gw"] != null ? ",gw=${each.value.network["2"]["gw"]}" : "")
    
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

    dynamic "network" {
        for_each = toset(each.value.network)
        
        content {
            model   = local.network_model
            bridge  = network.value["bridge"]
            tag     = network.value["vlan"]
        }
    }

    dynamic "disk" {
        for_each = toset(each.value.disk)
        
        content {
            type        = local.disk_type
            storage     = disk.value["storage"]
            size        = disk.value["size"]
            format      = "raw"
            ssd         = local.disk_type != "virtio" ? 1 : 0
            discard     = "on"
        }
    }
    
    lifecycle {
        ignore_changes = [
            network,
            disk.0.format
        ]
    }

    // Clear existing records (if exists) from known_hosts to prevent possible ssh connection issues
    provisioner "local-exec" {
        command = "ssh-keygen -f ~/.ssh/known_hosts -R ${element(split("/", each.value.network[0].cidr), 0)}"
    }
    provisioner "local-exec" {
        command = "ssh-keyscan -H ${element(split("/", each.value.network[0].cidr), 0)} >> ~/.ssh/known_hosts "
    }
    # provisioner "local-exec" {
    #     command = "ssh-keygen -f ~/.ssh/known_hosts -R ${element(split("/", lookup(each.value.network, "0", null).cidr), 0)}"
    # }
    # provisioner "local-exec" {
    #     command = "ssh-keyscan -H ${element(split("/", lookup(each.value.network, "0", null).cidr), 0)} >> ~/.ssh/known_hosts "
    # }

    # provisioner "local-exec" {
    #     command = "ssh-keygen -f ~/.ssh/known_hosts -R ${element(split("/", each.value.net_cidr), 0)}"
    # }
    # provisioner "local-exec" {
    #     command = "ssh-keyscan -H ${element(split("/", each.value.net_cidr), 0)} >> ~/.ssh/known_hosts "
    # }
}
