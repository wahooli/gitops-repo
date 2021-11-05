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
  pm_parallel         = 6
  pm_log_enable       = false
  pm_debug            = false
  pm_log_levels = {
    _default = "debug"
    _capturelog = ""
  }
}


module "kubernetes_workers" {
  source = "./modules/pve-qemu-bulk"
  vm-list = var.workers
  ssh_public_keys = tls_private_key.bootstrap_private_key.public_key_openssh
}

// Ansible post-provisioning configuration
resource "null_resource" "ansible" {
  depends_on = [
    module.kubernetes_masters,
    module.kubernetes_workers
  ]

  // Ansible playbook run - base config
  provisioner "local-exec" {
    command = "ansible-playbook -u devops -i ${path.module}/../../ansible/inventory --private-key ${path.module}/../../pk/private_key.pem ${path.module}/../../ansible/k3s.yaml"
    environment = {
      ANSIBLE_CONFIG = "${path.module}/../../ansible/ansible.cfg"
    }
  }
}