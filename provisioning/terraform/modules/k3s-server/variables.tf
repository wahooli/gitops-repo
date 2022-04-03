variable "metallb" {
    type = object({
        enabled             = optional(bool)
        target_namespace    = optional(string)
        protocol            = optional(string)
        addresses           = optional(string)
        speaker             = object({
            enabled         = bool
            frr             = object({
                enabled     = optional(bool)
            })
        })
    })
    default = {
        speaker = {
            enabled = true
            frr = {
                enabled = false
            }
        }
    }
    description             = "Generates ansible group vars section from values. Will be ignored if metallb is not used"
}

variable "dynamic_dns" {
    type = object({
        enabled             = optional(bool)
        keytab_filepath     = optional(string)
        user                = optional(string)
        install_path        = optional(string)
        realm               = optional(string)
        nameserver          = optional(string)
    })
    default = {
        enabled = false
    }
    description             = "Generates ansible group vars section from values."
}

variable "calico" {
    type = object({
        enabled                 = optional(bool)
        encapsulation           = optional(string)
        calico_version          = optional(string)
        install_calicoctl       = optional(bool)
        mtu                     = optional(number)
        node_cidr               = optional(string)
        linuxDataplane          = optional(string)
        containerIPForwarding   = optional(string)
        bgp = object({
            enabled             = bool
            node_to_node_mesh   = optional(bool)
            node_selector       = optional(string)
            external_ips        = optional(string)
            peer_ip             = optional(string)
            peer_as             = optional(number)
            node_as             = optional(number)
        })
    })
    default = {
        install_calicoctl = false
        bgp = {
            enabled = false
        }
    }
    description             = "Generates ansible group vars section from values. Will be ignored if calico is not used"
}

variable "longhorn" {
    type = object({
        enabled                                 = optional(bool)
        target_namespace                        = optional(string)
        longhorn_version                        = optional(string)
        defaultSettings                         = object({
            backupTarget                        = optional(string)
            backupTargetCredentialSecret        = optional(string)
            defaultDataPath                     = optional(string)
            storageMinimalAvailablePercentage   = optional(number)
            createDefaultDiskLabeledNodes       = optional(bool)
            defaultDataLocality                 = optional(string)
            storageOverProvisioningPercentage   = optional(number)
            taintToleration                     = optional(string)
        })
        ingress                                 = object({
            enabled                             = optional(bool)
            ingressClassName                    = optional(string)
            host                                = optional(string)
            tlsSecret                           = optional(string)
            annotations                         = optional(object({}))
        })
    })
    default = {
        defaultSettings     = {
            defaultDataPath = "/var/lib/longhorn"
            storageMinimalAvailablePercentage = 5
            defaultDataLocality = "best-effort"
            storageOverProvisioningPercentage = 135
        }
        ingress = {
            enabled = false
        }
    }
    description             = "Generates ansible group vars section from values. Used with k3s server bootstrap"
}

variable "install" {
    type = object({
        k3s_server = object({
            server_address          = optional(string) # k3s api address, if not defined will fallback to kubevip address or first node ip
            k3s_version             = optional(string)
            external_ip_cidr        = optional(string)
            install_path            = optional(string)
            docker_proxy_address    = optional(string)
            add_static_host_entries = optional(bool)
            server_labels           = optional(list(object({
                name                = string
                value               = string
            })))
            server_taints           = optional(list(object({
                name                = string
                value               = string
                effect              = string
            })))
            agent_labels            = optional(list(object({
                name                = string
                value               = string
            })))
            agent_taints            = optional(list(object({
                name                = string
                value               = string
                effect              = string
            })))
            cidr                    = object({
                cluster             = optional(string)
                service             = optional(string)
            })
        })
        systemd_dir                 = optional(string)
    })
    default = {
        k3s_server = {
            install_path            = "/usr/local/bin"
            k3s_version             = "v1.21.5+k3s1"
            cidr = {
                cluster             = "172.24.0.0/16"
                service             = "172.22.0.0/16"
            }
        }
        systemd_dir                 = "/etc/systemd/system"
    }
    description             = "Generates ansible group vars section from values. Used with k3s server bootstrap"
}

variable "proxmox" {
    type = object({
        host        = string
        user        = string
        password    = string
    })
    sensitive = true
    description = "Used to push custom cloudinit config files. Might work with ssh keys, i'm too lazy to fix"
}

variable "kubevip" {
    type = object({
        enabled     = bool
        interface   = optional(string)
        address     = optional(string)
        bgp         = optional(object({
            peer_ip = optional(string)
            peer_as = optional(string)
            node_as = optional(string)
        }))
    })
    default = {
        enabled     = false
    }
    description     = "Kubevip config."
}

variable "storage_operator" {
    type        = string
    description = "Storage for cluster, valid options are longhorn and none. Maybe adding others later."

    validation {
        condition = contains(["longhorn", "none"], var.storage_operator)
        error_message = "Storage has to be \"longhorn\" or \"none\"."
    }
}

variable "networking" {
    type        = string
    description = "CNI for cluster, valid options are calico and none"

    validation {
        condition = contains(["calico", "none"], var.networking)
        error_message = "Networking has to be \"calico\" or \"none\"."
    }
}

variable "proxmox_hosts" {
    type        = list(string)
    description = "Proxmox hosts to allocate VMs. Uses element() function to loop trough each possible value. Requires at least one value"
}

variable "cloud_init" {
    type        = object({
        cdrom_storage       = optional(string)
        custom_file_path    = optional(string)
        custom_storage_name = optional(string)
    })
    description = "Values for cicustom files"
}

variable "node_count" {
    type        = number
    description = "How many node VMs will be created"
    validation {
        condition = var.node_count >= 1
        error_message = "Node count has to be more than or equal to 1."
    }
    default     = 0
}

variable "node" {
    type = object({
        vmid_start      = optional(number)
        cpus            = optional(number)
        bridge          = optional(string) # main network bridge
        memory_mb       = optional(number) # ram in mb
        os_disk_storage = optional(string)
        os_disk_size    = optional(string)
        disk_size       = optional(string) # node storage size, allocated to storage backend
        disk_storage    = optional(string)
        ssh_username    = optional(string)
        user_password   = optional(string)
        default_gateway = optional(string)
        name_prefix     = optional(string)
        eth0_mtu        = optional(number)
        ssh_private_key = optional(string)
        ssh_public_keys = optional(list(string))
        searchdomains   = optional(list(string))
        nameservers     = list(string)
        additional_networks = optional(list(string))
    })
    default = {
        name_prefix = "k3s-server-"
        nameservers = ["1.1.1.1", "1.0.0.1"]
    }
    description = "Node VM configuration. Each node shares configuration"
}

variable "node_ip_addresses" {
    type        = list(string)
    description = "Static ip addresses for eth0 adapter. If empty, or not defined for node, will allocate dhcp address"
    default     = []
}

variable "node_ip_macaddr" {
    type        = list(string)
    description = "Static ip addresses for eth0 adapter. If empty, or not defined for node, will allocate dhcp address"
    default     = []
}


