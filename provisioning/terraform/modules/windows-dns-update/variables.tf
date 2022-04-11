variable "nameserver" {
    type        = string
    description = "Windows DNS server to send dns update"
    sensitive   = true
}

variable "realm" {
    type        = string
    description = "The Kerberos realm or Active Directory domain."
    sensitive   = true
}

variable "username" {
    type        = string
    description = "User to authenticate with"
    sensitive   = true
}

variable "keytab_file" {
    type        = string
    description = "Path to keytab file"
    # sensitive   = true
}

variable "a_records" {
    type            = list(object({
        zone        = string
        name        = string
        addresses   = list(string)
        ttl         = number
    }))
    validation {
        condition = length(var.a_records) >= 1
        error_message = "You need to define one record at least."
    }
    description = "List of ipv4 addresses to create record for"
}