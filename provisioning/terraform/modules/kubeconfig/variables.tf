variable "user" {
    type        = string
    description = "User to download file as"
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
