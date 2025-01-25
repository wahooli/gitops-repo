#!/bin/bash
rm -f /etc/postfix/{ldap-groups.cf,ldap-domains.cf,relayhost_map,sasl_passwd}
cp /tmp/docker-mailserver/postfix-relaymap.cf /etc/postfix/relayhost_map
cp /tmp/docker-mailserver/postfix-sasl-password.cf /etc/postfix/sasl_passwd
chown root:root /etc/postfix/{relayhost_map,sasl_passwd}
chmod 0600 /etc/postfix/{relayhost_map,sasl_passwd}

# default relayhost = DUNNO should bounce emails if relayhost isn't mapped to sender domain
postconf \
    "smtp_sasl_password_maps = texthash:/etc/postfix/sasl_passwd" \
    "sender_dependent_relayhost_maps = texthash:/etc/postfix/relayhost_map" \
    "smtpd_sasl_auth_enable = yes" \
    "smtp_sasl_auth_enable = yes" \
    "relayhost = DUNNO" \
    "mydestination = localhost" \
    "smtp_sasl_security_options = noanonymous" \
    "smtp_tls_security_level = encrypt" \
    "smtp_sender_dependent_authentication = yes" \
    "virtual_mailbox_domains = /etc/postfix/vhost" \
    "virtual_alias_maps = texthash:/etc/postfix/virtual"

sed -i /etc/postfix/ldap-senders.cf \
    -e '/result_format/d' \
    -e '/result_attribute/d'
cat <<EOF >> /etc/postfix/ldap-senders.cf
result_attribute = uid
result_format = %s@default.svc.cluster.local
EOF
postfix reload
