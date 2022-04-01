// Ansible post-provisioning configuration
resource "null_resource" "ansible_playbook" {
    triggers = var.triggers

    // Ansible playbook run - base config
    provisioner "local-exec" {
        when = create
        command = "ansible-playbook -u ${var.user} -i ${abspath(var.inventory_path)} --private-key ${abspath(var.private_key_path)} ${abspath(var.playbook_path)}"
        environment = {
            ANSIBLE_CONFIG = var.config_path
        }
    }
}