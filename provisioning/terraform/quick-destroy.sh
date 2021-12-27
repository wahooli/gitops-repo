#!/bin/bash
terraform state rm module.k3s_cluster.module.sops_gpg
terraform state rm module.k3s_cluster.module.flux.kubernetes_secret.main
terraform destroy -target module.k3s_cluster.module.flux.github_repository_deploy_key.flux -auto-approve
terraform destroy -target module.k3s_cluster.module.flux.tls_private_key.github_deploy_key -auto-approve

terraform destroy -target module.k3s_cluster.module.flux.github_repository_file.install -auto-approve
terraform destroy -target module.k3s_cluster.module.flux.github_repository_file.kustomize -auto-approve
terraform destroy -target module.k3s_cluster.module.flux.github_repository_file.sync -auto-approve
terraform state rm module.k3s_cluster.module.flux
terraform destroy -auto-approve