output "filepath" {
    depends_on  = [null_resource.file_dl]
    # value = data.local_file.downloaded_file.filename
    value = abspath(var.local_path)
    # value = abspath(data.local_file.downloaded_file.filename)
}

output "content" {
    depends_on  = [null_resource.file_dl]
    value = data.local_file.downloaded_file.content
    sensitive = true
}