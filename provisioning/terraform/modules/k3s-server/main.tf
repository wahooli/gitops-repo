terraform {
    experiments = [module_variable_optional_attrs]
}

locals {
    node_config = defaults(var.node, {
        cpus                = 1
        bridge              = "vmbr0"
        memory_mb           = 1024
        os_disk_storage     = "local"
        os_disk_size        = "15G"
        ssh_username        = "debian"
        name_prefix         = "k3s-server-"
        eth0_mtu            = 1500
        nameservers         = "1.1.1.1 1.0.0.1"
        # nameservers = ["1.1.1.1", "1.0.0.1"]
    })
    calico_config = defaults(var.calico, {
        enabled             = var.networking == "calico" ? true : false
        encapsulation       = "IPIP"
        calico_version      = "v3.22.1"
        node_cidr           = "10.0.0.0/24"
        mtu                 = 1500
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
        cni_plugins = {
            install                 = false
        }
    })
    longhorn_config = defaults(var.longhorn, {
        enabled             = var.storage_operator == "longhorn" ? true : false
        target_namespace    = "longhorn-system"
        longhorn_version    = "v1.2.4"
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
    cloud_init_config = defaults(var.cloud_init, {
        cdrom_storage       = "local" # creates cloudinit cdrom drive to this storage
        custom_file_path    = "/var/lib/vz" # stores cicustom files here. preferrably shared storage. omit /snippets suffix
        custom_storage_name = "local" # loads cicustom files from here
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
    macaddr                 = {for i, d in var.node_ip_macaddr : i => lower(d)}
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
        local.calico_config.install_calicoctl == true ? "k3s/calicoctl" : "",
        "k3s/master",
        local.calico_config.enabled == true ? "k3s/calico" : "",
        local.metallb_config.enabled == true ? "k3s/metallb" : "",
        local.longhorn_config.enabled == true ? "k3s/longhorn" : "",
        local.kubevip_config.enabled == true ? "k3s/kube-vip" : ""
    ])

    hostnames = formatlist("${local.node_config.name_prefix}%02s", local.node_id)
    id_start = local.node_config.vmid_start != null && local.node_config.vmid_start != 0 ? local.node_config.vmid_start : 1
    id_iterator = range(local.id_start, (local.id_start + var.node_count))
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

resource "local_file" "cloud_init_user_data_file" {
    count    = var.node_count
    content  = templatefile("${path.module}/templates/user_data.cfg",
    {
        ssh_pub_keys    = local.node_config.ssh_public_keys
        hostname        = "${format("${local.node_config.name_prefix}%02s", count.index + 1)}"
        fqdn            = "${format("${local.node_config.name_prefix}%02s", count.index + 1)}.${local.node_config.searchdomains[0]}"
        user            = local.node_config.ssh_username
        password        = bcrypt(local.node_config.user_password)
        eth0_mtu        = local.node_config.eth0_mtu
    })
    filename = "${path.module}/rendered/user_data_vm-${local.id_iterator[count.index]}.yml"
}

resource "local_file" "cloud_init_network_data_file" {
    count    = var.node_count
    content  = templatefile("${path.module}/templates/network_data_v2.cfg",
    {
        interfaces = [
            {
                macaddress = lower(lookup(local.macaddr, count.index, null))
                address = "dhcp"
            }
        ]
        searchdomains = jsonencode(local.node_config.searchdomains)
        nameservers = jsonencode(local.node_config.nameservers)
        eth0_mtu = local.node_config.eth0_mtu
    })
    filename = "${path.module}/rendered/network_data_vm-${local.id_iterator[count.index]}.yml"
}

# v1 network file
# resource "local_file" "cloud_init_network_data_file" {
#     count    = var.node_count
#     content  = templatefile("${path.module}/templates/network_data_v1.cfg",
#     {
#         interfaces = [
#             {
#                 macaddress = lower(lookup(local.macaddr, count.index, null))
#                 address = "dhcp"
#             }
#         ]
#         searchdomains = local.node_config.searchdomains
#         nameservers = local.node_config.nameservers
#     })
#     filename = "${path.module}/rendered/network_data_vm-${local.id_iterator[count.index]}.yml"
# }

resource "null_resource" "cloud_init_config_files" {
    depends_on = [
        local_file.cloud_init_network_data_file,
        local_file.cloud_init_user_data_file
    ]
    count    = var.node_count
    triggers = {
        network_files = join(" ", [for i in range(var.node_count) : "${local.cloud_init_config.custom_file_path}/snippets/${basename(local_file.cloud_init_network_data_file[i].filename)}"])
        user_files = join(" ", [for i in range(var.node_count) : "${local.cloud_init_config.custom_file_path}/snippets/${basename(local_file.cloud_init_user_data_file[i].filename)}"])
        ssh_user = sensitive(var.proxmox.user)
        ssh_pass = sensitive(var.proxmox.password)
        ssh_host = sensitive(var.proxmox.host)
        # files_sha = join(" ", [for i in range(var.node_count) : filesha256(local_file.cloud_init_network_data_file[i].filename)])
    }
    connection {
        type     = "ssh"
        user     = self.triggers.ssh_user
        password = self.triggers.ssh_pass
        host     = self.triggers.ssh_host
    }

    provisioner "file" {
        source      = local_file.cloud_init_user_data_file[count.index].filename
        destination = "${split(" ", self.triggers.user_files)[count.index]}"
    }

    provisioner "file" {
        source      = local_file.cloud_init_network_data_file[count.index].filename
        destination = "${split(" ", self.triggers.network_files)[count.index]}"
    }

    provisioner "remote-exec" {
        when        = destroy
        inline      = [
            "rm -f ${split(" ", self.triggers.network_files)[count.index]}"
        ]
    }

    provisioner "remote-exec" {
        when        = destroy
        inline      = [
            "rm -f ${split(" ", self.triggers.user_files)[count.index]}"
        ]
    }
}

resource "proxmox_vm_qemu" "k3s_server_node" {
    depends_on = [
        null_resource.cloud_init_config_files,
    ]
    for_each        = toset(formatlist("%s", local.node_id))
    target_node     = element(var.proxmox_hosts, each.key - 1)
    onboot          = local.onboot
    tablet          = local.tablet
    agent           = local.agent
    clone           = local.clone
    full_clone      = local.full_clone
    bios            = local.bios
    qemu_os         = local.qemu_os # linux
    os_type         = local.os_type
    scsihw          = local.scsihw
    cpu             = "${local.cpu},flags=${local.cpuflags}"
    name            = "${format("${local.node_config.name_prefix}%02s", each.key)}"
    vmid            = local.node_config.vmid_start != null && local.node_config.vmid_start != 0 ? (local.node_config.vmid_start + (each.key -1)) : null
    cores           = local.node_config.cpus
    memory          = local.node_config.memory_mb
    cicustom        = "network=${local.cloud_init_config.custom_storage_name}:snippets/${basename(local_file.cloud_init_network_data_file[each.key - 1].filename)},user=${local.cloud_init_config.custom_storage_name}:snippets/${basename(local_file.cloud_init_user_data_file[each.key - 1].filename)}"
    cloudinit_cdrom_storage = local.cloud_init_config.cdrom_storage
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
        bridge = local.node_config.bridge
        macaddr = lower(lookup(local.macaddr, each.key - 1, null))
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

resource "null_resource" "cloud_init_ready" {
    depends_on = [
        proxmox_vm_qemu.k3s_server_node
    ]
    count    = var.node_count
    triggers = {
        ssh_user = sensitive(local.node_config.ssh_username)
        ssh_pk = sensitive(local.node_config.ssh_private_key)
        ssh_host = sensitive(proxmox_vm_qemu.k3s_server_node[count.index + 1].default_ipv4_address)
    }
    connection {
        type        = "ssh"
        user        = self.triggers.ssh_user
        private_key = self.triggers.ssh_pk
        host        = self.triggers.ssh_host
    }

    provisioner "remote-exec" {
        when        = create
        on_failure  = continue

        inline      = [
            "sudo cloud-init status --wait"
        ]
    }
}

# yeah this sucks
resource "time_sleep" "wait_after_cloudinit" {
    depends_on = [null_resource.cloud_init_ready]

    create_duration = "30s"
}