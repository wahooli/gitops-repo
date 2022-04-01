terraform {
    experiments = [module_variable_optional_attrs]
}

locals {
    # calico = defaults(var.calico, {
    #     encapsulation       = "None"
    #     calicoctl_version   = "v3.21.2"
    #     node_cidr           = "10.0.0.0/24"
    #     bgp                 = {
    #         enabled         = true
    #         node_selector   = "has(router-peer)"
    #         external_ips    = "10.3.0.0/24"
    #         peer_ip         = "172.16.0.4"
    #         peer_as         = "65536"
    #         node_as         = "65537"
    #     }
    # })
    # metallb = defaults(var.metallb, {
    #     enabled             = true
    #     target_namespace    = "metallb-system"
    #     protocol            = "bgp"
    #     addresses           = "10.4.0.2-10.4.0.254"
    #     speaker             = {
    #         enabled         = false
    #         frr             = {
    #             enabled     = false
    #         }
    #     }
    # })
    # network = defaults(var.network, {
    #     cluster             = "172.24.0.0/16"
    #     service             = "172.22.0.0/16"
    # })
    # kubevip = defaults(var.kubevip, {
    #     enabled             = true
    #     interface           = "eth0"
    #     address             = "10.4.1.1" # basically kubernetes api address, if used
    #     bgp                 = {
    #         peer_ip         = "172.16.0.4"
    #         peer_as         = "65536"
    #         node_as         = "65538"
    #     }
    # })

    # note, for some weird reason defaults only work on top level keys for objects
    # nested defaults are found in variables.tf
    node_config = defaults(var.node, {
        # vmid_start          = null
        cpus                = 1
        bridge              = "vmbr0"
        memory_mb           = 1024
        os_disk_storage     = "local"
        os_disk_size        = "15G"
        ssh_username        = "debian"
        name_prefix         = "k3s-server-"
        nameserver          = "1.1.1.1 1.0.0.1"
    })
    calico_config = defaults(var.calico, {
        enabled             = var.networking == "calico" ? true : false
        encapsulation       = "IPIP"
        calico_version      = "v3.22.1"
        node_cidr           = "10.0.0.0/24"
        bgp = {
            enabled = false
        }
    })
    metallb_config = defaults(var.metallb, {
        enabled             = var.metallb.addresses != null ? true : false
        target_namespace    = "metallb-system"
        protocol            = "layer2"
    })
    kubevip_config = defaults(var.kubevip, {
        enabled             = false
    })
    install_config = defaults(var.install, {
        k3s_server = {
            install_path            = "/usr/local/bin"
            k3s_version             = "v1.21.5+k3s1"
            cidr = {
                cluster             = "172.24.0.0/16"
                service             = "172.22.0.0/16"
            }
            add_static_host_entries = var.dynamic_dns.enabled == false ? true : false
        }
        systemd_dir                 = "/etc/systemd/system"
        # docker_proxy_address= "dockerproxy.absolutist.it"
    })
    longhorn_config = defaults(var.longhorn, {
        enabled             = var.storage_operator == "longhorn" ? true : false
        target_namespace    = "longhorn-system"
        longhorn_version    = "v1.2.0" #"v1.2.4" 124 is latest
        defaultSettings     = {
            defaultDataPath = "/var/lib/longhorn"
            storageMinimalAvailablePercentage = 5
            defaultDataLocality = "best-effort"
            storageOverProvisioningPercentage = 135
            taintToleration = "CriticalAddonsOnly=true:NoSchedule"
            # below creates disks only on hosts which are labeled node.longhorn.io/create-default-disk=true
            # createDefaultDiskLabeledNodes = true
        }
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
    # ipconfig0               = tomap(toset(var.node_ip_addresses))

    ansible_roles = compact([
        local.calico_config.install_calicoctl == true ? "k3s/calicoctl" : "",
        "k3s/master",
        local.calico_config.enabled == true ? "k3s/calico" : "",
        local.metallb_config.enabled == true ? "k3s/metallb" : "",
        local.longhorn_config.enabled == true ? "k3s/longhorn" : "",
        local.kubevip_config.enabled == true ? "k3s/kube-vip" : ""
    ])

    hostnames = formatlist("${local.node_config.name_prefix}%02s", local.node_id)
}

resource "random_password" "master_nodes_shared_secret" {
    length           = 32
    special          = false
}

module "all_vars" {
    source = "../ansible-group-vars"
    filename = "inventory/group_vars/all.yaml"
    content = merge(local.install_config, {"dynamic_dns" = var.dynamic_dns, "longhorn" = local.longhorn_config})
}

module "master_vars" {
    source = "../ansible-group-vars"
    filename = "inventory/group_vars/master_nodes/k3s-vars.yaml"
    content = {
        k3s_shared_secret = random_password.master_nodes_shared_secret.result
        calico = local.calico_config
        metallb = local.metallb_config
        kubevip = local.kubevip_config
    }
}

resource "random_password" "vm_password" {
    length           = 16
    special          = true
    override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "proxmox_vm_qemu" "k3s_server_node" {
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
        #for_each = toset(each.value.disk)
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