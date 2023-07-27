SHELL=/bin/bash
AUTO_APPROVE=$(shell [ "`env | grep -c -i ^auto=yes$$`" == "1" ] && echo "-auto-approve")
WS=$(shell terraform workspace show)
CONFIG_FILE="vars.$(WS).yml"
CMD=$(shell echo $@ | cut -d. -f1)
CMD2=$(shell echo $@ | cut -d. -f2)
CMD3=$(shell echo $@ | cut -d. -f3)

ANSIBLE ?= bbb sl gl
TERRAFORM ?= vpc eip vpc-data efs rds cache bbb sl gl

SSH_USER=$(shell yq .ssh.user < $(CONFIG_FILE))
SSH_IDENTITY_FILE=$(shell yq .ssh.key_file < $(CONFIG_FILE))
DOMAIN=$(shell yq .domain < $(CONFIG_FILE))

debug.%:
	echo $(AUTO_APPROVE)
	echo $(CONFIG_FILE)
	echo $(SSH_USER)@$(CMD2).$(DOMAIN)

apply:
	terraform apply $(AUTO_APPROVE)

apply.%:
	terraform apply -target=module.$(CMD2) $(AUTO_APPROVE)

destroy:
	terraform destroy $(AUTO_APPROVE)

destroy.%:
	terraform destroy -target=module.$(CMD2) $(AUTO_APPROVE)

$(ANSIBLE):
	ANSIBLE_CONFIG=./ansible.cfg ansible-playbook $@.yml -i .$@.inv.$(WS).yml -e @.$@.vars.$(WS).yml -vv

fmt:
	terraform fmt -recursive ../..

output.%:
	terraform output $(CMD2)

sl.bbb:
	ANSIBLE_CONFIG=./ansible.cfg ansible-playbook sl.bbb.yml -i .sl.inv.$(WS).yml -e @.sl.vars.$(WS).yml -e @.bbb.secrets.$(WS).yml -vv

sl.tenant:
	ANSIBLE_CONFIG=./ansible.cfg ansible-playbook sl.tenant.yml -i .sl.inv.$(WS).yml -e @.sl.vars.$(WS).yml  -vv

sl.status:
	ssh -i $(SSH_IDENTITY_FILE) -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ServerAliveInterval=120 -o ServerAliveCountMax=2 $(SSH_USER)@sl.$(DOMAIN) sudo docker exec -t scalelite-api bin/rails status

sl.tenant.status:
	ssh -i $(SSH_IDENTITY_FILE) -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ServerAliveInterval=120 -o ServerAliveCountMax=2 $(SSH_USER)@sl.$(DOMAIN) sudo docker exec -t scalelite-api bin/rails tenants


sl.enable.%:
	ssh -i $(SSH_IDENTITY_FILE) -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ServerAliveInterval=120 -o ServerAliveCountMax=2 $(SSH_USER)@sl.$(DOMAIN) sudo docker exec -t scalelite-api bin/rails servers


ssh.%:
	ssh -i $(SSH_IDENTITY_FILE) -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ServerAliveInterval=120 -o ServerAliveCountMax=2 $(SSH_USER)@$(CMD2).$(DOMAIN)
