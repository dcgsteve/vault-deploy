#!/bin/bash

####################################################################
# This script only needs to be run once when a new Vault is deployed
####################################################################

#####################################################
# Register plugin
#####################################################
vault plugin register -sha256=ddaef75e7b7653e34e8b5efebe6253381a423428b68544cd79149deaff8b5f4e -command=vault-secrets-gen secret secrets-gen

#####################################################
# Ensure plugin can lock to memory
#####################################################
docker exec vault setcap cap_ipc_lock=+ep /vault/plugins/vault-secrets-gen

#####################################################
# Enable a default path "gen" for the secrets plugin
#####################################################
vault secrets enable -path="gen" -plugin-name="secrets-gen" plugin 
