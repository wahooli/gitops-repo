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

variable "repository_visibility" {
    type        = string
    description = "How visible is the github repo"
    default     = "private"
}

variable "branch" {
    type        = string
    description = "branch name"
    default     = "main"
}

variable "target_path" {
    type        = string
    description = "flux sync target path"
    default     = "cluster"
}

# variable "kubeconfig" {
#     type        = string
#     description = "Kubeconfig file path"
# }