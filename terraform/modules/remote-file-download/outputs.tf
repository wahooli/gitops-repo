output "filepath" {
    value = data.local_file.downloaded_file.filename
}

output "content" {
    value = data.local_file.downloaded_file.content
    sensitive = true
}