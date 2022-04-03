terraform {
    required_providers {
        proxmox = {
            source  = "telmate/proxmox"
            version = ">= 2.9.0"
        }
    }
    required_version = ">= 1.0.0"
    experiments = [module_variable_optional_attrs]
}

provider "proxmox" {
    # Configuration options
    pm_api_url          = var.proxmox_api_url
    pm_api_token_id     = var.proxmox_api_token_id
    pm_api_token_secret = var.proxmox_api_token_secret
    pm_tls_insecure     = var.proxmox_ignore_tls
    pm_parallel         = 4 # having 6 as parallel, gives errors for already running vm for some reason
    pm_log_enable       = true
    pm_debug            = true
    pm_log_file         = "terraform-plugin-proxmox.log"
    pm_log_levels = {
        _default = "debug"
        _capturelog = ""
    }
}

module "k3s_cluster" {
    source                  = "./deployments/k3s_cluster"
    cluster_name_prefix     = var.k3s.cluster_name_prefix
    bgp_config              = var.k3s.bgp_config
    vm_config               = var.k3s.vm_config
    k3s_config              = var.k3s.server_config
    proxmox                 = var.proxmox
    github_config = {
        branch = "dev"
        owner = var.github_owner
        repo_name = "homelab"
        token = var.github_token
    }
    fluxcd_config = {
        deploy_key_title_prefix = "FluxCD"
        flux_namespace = "flux-system"
        target_path = "test-cluster"
        flux_version = "v0.28.5"
        key_fp = var.key_fp
    }
}