variable "user" {
    type        = string
    description = "User to run ansible provisioning as"
}

variable "config_path" {
    type        = string
    description = "Path to ansible.cfg"
}

variable "inventory_path" {
    type        = string
    description = "Path to ansible inventory folder"
}

variable "playbook_path" {
    type        = string
    description = "Path to playbook to run"
}

variable "private_key_path" {
    type        = string
    description = "Path to private key for ssh authentication"
}

variable "triggers" {
    description = "Triggers to pass for null_resource"
}