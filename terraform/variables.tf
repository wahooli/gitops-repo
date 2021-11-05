variable "proxmox_api_url" {
    description = "Proxmox API endpoint"
    type        = string
    default     = "https://10.0.0.12:8006/api2/json"
}

variable "proxmox_api_token_id" {
    description = "Proxmox API Token ID"
    type        = string
    sensitive   = true
    default     = "terraform@pve!terraform-token"
}

variable "proxmox_api_token_secret" {
    description = "API token secret. Required, sensitive, or use environment variable TF_VAR_proxmox_api_token_secret"
    sensitive   = true
}

variable "proxmox_ignore_tls" {
    description = "Disable TLS verification while connecting"
    type        = string
    default     = "true"
}

variable "masters" {
    type = map(object({
        id = optional(number)
        target_node = string

        cores = number
        memory = number
        desc = optional(string)
        net_cidr = string
        net_gw = optional(string)
        net_bridge = optional(string)
        net_vlan = optional(number)
        storage_cidr = string
        storage_bridge = string
        storage_vlan = optional(number)
        disk_size = string
        disk_storage = string
    }))
    description = "Master nodes config"
}

variable "workers" {
    type = map(object({
        id = optional(number)
        target_node = string

        cores = number
        memory = number
        desc = optional(string)
        net_cidr = string
        net_gw = optional(string)
        net_bridge = optional(string)
        net_vlan = optional(number)
        storage_cidr = string
        storage_bridge = string
        storage_vlan = optional(number)
        disk_size = string
        disk_storage = string
    }))
    description = "Master nodes config"
}