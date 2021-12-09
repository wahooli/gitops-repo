module "kubeconfig_dl" {
    source = "../remote-file-download"
    sleep_before        = "0s"
    user                = var.user
    host_addr           = var.host_addr
    remote_file         = var.remote_file
    local_path          = var.local_path
    private_key_path    = var.private_key_path
}

locals {
    depends_on = [module.kubeconfig_dl]
    content                 =  yamldecode(module.kubeconfig_dl.content)
    host                    = "${local.content["clusters"]["0"]["cluster"]["server"]}"
    cluster_ca_certificate  = "${base64decode(local.content["clusters"]["0"]["cluster"]["certificate-authority-data"])}"
    client_certificate      = "${base64decode(local.content["users"]["0"]["user"]["client-certificate-data"])}"
    client_key              = "${base64decode(local.content["users"]["0"]["user"]["client-key-data"])}"
    path                    = module.kubeconfig_dl.filepath
}

# data "null_data_source" "kubeconfig_content" {
#     depends_on = [
#         module.kubeconfig_dl
#     ]
#     inputs = yamldecode(module.kubeconfig_dl.content)
# }

# data "null_data_source" "kubeconfig" {
#     depends_on = [
#         data.null_data_source.kubeconfig_content
#     ]
#     inputs = {
#         cluster_ca_certificate  = "${base64decode(data.null_data_source.kubeconfig_content.outputs["clusters"])}"
#         client_certificate      = "${base64decode(data.null_data_source.kubeconfig_content.outputs["users"])}"
#         client_key              = "${base64decode(data.null_data_source.kubeconfig_content.outputs["users"])}"
#     }
# }