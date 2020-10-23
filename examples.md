Please note that any examples below that are given using the vault CLI can all also be performed via API calls. Check out https://www.vaultproject.io/api for further information.

# Examples Index <!-- omit in toc -->
- [Check out what secrets engines are enabled](#check-out-what-secrets-engines-are-enabled)
- [Create simple key/value storage for a project](#create-simple-keyvalue-storage-for-a-project)
- [Simple write of data to key-value store for project](#simple-write-of-data-to-key-value-store-for-project)
- [Get my-secret back](#get-my-secret-back)
- [Get just the value of 'foo' secret back via JSON](#get-just-the-value-of-foo-secret-back-via-json)
- [Get back a non-user generated password to use and store in a variable using API directly](#get-back-a-non-user-generated-password-to-use-and-store-in-a-variable-using-api-directly)


___
## Check out what secrets engines are enabled
`vault secrets list`

```
Path          Type           Accessor                Description
----          ----           --------                -----------
cubbyhole/    cubbyhole      cubbyhole_97ede3af      per-token private secret storage
identity/     identity       identity_e023da0e       identity store
sys/          system         system_4592c9a3         system endpoints used for control, policy and debugging
```
___
## Create simple key/value storage for a project
`vault secrets enable -path=/project1 kv`
```
Success! Enabled the kv secrets engine at: /project1/
```
___
## Simple write of data to key-value store for project
`vault write project1/my-secret foo=bar`
```
Success! Data written to: project1/my-secret
```
___
## Get my-secret back
`vault read project1/my-secret`
```
Key                 Value
---                 -----
refresh_interval    168h
foo                 bar
```

___
## Get just the value of 'foo' secret back via JSON
`vault read -format json project1/my-secret | jq -r .data.foo`
```
bar
```

___
## Get back a non-user generated password to use and store in a variable using API directly

In order to do this you need to create your password policy first to ensure that the generated password meets your specific rules.

An example policy.json could be:
```json
{ "policy": "length=20\n\nrule \"charset\" {\n  charset = \"abcdefghijklmnopqrstuvwxyz\"\n  min-chars = 1\n}\n\nrule \"charset\" {\n  charset = \"ABCDEFGHIJKLMNOPQRSTUVWXYZ\"\n  min-chars = 1\n}\n" }
```

To use this JSON file and create the policy you could:
```bash
curl -s \
    --header "X-Vault-Token: ${VAULT_TOKEN}" \
    --request PUT \
    --data @policy.json \
    ${VAULT_ADDR}/v1/sys/policies/password/myproject
```

Once the policy is in place you can then generate a password from it:

```bash
curl -s --header "X-Vault-Token: ${VAULT_TOKEN}" \
  ${VAULT_ADDR}/v1/sys/policies/password/myproject/generate \
  | jq -r .data.password
```

Once you have the password you could, if you wanted to, write it back in to an existing KV store in Vault:

```bash
curl -s \
  --header "X-Vault-Token: $VAULT_TOKEN" \
  --request "PUT" \
  --data '{ "mysecret": "'"${MyPassword}"'" }' ${VAULT_ADDR}/v1/myproject/info
```