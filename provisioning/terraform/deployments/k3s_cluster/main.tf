locals {
    # os_disk_storage = "local-zfs" #too slow :D
    proxmox_storage = "nvme-zfs"
    os_disk_storage = "nvme-zfs"
    deploy_key_title = "FluxCD"
    masters = {
        "k3s-master-01" = {
            id              = 600
            cores           = 4
            memory          = 4096
            target_node     = "pitfall"
            network = [
                {
                    cidr    = "10.0.0.2/24",
                    gw      = "10.0.0.253"
                    bridge  = "vmbr100"
                }
            ],
            disk = [
                {
                    size    = "35G"
                    storage = local.os_disk_storage
                }
            ]
        },
        "k3s-master-02" = {
            id              = 601
            cores           = 4
            memory          = 4096
            target_node     = "berzerk"
            network = [
                {
                    cidr    = "10.0.0.3/24",
                    gw      = "10.0.0.253"
                    bridge  = "vmbr100"
                }
            ],
            disk = [
                {
                    size    = "35G"
                    storage = local.os_disk_storage
                }
            ]
        },
        "k3s-master-03" = {
            id              = 602
            cores           = 4
            memory          = 4096
            target_node     = "solaris"
            network = [
                {
                    cidr    = "10.0.0.4/24",
                    gw      = "10.0.0.253"
                    bridge  = "vmbr100"
                }
            ]
            disk = [
                {
                    size    = "35G"
                    storage = local.os_disk_storage
                }
            ]
        }
    }
    workers = {
        "k3s-worker-01" = {
            id              = 603
            cores           = 8
            memory          = 16384
            target_node     = "berzerk"
            network = [
                {
                    cidr    = "10.0.0.5/24",
                    gw      = "10.0.0.253"
                    bridge  = "vmbr100"
                }
            ]
            disk = [
                {
                    size    = "45G"
                    storage = local.os_disk_storage
                },
                {
                    size    = "140G"
                    storage = local.proxmox_storage
                }
            ]
        },
        "k3s-worker-02" = {
            id              = 604
            cores           = 8
            memory          = 16384
            target_node     = "pitfall"
            network = [
                {
                    cidr    = "10.0.0.6/24",
                    gw      = "10.0.0.253"
                    bridge  = "vmbr100"
                }
            ]
            disk = [
                {
                    size    = "45G"
                    storage = local.os_disk_storage
                },
                {
                    size    = "140G"
                    storage = local.proxmox_storage
                }
            ]
        },
        "k3s-worker-03" = {
            id              = 605
            cores           = 8
            memory          = 16384
            target_node     = "solaris"
            network = [
                {
                    cidr    = "10.0.0.7/24",
                    gw      = "10.0.0.253"
                    bridge  = "vmbr100"
                }
            ]
            disk = [
                {
                    size    = "45G"
                    storage = local.os_disk_storage
                },
                {
                    size    = "140G"
                    storage = local.proxmox_storage
                }
            ]
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
            for k,v in local.masters: element(split("/", v.network["0"]["cidr"]), 0)
        ],
        worker_nodes = [
            for k,v in local.workers: element(split("/", v.network["0"]["cidr"]), 0)
        ]
    }
}

module "ansible_playbook" {
    source = "../../modules/ansible-provisioner"
    depends_on = [
        module.ansible_inventory,
        module.kubernetes_masters,
        module.kubernetes_workers
    ]
    user                = var.remote_user
    config_path         = "${path.module}/../../../ansible/ansible.cfg"
    inventory_path      = "${path.module}/../../../ansible/inventory"
    playbook_path       = "${path.module}/../../../ansible/k3s.yaml"
    private_key_path    = local_file.private_key.filename
    triggers = {
        servers = module.ansible_inventory.server_count
    }
}

# module "kubeconfig" {
#     source = "../../modules/remote-file-download"
#     depends_on = [
#         module.ansible_playbook,
#         module.kubernetes_masters
#     ]
#     user                = var.remote_user
#     host_addr           = module.kubernetes_masters.ip_addresses.0
#     remote_file         = "~/.kube/config"
#     local_path          = "${path.module}/../../outputs/kubeconfig"
#     private_key_path    = local_file.private_key.filename
# }

module "kubeconfig" {
    source = "../../modules/kubeconfig"
    depends_on = [
        module.ansible_playbook,
        module.kubernetes_masters
    ]
    user                = var.remote_user
    host_addr           = module.kubernetes_masters.ip_addresses.0
    remote_file         = "~/.kube/config"
    local_path          = "${path.module}/../../outputs/kubeconfig"
    private_key_path    = local_file.private_key.filename
}

module "flux" {
    source                      = "../../modules/fluxcd"
    # depends_on                  = [ module.kubeconfig ]
    github_deploy_key_title     = local.deploy_key_title
    github_token                = var.github_token
    github_owner                = var.github_owner
    repository_name             = var.repository_name
    branch                      = var.branch
    target_path                 = var.flux_path
    flux_namespace              = var.flux_namespace
    kubeconfig_path             = module.kubeconfig.filepath

    kube_host                   = module.kubeconfig.kubeconfig.host
    kube_client_certificate     = module.kubeconfig.kubeconfig.client_certificate
    kube_client_key             = module.kubeconfig.kubeconfig.client_key
    kube_cluster_ca_certificate = module.kubeconfig.kubeconfig.cluster_ca_certificate
}

resource "null_resource" "worker_nodes_label" {
    depends_on = [
        module.kubeconfig
    ]
    for_each = local.workers
    triggers = {
        kubeconfig = module.kubeconfig.filepath
    }

    provisioner "local-exec" {
        # when        = apply
        command     = "kubectl --kubeconfig ${self.triggers.kubeconfig} label nodes ${each.key} node.longhorn.io/create-default-disk=true"
    }
}

module "sops_gpg" {
    source                  = "../../modules/kube-sops-secret"
    depends_on              = [ module.kubeconfig, module.flux ]
    key_fp                  = var.key_fp
    secret_name             = "sops-gpg"
    namespace               = var.flux_namespace
    kubeconfig_path         = module.kubeconfig.filepath
}