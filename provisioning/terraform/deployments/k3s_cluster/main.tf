resource "tls_private_key" "node_ssh_pk" {
    algorithm = "ECDSA"
    ecdsa_curve = var.ssh_pk_ecdsa_curve
}

resource "local_sensitive_file" "private_key" {
    content = tls_private_key.node_ssh_pk.private_key_pem
    filename = abspath("${path.module}/../../../outputs/pk/${var.cluster_name_prefix}-pk.pem")
    file_permission = "0600"
}

resource "random_password" "vm_password" {
    length           = 32
    special          = true
    override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "k3s_server" {
    source                  = "../../modules/k3s-server"
    storage_operator        = "longhorn"
    networking              = "calico"
    proxmox_hosts           = var.vm_config.proxmox_hosts
    node_count              = var.vm_config.server_node_count
    node_ip_macaddr         = ["82:06:19:81:67:59", "F2:C9:63:D4:3E:3E", "2A:56:EA:EE:2D:F4"]
    node = {
        vmid_start = var.vm_config.vmid_start
        ssh_username = var.vm_config.ssh_username
        user_password = random_password.vm_password.result
        cpus = var.vm_config.server_node_cpus
        bridge = var.vm_config.bridge
        memory_mb = var.vm_config.server_node_memory
        eth0_mtu = var.vm_config.mtu
        os_disk_storage = var.vm_config.os_disk_storage
        name_prefix = "${var.cluster_name_prefix}-server-"
        ssh_private_key = tls_private_key.node_ssh_pk.private_key_pem
        ssh_public_keys = [tls_private_key.node_ssh_pk.public_key_openssh]
        nameservers = var.vm_config.nameservers
        searchdomains = var.vm_config.searchdomains
    }
    cloud_init = {
        cdrom_storage       = var.vm_config.ci_storage
        custom_file_path    = var.vm_config.ci_remote_path
        custom_storage_name = var.vm_config.ci_custom_storage
    }
    proxmox = var.proxmox
    longhorn = {
        target_namespace    = "longhorn-system"
        longhorn_version    = var.k3s_config.longhorn_version
        defaultSettings     = {
            backupTarget = var.k3s_config.longhorn_backup_target
            backupTargetCredentialSecret = var.k3s_config.longhorn_backup_secret
            defaultDataPath = "/var/lib/longhorn"
            storageMinimalAvailablePercentage = 10
            defaultDataLocality = "best-effort"
            storageOverProvisioningPercentage = 150
            taintToleration = "CriticalAddonsOnly=true:NoSchedule"
            # below creates disks only on hosts which are labeled node.longhorn.io/create-default-disk=true
            createDefaultDiskLabeledNodes = true
        }
        ingress             = {
            enabled = false
        }
    }
    install = {
        k3s_server = {
            docker_proxy_address    = var.k3s_config.docker_proxy_address
            k3s_version             = var.k3s_config.k3s_version
            external_ip_cidr        = var.bgp_config.external_ipv4_cidr
            server_address          = "${var.cluster_name_prefix}.${var.vm_config.searchdomains[0]}"
            cidr                    = {
                cluster             = "172.24.0.0/16"
                service             = "172.22.0.0/16"
            }
            server_labels = [
                {
                    name = "node.kubernetes.io/exclude-from-external-load-balancer"
                    value = "true"
                }
            ]
            server_taints = [
                {
                    name = "CriticalAddonsOnly"
                    value = "true"
                    effect = "NoSchedule"
                }
            ]
            agent_labels = [
                {
                    name = "node.longhorn.io/create-default-disk"
                    value = "true"
                },
                {
                    name = "multi-interface-node"
                    value = "true"
                }
            ]
        }
        cni_plugins = {
            install = true
            install_path = "/opt/cni/bin"
            version = var.k3s_config.cni_plugins_version
        }
    }
    metallb = {
        enabled             = true
        target_namespace    = "metallb-system"
        protocol            = "bgp"
        addresses           = var.bgp_config.external_ip_range
        speaker             = {
            enabled         = false
            frr             = {
                enabled     = false
            }
        }
    }
    calico = {
        encapsulation           = "None" #"IPIPCrossSubnet" #"None"
        calico_version          = var.k3s_config.calico_version
        install_calicoctl       = true
        node_cidr               = var.vm_config.cidr
        linuxDataplane          = "BPF" # "Iptables" #BPF
        containerIPForwarding   = "Enabled"
        mtu                     = (var.vm_config.mtu - 60)
        bgp = {
            enabled             = true
            node_to_node_mesh   = true
            node_selector       = "all()" # has(router-peer)
            external_ips        = var.bgp_config.external_ipv4_cidr
            peer_ip             = var.bgp_config.peer_ip
            peer_as             = var.bgp_config.peer_as
            node_as             = var.bgp_config.node_as
        }
    }
    dynamic_dns = {
        enabled = true
        keytab_filepath = abspath("${path.module}/../../../outputs/pk/externaldns.keytab")
        user = "externaldns"
        install_path = "/usr/local/bin"
        realm = var.vm_config.searchdomains[0]
        nameserver = var.vm_config.nameserver_name
    }
}

module "k3s_agent" {
    source                  = "../../modules/k3s-agent"
    proxmox_hosts           = var.vm_config.proxmox_hosts
    node_count              = var.vm_config.agent_node_count
    node_ip_macaddr         = ["0A:DF:58:1A:F2:4B", "D2:1C:C4:DE:9B:E4", "CE:19:CA:60:FB:83"]
    # node_ip_addresses       = ["192.168.1.22/24"]
    node = {
        # default_gateway = "192.168.1.1"
        vmid_start = var.vm_config.vmid_start + var.vm_config.server_node_count + 1
        cpus = var.vm_config.agent_node_cpus
        bridge = var.vm_config.bridge
        ssh_username = var.vm_config.ssh_username
        user_password = random_password.vm_password.result
        memory_mb = var.vm_config.agent_node_memory
        os_disk_storage = var.vm_config.os_disk_storage
        disk_size = var.vm_config.longhorn_disk_size
        disk_storage = var.vm_config.longhorn_disk_storage
        name_prefix = "${var.cluster_name_prefix}-agent-"
        ssh_private_key = tls_private_key.node_ssh_pk.private_key_pem
        ssh_public_keys = [tls_private_key.node_ssh_pk.public_key_openssh]
        nameservers = var.vm_config.nameservers
        eth0_mtu = var.vm_config.mtu
        searchdomains = var.vm_config.searchdomains
        additional_networks = var.vm_config.agent_additional_networks
        # dhcp_additional_networks = true
    }
    cloud_init = {
        cdrom_storage       = var.vm_config.ci_storage
        custom_file_path    = var.vm_config.ci_remote_path
        custom_storage_name = var.vm_config.ci_custom_storage
    }
    proxmox = var.proxmox
    mount_longhorn_disk = true
}

module "ansible_playbook" {
    source  = "../../modules/ansible-playbook"
    filename = "playbooks/generated_playbook.yaml"
    plays = [
        {
            hosts = ["master_nodes", "worker_nodes"]
            become = true
            gather_facts = true
            any_errors_fatal = true
            roles = [
                "cloud-init-wait",
                "update_os",
                "prepare",
                "dynamic_dns/install",
                "cni-plugins-install",
                "k3s/download",
                "k3s/pre-configure",
                "k3s/calico-blackhole"
            ]
        },
        {
            hosts = ["master_nodes"]
            become = true
            gather_facts = true
            any_errors_fatal = true
            roles = module.k3s_server.ansible_roles
        },
        {
            hosts = ["worker_nodes"]
            become = true
            gather_facts = true
            any_errors_fatal = true
            roles = module.k3s_agent.ansible_roles
        },
        {
            hosts = ["master_nodes", "worker_nodes"]
            become = true
            gather_facts = true
            any_errors_fatal = true
            roles = [
                "k3s/install-cleanup"
            ]
        }
    ]
}

module "ansible_inventory" {
    source  = "../../modules/ansible-inventory"
    content = {
        "master_nodes" = tomap(module.k3s_server.ansible_hosts),
        "worker_nodes" = tomap(module.k3s_agent.ansible_hosts)
    }
    filename = "inventory/generated_inventory.yaml"
}

module "ansible_provisioner" {
    source = "../../modules/ansible-provisioner"
    depends_on = [
        # module.ansible_inventory,
        module.ansible_playbook,
        module.k3s_server,
        module.k3s_agent,
    ]
    user                = module.k3s_agent.node_ssh_username
    config_path         = "${path.module}/../../../ansible/ansible.cfg"
    inventory_path      = "${path.module}/../../../ansible/inventory"
    playbook_path       = module.ansible_playbook.filepath
    private_key_path    = local_sensitive_file.private_key.filename
    triggers = {
        master_roles = join(",", module.k3s_server.ansible_roles)
        agent_roles = join(",", module.k3s_agent.ansible_roles)
        playbook_length = module.ansible_playbook.play_count
    }
}

module "kubeconfig" {
    source = "../../modules/kubeconfig"
    depends_on = [
        module.ansible_provisioner,
        module.k3s_server
    ]
    user                = var.vm_config.ssh_username
    host_addr           = module.k3s_server.ip_addresses.0
    remote_file         = "~/.kube/config"
    local_path          = "${path.module}/../../../outputs/kubeconfig"
    private_key_path    = local_sensitive_file.private_key.filename
}

# this cannot be done for some reason when joining cluster, dunno why
resource "null_resource" "worker_nodes_label" {
    depends_on = [
        module.kubeconfig
    ]
    for_each = toset(module.k3s_agent.hostnames)
    triggers = {
        kubeconfig = module.kubeconfig.filepath
    }

    provisioner "local-exec" {
        # when        = apply
        command     = "kubectl --kubeconfig ${self.triggers.kubeconfig} label nodes ${each.key} node-role.kubernetes.io/worker=worker"
    }
}

module "fluxcd" {
    source                      = "../../modules/fluxcd"
    # depends_on                  = [ module.kubeconfig ]
    github_deploy_key_title     = "${var.fluxcd_config.deploy_key_title_prefix}-${var.cluster_name_prefix}"
    github_token                = var.github_config.token
    github_owner                = var.github_config.owner
    repository_name             = var.github_config.repo_name
    branch                      = var.github_config.branch
    target_path                 = var.fluxcd_config.target_path
    flux_namespace              = var.fluxcd_config.flux_namespace
    kubeconfig_path             = module.kubeconfig.filepath
    flux_version                = var.fluxcd_config.flux_version
    extra_components            = ["image-reflector-controller", "image-automation-controller"]
    kube_host                   = module.kubeconfig.kubeconfig.host
    kube_client_certificate     = module.kubeconfig.kubeconfig.client_certificate
    kube_client_key             = module.kubeconfig.kubeconfig.client_key
    kube_cluster_ca_certificate = module.kubeconfig.kubeconfig.cluster_ca_certificate
}

module "sops_gpg" {
    source                  = "../../modules/kube-sops-secret"
    depends_on              = [ module.kubeconfig, module.fluxcd ]
    key_fp                  = var.fluxcd_config.key_fp
    secret_name             = "sops-gpg"
    namespace               = var.fluxcd_config.flux_namespace
    kubeconfig_path         = module.kubeconfig.filepath
}