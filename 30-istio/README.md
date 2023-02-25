## Service Mest Networking Manager with Istio

Ref: https://istio.io/latest/docs/

- All resources are provisioned with Terraform.
- Kubernetes Cluster
- Cloud Provisioner: Digital Ocean
- 

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

4. Install istioctl on client
Ref: https://istio.io/latest/docs/setup/getting-started/#download

```
$ curl -L https://istio.io/downloadIstio | sh -

$ cd istio-1.17.1/

$ export PATH=$PWD/bin:$PATH

$ istioctl --kubeconfig kubeconfig.yaml x precheck
```

5. Install "istio" with "istioctl"

```
$ istioctl --kubeconfig kubeconfig.yaml install --set profile=demo -y

$ kubectl --kubeconfig kubeconfig.yaml get ns

$ kubectl --kubeconfig kubeconfig.yaml get all -n istio-system

$ kubectl --kubeconfig label namespace default istio-injection=enabled

$ kubectl --kubeconfig kubeconfig.yaml get ns --selector=istio-injection=enabled
```