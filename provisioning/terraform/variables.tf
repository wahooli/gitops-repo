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

variable "github_owner" {
    type        = string
    description = "github owner"
    default     = "wahooli"
}

variable "github_token" {
    type        = string
    description = "github token"
    sensitive   = true
}

variable "key_fp" {
    type        = string
    description = "SOPS key fingerprint"
    sensitive   = true
}

variable "k3s" {
    type = object({
        cluster_name_prefix         = string
        server_config = object({
            docker_proxy_address    = string
            k3s_version             = string
            longhorn_version        = string
            longhorn_backup_target  = string
            longhorn_backup_secret  = string
            calico_version          = string
        })
        vm_config = object({
            proxmox_hosts           = list(string)
            vmid_start              = number
            agent_node_count        = number
            agent_node_cpus         = number
            agent_node_memory       = number
            server_node_count       = number
            server_node_cpus        = number
            server_node_memory      = number
            nameserver              = string
            nameserver_name         = string
            searchdomain            = string
            os_disk_storage         = string
            longhorn_disk_size      = string
            longhorn_disk_storage   = string
            bridge                  = string
            ssh_username            = string
            cidr                    = string
        })
        bgp_config = object({
            external_ipv4_cidr = string # external Ip range used by calico
            external_ip_range = string # Ip range advertised by metall
            peer_ip = string
            node_as = number
            peer_as = number
        })
    })
}
