# vault-deploy

This script will deliberately destroy **any** previous container spun up under the name of `vault` - you have been warned !

It will then spin up an instance of Vault for general testing and development use, although it could be used as basis of single server production deployment, provided you remove the *helper* files and handle the management of the security keys in a more secure manner!

Note that the container needs to stop memory from being written to disk so uses IPC_LOCK capability; this is possible to override by changing the Vault config but is not recommended.


Additional steps done:

- password generator plugin is installed
- GUI is disabled
- memory lock is enabled
