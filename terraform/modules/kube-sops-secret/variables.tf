variable "key_fp" {
    type        = string
    description = "SOPS key fingerprint"
    sensitive   = true
}

variable "kubeconfig_path" {
    type        = string
    description = "Path to kubeconfig"
}

variable "secret_name" {
    type        = string
    description = "Name of sops secret"
    default     = "sops-gpg"
}

variable "namespace" {
    type        = string
    description = "Namespace to create secret into"
}