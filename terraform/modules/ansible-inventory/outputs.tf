output "server_count" {
    value = length(flatten([for k, v in var.servers: v]))
}