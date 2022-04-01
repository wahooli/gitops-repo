terraform {
    required_providers {
        dns = {
            source = "hashicorp/dns"
            version = ">= 3.2.3"
        }
    }
    required_version = ">= 1.0"
}