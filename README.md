# vault-deploy

## WARNINGS
- This script will deliberately destroy **any** previous container spun up under the name of `vault` along with any associated data

- This script is not for production use, although it could be used as basis of single server production deployment provided you remove the *helper* files and handle the management of the
security keys in a more secure manner

- Note that the container needs to stop memory from being written to disk so uses IPC_LOCK capability; this is possible to override by changing the Vault config but is **not** recommended.
___
## Pre-requisites
A working install of Docker should be available on the host configured so that the current user can deploy out new containers.

___
## Step 1 - Make sure Vault CLI is installed on host
This script utilises the Vault CLI in order to configure the initial install. Please follow the installation notes (https://www.vaultproject.io/docs/install) or if you using a Debian based OS you can use the included helper script `vault-install-cli.sh`

___
## Step 2 - Deploy out the Vault container and data volumes
Review the script `vault-create.sh` and make sure that the options are set correctly for your specific deployment. If you are installing on a local dev machine then the defaults will probably be fine - but it is recommended to check through anyway.

When happy, run the script.

When finished, the script will have deployed out several "helper" scripts etc. to the directory you specified in the script (I.E. `HELPER_FILES_DIR`)

___
## Step 3 -  Vault post-configuration
### *Setting up your environment*
Provided the script ran correctly, you should be able to see the new Vault container up and running in Docker. In order to run commands against this vault it is suggested to create two environment variables - one for the location of the vault and the other for the root token that gives you admin authority of the vault. 
As this is a dev-type script, then simply running `source ~/vault/vault-env` will set your environment up for you. You can check whether everything has worked correctly by running the command `vault status`. You should see something like this returned:
```
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    0/3
Unseal Nonce       n/a
Version            1.5.3
HA Enabled         false
```

### *Unsealing the Vault*
As you can see though from the test done above, the Vault is still currently sealed (see https://www.vaultproject.io/docs/concepts/seal for detail on the concept behind this) and needs to be unsealed. Normally in production this would be carefully managed across multiple people but for the purposes of this dev-based script you will find another helper script to do this for you, I.E. `vault-unseal`

Running this will call Vault three times, each time using a different master key. once three keys have been entered the Vault is unsealed. Run the `vault status` command again to check (you should see the `sealed` line now showing false.)

___
## Examples

See examples.md for some basic usage examples once you have Vault up and running

___
