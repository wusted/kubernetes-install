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

## For all GitOps application, the source repo to be used is https://github.com/argoproj/argocd-example-apps.git
- To get the corresponding apiVersion to be used in Applications manifests, run:
```
$ kubectl --kubeconfig kubeconfig.yaml api-versions | grep argo
```

7. Create Guestbook App from Kubernetes Manifest.
```
$ kubectl --kubeconfig kubeconfig apply -f 03-guestbook-app.yaml

- Manually Sync the app as ArgoCD will not do it automatically:

GUI: Just go to the Project Main page and click "Sync" in the Application.

OR,

CLI:
$ argocd app get guestbook
$ argocd app sync guestbook  # Enable auto-sync can be set in the UI inside of the App > App Details.

In both outputs a list of the Kubernetes Resources from the Source(Manifest file, Helm Chart, Kustomize Apps, etc.)  
In the GUI a display chart of the Source Dependencies and Components from the Kubernetes Cluster can be visualized.  


$ kubectl --kubeconfig kubeconfig.yaml get apps -n argocd
$ kubectl --kubeconfig kubeconfig.yaml describe apps -n argocd
$ kubectl --kubeconfig kubeconfig.yaml get svc,deploy,ep -n kube-system guestbook-ui

# Delete the Application.
- Can be performed from GUI or CLI

$ argocd app delete guestbook
```


7. Create Guestbook App from Helm Chart.
```
$ kubectl --kubeconfig kubeconfig apply -f 04-guestbook-helm-app.yaml

- Manually Sync the app as ArgoCD will not do it automatically:

GUI: Just go to the Project Main page and click "Sync" in the Application.

OR,

CLI:
$ argocd app get guestbook
$ argocd app sync guestbook  # Enable auto-sync can be set in the UI inside of the App > App Details.

In both outputs a list of the Kubernetes Resources from the Source(Manifest file, Helm Chart, Kustomize Apps, etc.)  
In the GUI a display chart of the Source Dependencies and Components from the Kubernetes Cluster can be visualized.  
Also from te GUI inside of the App > App Details > Parameters, the values.yaml of the Repo can be reviewed.

$ kubectl --kubeconfig kubeconfig.yaml get apps -n argocd
$ kubectl --kubeconfig kubeconfig.yaml describe apps -n argocd
$ kubectl --kubeconfig kubeconfig.yaml get svc,deploy,ep -n kube-system guestbook-helm-guestbook
```

8. ArgoCD allows to apply Helm Charts in top of already existing Helm Charts to add Services.
