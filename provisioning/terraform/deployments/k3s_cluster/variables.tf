variable "ssh_pk_ecdsa_curve" {
    type        = string
    default     = "P521"
}

variable "cluster_name_prefix" {
    type        = string
    description = "Will add this prefix to hostnames and to ssh private key"
}

variable "bgp_config" {
    type = object({
        external_ipv4_cidr = string # external Ip range used by calico
        external_ip_range = string # Ip range advertised by metall
        peer_ip = string
        node_as = number
        peer_as = number
    })
}

variable "k3s_config" {
    type = object({
        docker_proxy_address    = string
        k3s_version             = string
        longhorn_version        = string
        longhorn_backup_target  = string
        longhorn_backup_secret  = string
        calico_version          = string
    })
}

variable "vm_config" {
    type = object({
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
}

variable "github_config" {
    type        = object({
        token       = string
        owner       = string
        repo_name   = string
        branch      = string
    })
    sensitive = true
}

variable "fluxcd_config" {
    type        = object({
        deploy_key_title_prefix = string
        flux_namespace          = string
        target_path             = string
        flux_version            = string
        key_fp                  = string
    })
    sensitive = true
}