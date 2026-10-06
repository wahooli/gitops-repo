#!/bin/bash
GATEWAY_NAME="vpn-gateway.vpn-gateway.svc.cluster.local"
K8S_DNS_IPS="${cluster_dns_ip}"
NOT_ROUTED_TO_GATEWAY_CIDRS="$(echo "${vpn_gateway_cluster_cidrs:=10.12.0.0/15}" | tr ',' ' ')"
VXLAN_ID="42"
VXLAN_PORT="4789"
VXLAN_IP_NETWORK="172.16.0"
VXLAN_GATEWAY_FIRST_DYNAMIC_IP=20
VPN_INTERFACE_MTU="1320"
