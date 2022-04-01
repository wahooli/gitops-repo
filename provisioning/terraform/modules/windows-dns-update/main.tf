provider "dns" {
    update {
        server = var.nameserver # Using the hostname is important in order for an SPN to match
        gssapi {
            realm    = var.realm
            username = var.username
            keytab   = var.keytab_file
        }
    }
}

resource "dns_a_record_set" "windows_dns_record" {
    for_each = {for i, record in var.a_records : i => record}
    zone = each.value.zone
    name = each.value.name
    addresses = each.value.addresses
    ttl = each.value.ttl
}