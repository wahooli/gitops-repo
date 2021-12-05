resource "null_resource" "sops_gpg_secret" {
    triggers = {
        namespace   = var.namespace
        kubeconfig  = var.kubeconfig_path
        key_fp      = var.key_fp
        secret_name = var.secret_name
    }

    provisioner "local-exec" {
        command = "gpg --export-secret-keys --armor \"${self.triggers.key_fp}\" | kubectl --kubeconfig ${self.triggers.kubeconfig} create secret generic ${self.triggers.secret_name} --namespace ${self.triggers.namespace} --from-file=sops.asc=/dev/stdin"
    }

    provisioner "local-exec" {
        when       = destroy
        command    = "kubectl --kubeconfig ${self.triggers.kubeconfig} delete secret ${self.triggers.secret_name}"
    }
}