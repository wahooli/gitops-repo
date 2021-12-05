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

variable "kubeconfig_path" {
    type        = string
    description = "Path to the kubeconfig file."
}

variable "github_deploy_key_title" {
    type        = string
    description = "Name of github deploy key"
}