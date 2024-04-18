# Kubernetes clusters repo
Readme will be updated later, maybe

## How to's
Include repo githooks
`git config core.hooksPath .githooks/`

Ensure you have ansible-vault installed  
Create file `vault-password.txt` into repo root, containing the decryption key for inventory  
To decrypt values run post commit hook  
`.githooks/post-checkout`

Install ansible collection  
`ansible-galaxy collection install git@github.com:wahooli/ansible-collection-common.git`

To fetch kubeconfig  
`ansible-playbook wahooli.common.fetch_kubeconfig -i inventory/vm/`  
this creates output path into repo root, which contains kubeconfig. do whatever you want with it, ie. `export KUBECONFIG="$(pwd)/output/kubeconfig"`

To update secrets, run following  
`ansible-playbook wahooli.common.update_cluster_secrets -i inventory/vm/`