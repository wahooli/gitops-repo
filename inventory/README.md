# How to provision hosts
Create connection-password.txt in repo root and add password for the user you're using for configuration step.  
`ansible-playbook -e 'ansible_user=root' --connection-password-file=connection-password.txt wahooli.common.configure_hosts -i inventory/vm/`
`-e 'ansible_user=root'` overrides the username provided by inventory

Next you can run the create cluster playbook or whichever you like
To update secrets, run following  
`ansible-playbook wahooli.common.turingpi_create_cluster -i inventory/vm/`