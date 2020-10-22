#!/bin/bash

# The following deploys out a basic Vault instance based on filesystem storage (into Docker volumes)
#
# It will deliberately destory any existing Vault instance - you have been warned !
#
# Notes:
# - password generator plugin is installed
# - GUI is disabled
# - memory lock is enabled

###################################################################################
# Check if Vault CLI is available
###################################################################################
command -v vault >/dev/null 2>&1 || { echo >&2 "Hashicorp Vault CLI needs to be installed - check out helper script 'getvault.sh'. Aborting."; exit 1; }

###################################################################################
# Options
###################################################################################
HELPER_FILES_DIR=~/vault
URL=127.0.0.1

###################################################################################
# Main script
###################################################################################
echo ==============================================================================
echo Stopping and destroying any existing Vault ...
docker stop vault
docker rm vault
docker volume rm vault-config
docker volume rm vault-data
docker volume rm vault-logs
docker volume rm vault-policies

echo ==============================================================================
echo Starting fresh Vault ...
docker run -d \
  --name vault \
  --restart unless-stopped \
  --cap-add IPC_LOCK \
  -p 8888:8888 \
  -e 'VAULT_LOCAL_CONFIG={"backend": {"file": {"path": "/vault/file"}}, "listener": {"tcp": {"address": "0.0.0.0:8888", "tls_disable": 1}}, "ui": 0, "default_lease_ttl": "168h", "max_lease_ttl": "720h", "plugin_directory": "/vault/plugins"}' \
  -e 'VAULT_ADDR=http://0.0.0.0:8888' \
  -e 'VAULT_API_ADDR=http://0.0.0.0:8888' \
  -v vault-config:/vault/config \
  -v vault-policies:/vault/policies \
  -v vault-data:/vault/data \
  -v vault-logs:/vault/logs \
  -v vault-certs:/vault/certs \
  dcgsteve/vault:002 server

export VAULT_ADDR=http://${URL}:8888

echo ==============================================================================
echo Pause for Vault to come up ...
sleep 1

echo ==============================================================================
echo "Initialising Vault ..."
mkdir -p $HELPER_FILES_DIR
vault operator init > $HELPER_FILES_DIR/vault-info

echo ==============================================================================
echo "Writing out developer helper files ..."
echo "  vault-env     = environment variables"
echo "  vault-unseal  = unseal script"
echo "  vault-info    = full key and token info for Vault"
echo "  vault-plugins = enable use of secrets plugin"
echo ""
echo "Obviously these helper files are only for development not for production !"

echo export VAULT_ADDR=http://${URL}:8888 > $HELPER_FILES_DIR/vault-env
echo export VAULT_TOKEN=$( cat $HELPER_FILES_DIR/vault-info | grep 'Initial Root Token' | awk -F ' ' '{print $4}' ) >> $HELPER_FILES_DIR/vault-env

echo vault operator unseal $( cat $HELPER_FILES_DIR/vault-info | grep 'Unseal Key 1' | awk -F ' ' '{print $4}' ) > $HELPER_FILES_DIR/vault-unseal
echo vault operator unseal $( cat $HELPER_FILES_DIR/vault-info | grep 'Unseal Key 2' | awk -F ' ' '{print $4}' ) >> $HELPER_FILES_DIR/vault-unseal
echo vault operator unseal $( cat $HELPER_FILES_DIR/vault-info | grep 'Unseal Key 3' | awk -F ' ' '{print $4}' ) >> $HELPER_FILES_DIR/vault-unseal

echo vault plugin register -sha256="ddaef75e7b7653e34e8b5efebe6253381a423428b68544cd79149deaff8b5f4e" -command="vault-secrets-gen" secret secrets-gen > $HELPER_FILES_DIR/vault-plugins
echo docker exec vault setcap cap_ipc_lock=+ep /vault/plugins/vault-secrets-gen >> $HELPER_FILES_DIR/vault-plugins

chmod u+x $HELPER_FILES_DIR/vault-unseal
chmod u+x $HELPER_FILES_DIR/vault-plugins

ls -l $HELPER_FILES_DIR

echo ==============================================================================
echo Done
