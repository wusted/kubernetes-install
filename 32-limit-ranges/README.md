## Limit Range in Kubernetes

Ref: https://kubernetes.io/docs/concepts/policy/limit-range/

- All resources are provisioned with Terraform.
- Kubernetes Cluster
- Cloud Provisioner: Digital Ocean
- Limit Range enables management of default resource allocation for NEW pods, containers and PersistentVolumeClaims per Kubernetes Namespace.

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

4. Create a Pod without Resource Limits or Requests.

5. Apply the LimitRange and create a Pod without Resource Limits or Requests.

6. Create Pod with a bigger Resource Request than the Limit Range

===
LimitRanges is a great object for ...
Other LimitRange features include:
- 
- 