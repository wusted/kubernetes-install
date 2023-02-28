## Helm Charts with Kubernetes and Github 

Ref: https://helm.sh/docs/topics/charts/

- All resources are provisioned with Terraform.
- Kubernetes Cluster
- Cloud Provisioner: Digital Ocean
- Make sure to havel helm installed in local client.
- Helms charts applies resources in Kubernetes as a Package Manager connecting to Repositories.

1. Add the do_token environment variable for Terraform.
```
$ export TF_VAR_do_token=REPLACE_WITH_TOKEN
```

2. Provision the Cloud Infrastructure with Terraform.
This will create:
- 1 Kubernetes Cluster
- Pull in the "kubeconfig.yaml" file

````
$ terraform init

$ terraform plan

$ terraform apply
````

3. Once created, the access to the K8s Cluster can be tested with:
```
$ kubectl --kubeconfig kubeconfig.yaml get nodes
```

4. Install Helm in client.
```
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
$ helm version
```

5. 

====
Helm is a great tool for...  
Other Helm Features include:
- 
- 
- 
- 
