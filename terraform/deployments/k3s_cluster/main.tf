locals {
    masters = {
        "k3s-master-01" = {
            id              = 600
            cores           = 4
            memory          = 4096
            net_cidr        = "10.0.0.2/24"
            net_gw          = "10.0.0.253"
            net_bridge      = "vmbr100"
            storage_cidr    = "10.2.0.200/25"
            storage_bridge  = "vmbr140"
            target_node     = "pitfall"
            disk_size       = "50G"
            disk_storage    = "nvme-mirror"
        },
        "k3s-master-02" = {
            id              = 601
            cores           = 4
            memory          = 4096
            net_cidr        = "10.0.0.3/24"
            net_gw          = "10.0.0.253"
            net_bridge      = "vmbr100"
            storage_cidr    = "10.2.0.201/25"
            storage_bridge  = "vmbr140"
            target_node     = "berzerk"
            disk_size       = "50G"
            disk_storage    = "nvme-mirror"
        },
        "k3s-master-03" = {
            id              = 602
            cores           = 4
            memory          = 4096
            net_cidr        = "10.0.0.4/24"
            net_gw          = "10.0.0.253"
            net_bridge      = "vmbr100"
            storage_cidr    = "10.2.0.202/25"
            storage_bridge  = "vmbr140"
            target_node     = "solaris"
            disk_size       = "50G"
            disk_storage    = "nvme-mirror"
        }
    }
    workers = {
        "k3s-worker-01" = {
            id              = 603
            cores           = 8
            memory          = 16384
            net_cidr        = "10.0.0.5/24"
            net_gw          = "10.0.0.253"
            net_bridge      = "vmbr100"
            storage_cidr    = "10.2.0.203/25"
            storage_bridge  = "vmbr140"
            target_node     = "berzerk"
            disk_size       = "50G"
            disk_storage    = "nvme-mirror"
        },
        "k3s-worker-02" = {
            id              = 604
            cores           = 8
            memory          = 16384
            net_cidr        = "10.0.0.6/24"
            net_gw          = "10.0.0.253"
            net_bridge      = "vmbr100"
            storage_cidr    = "10.2.0.204/25"
            storage_bridge  = "vmbr140"
            target_node     = "pitfall"
            disk_size       = "50G"
            disk_storage    = "nvme-mirror"
        },
        "k3s-worker-03" = {
            id              = 605
            cores           = 8
            memory          = 16384
            net_cidr        = "10.0.0.7/24"
            net_gw          = "10.0.0.253"
            net_bridge      = "vmbr100"
            storage_cidr    = "10.2.0.205/25"
            storage_bridge  = "vmbr140"
            target_node     = "solaris"
            disk_size       = "50G"
            disk_storage    = "nvme-mirror"
        }
    }
}

resource "tls_private_key" "bootstrap_private_key" {
    algorithm = "ECDSA"
    ecdsa_curve = "P384"
}

resource "local_file" "private_key" {
    sensitive_content = tls_private_key.bootstrap_private_key.private_key_pem
    filename = "${path.module}/../../../pk/k3s-pk.pem"
    file_permission = "0600"
}

module "kubernetes_masters" {
    source = "../../modules/pve-qemu-bulk"
    vm-list = local.masters
    ssh_public_keys = tls_private_key.bootstrap_private_key.public_key_openssh
    default_user = var.remote_user
}

module "kubernetes_workers" {
    source = "../../modules/pve-qemu-bulk"
    vm-list = local.workers
    ssh_public_keys = tls_private_key.bootstrap_private_key.public_key_openssh
    default_user = var.remote_user
}

module "ansible_inventory" {
  source = "../../modules/ansible-inventory"
  ansible_inventory_filename = "k3s"
  servers = {
    master_nodes = [
      for k,v in local.masters: element(split("/", v.net_cidr), 0)
      ],
    worker_nodes = [
      for k,v in local.workers: element(split("/", v.net_cidr), 0)
      ]
  }
}

// Ansible post-provisioning configuration
resource "null_resource" "ansible" {
    depends_on = [
        module.kubernetes_masters,
        module.kubernetes_workers
    ]
    triggers = {
        servers = module.ansible_inventory.server_count
    }

    // Ansible playbook run - base config
    provisioner "local-exec" {
        command = "ansible-playbook -u ${var.remote_user} -i ${path.module}/../../../ansible/inventory --private-key ${path.module}/../../../pk/k3s-pk.pem ${path.module}/../../../ansible/k3s.yaml"
        environment = {
            ANSIBLE_CONFIG = "${path.module}/../../../ansible/ansible.cfg"
        }
    }

    provisioner "local-exec" {
        command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${local_file.private_key.filename} ${var.remote_user}@${module.kubernetes_masters.ip_addresses.0}:~/.kube/config ${path.module}/../../outputs/kubeconfig"
    }
}