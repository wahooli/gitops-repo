terraform {
    required_providers {
        kubectl = {
            source  = "gavinbunney/kubectl"
            version = ">= 1.13.1"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = ">= 2.7.0"
        }
        flux = {
            source  = "fluxcd/flux"
            version = ">= 0.8.0"
        }
        github = {
            source = "integrations/github"
            version = ">= 4.18.2"
        }
    }
    required_version = ">= 1.0"
}