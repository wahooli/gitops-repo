terraform {
    experiments = [module_variable_optional_attrs]
    required_providers {
        proxmox = {
            source = "telmate/proxmox"
            version = ">=2.9.0"
        }
        macaddress = {
            source = "ivoronin/macaddress"
            version = ">=0.3.0"
        }
    }
    required_version = ">= 1.0"
}
