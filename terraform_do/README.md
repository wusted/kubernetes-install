# This Repo is for Terraform setup for usage with Digital Ocean

# Requirements:
1. Get DO Personal Token from Digital Ocean Web UI.
2. Create or have an SSH Key Pair, 
Public Key will be imported to Digital Ocean. 
Private Key should remain in Client.

1. Create Local Env Variable with 
"TF_VAR" prefix for Terraform to import it.

```
$ export TF_VAR_do_path="replacewithDOPersonalKey"
```

2. Init and Plan to check Settings 
for SSH Key for Droplets and DO Token

```
$ terraform init
$ terrform plan
```

3. Apply to import SSH Key and create resources

```
$ terraform apply
```
