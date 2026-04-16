#!/bin/sh
# Extract kubeconfig for authentik outpost service connection
# Run with: kubectl config use-context <cluster> && ./get-kubeconfig.sh

NAMESPACE=default
SECRET_NAME=authentik
KUBE_API=$(kubectl config view --minify --output jsonpath="{.clusters[*].cluster.server}")
KUBE_CA=$(kubectl -n "$NAMESPACE" get secret/"$SECRET_NAME" -o jsonpath='{.data.ca\.crt}')
KUBE_TOKEN=$(kubectl -n "$NAMESPACE" get secret/"$SECRET_NAME" -o jsonpath='{.data.token}' | base64 --decode)

cat <<EOF
apiVersion: v1
kind: Config
clusters:
- name: default-cluster
  cluster:
    certificate-authority-data: ${KUBE_CA}
    server: ${KUBE_API}
contexts:
- name: default-context
  context:
    cluster: default-cluster
    namespace: ${NAMESPACE}
    user: authentik-user
current-context: default-context
users:
- name: authentik-user
  user:
    token: ${KUBE_TOKEN}
EOF
