output "filepath" {
    depends_on = [
        module.kubeconfig_dl.content
    ]
    value = local.path
}

output "kubeconfig" {
    depends_on = [
        module.kubeconfig_dl.content
    ]
    value = {
        host                    = local.host
        cluster_ca_certificate  = local.cluster_ca_certificate
        client_certificate      = local.client_certificate
        client_key              = local.client_key
    }
    sensitive = true
}