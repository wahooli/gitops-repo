output "kubeconfig" {
    value = module.k3s_cluster.kubeconfig.host
}