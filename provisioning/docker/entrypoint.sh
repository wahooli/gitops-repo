#!/bin/bash
user="${DNS_USER}@${DNS_REALM}"
pass="${DNS_PASS}"
keytab_output=${KEYTAB_PATH:-/workdir/outputs/pk}
keytab_file="${keytab_output}/${DNS_USER}.keytab"
method="aes256-cts-hmac-sha1-96"

if [ ! -f "${keytab_file}" ]; then
    echo "Generating keytab file."
    /usr/bin/ktutil <<EOF
addent -password -p $user -k 1 -e $method
$pass
write_kt $keytab_file
q
EOF
fi