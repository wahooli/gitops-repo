#!/bin/bash
terraform state rm module.k3s_cluster.module.fluxcd.kubernetes_secret.hass_deploy_key
terraform state rm module.k3s_cluster.module.sops_gpg.null_resource.sops_gpg_secret
terraform state rm module.k3s_cluster.module.fluxcd.kubernetes_secret.main
terraform destroy -target "module.k3s_cluster.module.fluxcd.github_repository_deploy_key.flux" -auto-approve
terraform destroy -target "module.k3s_cluster.module.fluxcd.github_repository_file.install" -auto-approve
terraform destroy -target "module.k3s_cluster.module.fluxcd.github_repository_file.kustomize" -auto-approve
terraform destroy -target "module.k3s_cluster.module.fluxcd.github_repository_file.sync" -auto-approve
terraform destroy -target "module.k3s_cluster.module.fluxcd.github_repository_file.patches[\"deployments\"]" -auto-approve
terraform destroy -target "module.k3s_cluster.module.fluxcd.tls_private_key.github_deploy_key" -auto-approve
terraform state rm module.k3s_cluster.module.fluxcd
terraform destroy -auto-approve