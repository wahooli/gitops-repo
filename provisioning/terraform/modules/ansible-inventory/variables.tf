variable "servers" {
  type = map
  default = {}
  description = "A map of inventory group names to IP addresses."
}

variable "ansible_inventory_filename" {
  type = string
  description = "Filename for Ansible inventory file."
}