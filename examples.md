# Examples

Please note that although the examples below are given using the vault CLI, they can all also be performed via API calls. Check out https://www.vaultproject.io/api for further information.

___
### Check out what secrets engines are enabled
`vault secrets list`

```
Path          Type           Accessor                Description
----          ----           --------                -----------
cubbyhole/    cubbyhole      cubbyhole_97ede3af      per-token private secret storage
gen/          secrets-gen    secrets-gen_392f375b    n/a
identity/     identity       identity_e023da0e       identity store
sys/          system         system_4592c9a3         system endpoints used for control, policy and debugging
```
___
### Create simple key/value storage for a project
`vault secrets enable -path=/project1 kv`
```
Success! Enabled the kv secrets engine at: /project1/
```
___
### Simple write of data to key-value store for project
`vault write project1/my-secret foo=bar`

___
### Get my-secret back
`vaule read project1/my-secret`
```
Success! Data written to: project1/my-secret
```

___
### Get just the value of 'foo' secret back via JSON
`vault read -format json project1/my-secret | jq .data.foo`
```
"bar"
```

___
### Get back a non-user generated password to use and store in a variable
```bash
#!/bin/bash

MYPASS=$( vault write -format json gen/password length=36 symbols=3 | jq -r .data.value )
echo "My password is: $MYPASS"
```
___
