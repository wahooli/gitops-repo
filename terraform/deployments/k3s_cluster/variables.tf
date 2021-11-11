variable "remote_user" {
    description = "Remote user to be created with cloudinit"
    type = string
    default = "debian"
}

variable "kubeconfig" {
    description = "Kubeconfig"
    type = string
    default = file("${path.module}/outputs/kubeconfig")
}