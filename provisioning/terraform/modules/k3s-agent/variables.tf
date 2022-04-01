variable "mount_longhorn_disk" {
    type        = bool
    description = "Run longhorn disk mount role"
    default     = false
}

variable "proxmox_hosts" {
    type        = list(string)
    description = "Proxmox hosts to allocate VMs. Uses element() function to loop trough each possible value. Requires at least one value"
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
        default_gateway = optional(string)
        name_prefix     = optional(string)
        ssh_public_keys = optional(string)
        searchdomain    = optional(string)
        nameserver      = optional(string)
    })
    default = {
        name_prefix = "k3s-agent-"
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


