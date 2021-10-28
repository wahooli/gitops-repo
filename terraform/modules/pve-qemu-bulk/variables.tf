variable "vm-list" {
	type = map(object({
		id = optional(number)
        target_node = string

		cores = number
		memory = number
		desc = optional(string)
		net_cidr = string
		net_gw = optional(string)
		net_bridge = optional(string)
		net_vlan = optional(number)
		storage_cidr = string
		storage_bridge = string
		storage_vlan = optional(number)
		disk_size = string
		disk_storage = string
	}))
	description = "Virtual machine bulk config"
}

variable "ssh_public_keys" {
    description = "Temp SSH public key that will be added to the container"
    type = string
}