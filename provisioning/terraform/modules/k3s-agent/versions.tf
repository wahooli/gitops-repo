terraform {
    required_providers {
        proxmox = {
            source = "telmate/proxmox"
            version = ">=2.9.0"
        }
    }
    required_version = ">= 1.0"
}