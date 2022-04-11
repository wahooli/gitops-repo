variable "github_owner" {
    type        = string
    description = "github owner"
}

variable "github_token" {
    type        = string
    description = "github token"
    sensitive   = true
}

variable "repository_name" {
    type        = string
    description = "github repository name"
}

variable "branch" {
    type        = string
    description = "branch name"
    default     = "main"
}

variable "target_path" {
    type        = string
    description = "flux sync target path"
}

variable "flux_namespace" {
    type        = string
    description = "the flux namespace"
    default     = "flux-system"
}

variable "flux_version" {
    type        = string
    description = "FluxCD version to be installed"
    default     = "v0.28.5"
}

variable "extra_components" {
    description = "Extra components to install"
    default     = []
}


variable "kubeconfig_path" {
    type        = string
    description = "Path to the kubeconfig file."
}

variable "github_deploy_key_title" {
    type        = string
    description = "Name of github deploy key"
}

variable "kube_host" {
    type        = string
    default     = null
}

variable "kube_client_certificate" {
    type        = string
    default     = null
}

variable "kube_client_key" {
    type        = string
    default     = null
}

variable "kube_cluster_ca_certificate" {
    type        = string
    default     = null
}