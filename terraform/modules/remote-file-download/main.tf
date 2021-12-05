resource "null_resource" "file_dl" {
    triggers = {
        host        = var.host_addr
        file        = var.remote_file
        local_path  = var.local_path
    }

    provisioner "local-exec" {
        command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.private_key_path} ${var.user}@${self.triggers.host}:${self.triggers.file} ${self.triggers.local_path}"
    }
}

data "local_file" "downloaded_file" {
    depends_on  = [null_resource.file_dl]
    filename    = var.local_path 
}