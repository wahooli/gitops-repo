variable "remote_user" {
    description = "Remote user to be created with cloudinit"
    type = string
    default = "debian"
}

variable "github_owner" {
    type        = string
    description = "github owner"
    default     = "wahooli"
}

variable "github_token" {
    type        = string
    description = "github token"
    sensitive   = true
}

variable "repository_name" {
    type        = string
    description = "github repository name"
    default     = "homelab"
}

variable "branch" {
    type        = string
    description = "branch name"
    default     = "main"
}

variable "flux_path" {
    type        = string
    description = "flux sync target path"
}

variable "flux_namespace" {
    type        = string
    description = "the flux namespace"
    default     = "flux-system"
}

variable "key_fp" {
    type        = string
    description = "SOPS key fingerprint"
    sensitive   = true
}