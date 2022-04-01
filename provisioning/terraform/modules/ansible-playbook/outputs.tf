output "filepath" {
    value = module.yaml_file.filepath
}

output "play_count" {
    value = length(var.plays)
}