variable "user" {
    type        = string
    description = "User to download file as"
}

variable "sleep_before" {
    type        = string
    description = "Duration to sleep before download"
    default     = "0s"
}

variable "host_addr" {
    type        = string
    description = "Host to download file from"
}

variable "remote_file" {
    type        = string
    description = "File to download"
}

variable "local_path" {
    type        = string
    description = "Path to download file to"
}

variable "private_key_path" {
    type        = string
    description = "Path to private key for ssh authentication"
}
