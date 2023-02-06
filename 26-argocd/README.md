## Continuous Delivery/Continuous Deployment with ArgoCD in Kubernetes

Ref: https://argo-cd.readthedocs.io/en/stable/

- All resources are provisioned with Terraform.
- Kubernetes Cluster
- Cloud Provisioner: Digital Ocean
- ArgoCD Kubernetes Operator CRD

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
 
4. Create Argo Namespace and Deploy the CRD:
```
$ kubectl --kubeconfig kubeconfig.yaml create ns argocd
$ kubectl --kubeconfig kubeconfig.yaml -n argocd apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

$ kubectl --kubeconfig kubeconfig.yaml -n argocd get -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

- Install ArgoCD CLI Tool
```
$ brew install argocd
```

5. Access the ArgoCD API Server.
3 Different Options:
    - Service Type LoadBalancer
    - Ingress
    - Port Forward

For this example, I will use Port Forward.  
In another terminal, run:
```
$ kubectl --kubeconfig kubeconfig.yaml port-forward svc/argocd-server -n argocd 8080:443
```

API can then be accessed using localhost:8080


6. Get the ArgoCD "admin" initial password, and change it.
```
$ kubectl --kubeconfig kubeconfig.yaml -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# Replace ARGOCD_SERVER with IP or hostname, in this case localhost since port-forward is used.
$ argocd login <ARGOCD_SERVER>

$ argocd account update-password
```

- An optional External Cluster can be defined, check the ArgoCD documentation for that.

- Now login to the Web Browers with "admin" user in localhost:8080 using the new password.

- The secret can be deleted as its only purpose is to store the initial password.
```
$ kubectl --kubeconfig kubeconfig.yaml -n argocd delete secret argocd-initial-admin-secret
```


## For all apps, the repo to be used is https://github.com/argoproj/argocd-example-apps.git
7. Create Guestbook App.
