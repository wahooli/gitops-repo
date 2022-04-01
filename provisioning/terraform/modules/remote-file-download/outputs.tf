output "filepath" {
    depends_on  = [null_resource.file_dl]
    value = abspath(var.local_path)
}

output "content" {
    depends_on  = [null_resource.file_dl]
    value = data.local_file.downloaded_file.content
    sensitive = true
}