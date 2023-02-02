# Nginx Ingress with Load Balancer and Cert-Manager
- All resources are provisioned with Terraform including K8s Cluster.
- Cloud Provisioner is Digital Ocean
- Kubernetes Ingress is Nginx
- Replace with Domain needed at the moment
- LoadBalancer created with Kubernetes Service
- Let's Encrypt for Certificate Provisioning.

1. Add the do_token enviroment variable for Terraform.
```
$ export TF_VAR_do_token=REPLACE_WITH_TOKEN
```

2. Provision the Cloud Infrastructure with Terraform.
This will create:
- 1 Kubernetes Cluster
- Pull in kubeconfig.yaml file
- 1 DNS and 1 A Record

```
$ terraform init

$ terraform plan

$ terraform apply
```

3. Once created the access to the K8s Cluster can be tested with:
```
$ kubectl --kubeconfig kubeconfig.yaml get nodes
```

