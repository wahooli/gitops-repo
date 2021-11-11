variable "proxmox_api_url" {
    description = "Proxmox API endpoint"
    type        = string
    default     = "https://10.0.0.12:8006/api2/json"
}

variable "proxmox_api_token_id" {
    description = "Proxmox API Token ID"
    type        = string
    sensitive   = true
    default     = "terraform@pve!terraform-token"
}

variable "proxmox_api_token_secret" {
    description = "API token secret. Required, sensitive, or use environment variable TF_VAR_proxmox_api_token_secret"
    sensitive   = true
}

variable "proxmox_ignore_tls" {
    description = "Disable TLS verification while connecting"
    type        = string
    default     = "true"
}

variable "kubeconfig" {
    description = "Kubeconfig file path"
    type        = string
    default     = "${path.module}/outputs/kubeconfig"
}