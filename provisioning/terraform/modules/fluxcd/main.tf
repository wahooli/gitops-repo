# Github
provider "github" {
    token           = var.github_token
    owner           = var.github_owner
}

provider "kubernetes" {
    # config_paths            = [ dirname(var.kubeconfig_path) ]
    config_path = var.kubeconfig_path
}

provider "kubectl" {
    config_path = var.kubeconfig_path
}

resource "null_resource" "flux_namespace" {
    triggers = {
        namespace   = var.flux_namespace
        kubeconfig  = var.kubeconfig_path
    }

    provisioner "local-exec" {
        when = create
        command = "kubectl --kubeconfig ${self.triggers.kubeconfig} create namespace ${self.triggers.namespace}"
    }

    provisioner "local-exec" {
        when       = destroy
        command    = "kubectl --kubeconfig ${self.triggers.kubeconfig} delete namespace ${self.triggers.namespace} --cascade=true --wait=false"
    }

    provisioner "local-exec" {
        when       = destroy
        command    = "kubectl --kubeconfig ${self.triggers.kubeconfig} patch customresourcedefinition helmcharts.source.toolkit.fluxcd.io helmreleases.helm.toolkit.fluxcd.io helmrepositories.source.toolkit.fluxcd.io kustomizations.kustomize.toolkit.fluxcd.io gitrepositories.source.toolkit.fluxcd.io -p '{\"metadata\":{\"finalizers\":null}}'"
        on_failure = continue
    }

    lifecycle {
        create_before_destroy = true
    }
}

data "flux_install" "main" {
    target_path = var.target_path
}

data "flux_sync" "main" {
    target_path = var.target_path
    url         = "ssh://git@github.com/${var.github_owner}/${var.repository_name}.git"
    branch      = var.branch
}

data "kubectl_file_documents" "install" {
    content = data.flux_install.main.content
}

data "kubectl_file_documents" "sync" {
    content = data.flux_sync.main.content
}

locals {
    install = [for v in data.kubectl_file_documents.install.documents : {
        data : yamldecode(v)
            content : v
        }
    ]
    sync = [for v in data.kubectl_file_documents.sync.documents : {
        data : yamldecode(v)
            content : v
        }
    ]
}

resource "kubectl_manifest" "install" {
    depends_on  = [null_resource.flux_namespace]
    for_each    = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
    yaml_body   = each.value
}

resource "kubectl_manifest" "sync" {
    depends_on  = [kubectl_manifest.install, null_resource.flux_namespace]
    for_each    = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
    yaml_body   = each.value
}

locals {
    known_hosts = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
}

resource "tls_private_key" "github_deploy_key" {
    algorithm   = "RSA"
    rsa_bits    = 4096
}

resource "kubernetes_secret" "main" {
    depends_on = [kubectl_manifest.install]

    metadata {
        annotations     = {}
        labels          = {}
        name            = data.flux_sync.main.secret
        namespace       = data.flux_sync.main.namespace
    }

    data = {
        known_hosts     = local.known_hosts
        identity        = tls_private_key.github_deploy_key.private_key_pem
        "identity.pub"  = tls_private_key.github_deploy_key.public_key_openssh
    }

    lifecycle {
        ignore_changes = [
            metadata[0].annotations,
            metadata[0].labels
        ]
    }
}

# maybe move this elsewhere, but lazy way to add deploykey to homeassistant
resource "null_resource" "iot_namespace" {
    triggers = {
        namespace   = "iot"
        kubeconfig  = var.kubeconfig_path
    }

    provisioner "local-exec" {
        when = create
        command = "kubectl --kubeconfig ${self.triggers.kubeconfig} create namespace ${self.triggers.namespace}"
    }
}

resource "kubernetes_secret" "hass_deploy_key" {
    depends_on = [null_resource.iot_namespace]

    metadata {
        annotations     = {}
        labels          = {}
        name            = "homeassistant-deploy-key"
        namespace       = "iot"
    }

    data = {
        id_rsa        = tls_private_key.github_deploy_key.private_key_pem
        "id_rsa.pub"  = tls_private_key.github_deploy_key.public_key_openssh
    }

    lifecycle {
        ignore_changes = [
            metadata[0].annotations,
            metadata[0].labels
        ]
    }
}

# To make sure the repository exists and the correct permissions are set.
data "github_repository" "main" {
    full_name = "${var.github_owner}/${var.repository_name}"
}

resource "github_repository_file" "install" {
    commit_author       = "FluxCD"
    commit_email        = "terraform@fluxcd.com"
    repository          = data.github_repository.main.name
    file                = data.flux_install.main.path
    content             = data.flux_install.main.content
    branch              = var.branch
    overwrite_on_create = true
}

resource "github_repository_file" "sync" {
    commit_author       = "FluxCD"
    commit_email        = "terraform@fluxcd.com"
    repository          = var.repository_name
    file                = data.flux_sync.main.path
    content             = data.flux_sync.main.content
    branch              = var.branch
    overwrite_on_create = true
}

resource "github_repository_file" "kustomize" {
    commit_author       = "FluxCD"
    commit_email        = "terraform@fluxcd.com"
    repository          = var.repository_name
    file                = data.flux_sync.main.kustomize_path
    content             = data.flux_sync.main.kustomize_content
    branch              = var.branch
    overwrite_on_create = true
}

# For flux to fetch source
resource "github_repository_deploy_key" "flux" {
    title               = var.github_deploy_key_title
    repository          = data.github_repository.main.name
    key                 = tls_private_key.github_deploy_key.public_key_openssh
    read_only           = false # for auto-updating images
}