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
    }
    required_version = ">= 1.0"
}