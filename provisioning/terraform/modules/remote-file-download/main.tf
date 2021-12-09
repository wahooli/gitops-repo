resource "time_sleep" "wait_before_dl" {
    destroy_duration = var.sleep_before
}

resource "null_resource" "file_dl" {
    depends_on = [time_sleep.wait_before_dl]
    triggers = {
        host        = var.host_addr
        file        = var.remote_file
        local_path  = abspath(var.local_path)
    }

    provisioner "local-exec" {
        command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.private_key_path} ${var.user}@${self.triggers.host}:${self.triggers.file} ${self.triggers.local_path}"
    }

    provisioner "local-exec" {
        when = destroy
        command = "rm -f ${self.triggers.local_path}"
        on_failure  = continue
    }   
}

resource "time_sleep" "wait_after_dl" {
    depends_on  = [null_resource.file_dl]
    destroy_duration = "1s"
}

data "local_file" "downloaded_file" {
    depends_on  = [time_sleep.wait_after_dl]
    filename    = abspath(var.local_path)
}