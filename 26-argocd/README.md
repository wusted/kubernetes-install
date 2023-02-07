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
$ kubectl --kubeconfig kubeconfig.yaml apply -f 03-guestbook-app.yaml
$ kubectl --kubeconfig kubeconfig.yaml get -f 03-guestbook-app.yaml

- Manually Sync the app as ArgoCD will not do it automatically:

GUI: Just go to the Project Main page and click "Sync" in the Application.

OR,

CLI:
$ argocd app get guestbook
$ argocd app sync guestbook  # Enable auto-sync can be set in the UI inside of the App > App Details.

In both outputs a list of the Kubernetes Resources from the Source(Manifest file, Helm Chart, Kustomize Apps, etc.)  
In the GUI a display chart of the Source Dependencies and Components from the Kubernetes Cluster can be visualized.  


$ kubectl --kubeconfig kubeconfig.yaml get apps -n argocd
$ kubectl --kubeconfig kubeconfig.yaml describe apps -n argocd guestbook
$ kubectl --kubeconfig kubeconfig.yaml get svc,deploy,ep -n kube-system guestbook-ui

# Delete the Application.
- Can be performed from GUI or CLI

$ argocd app delete guestbook
```


7. Create Guestbook App from Helm Chart.
```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 04-guestbook-helm-app.yaml
$ kubectl --kubeconfig kubeconfig.yaml get -f 04-guestbook-helm-app.yaml

- Manually Sync the app as ArgoCD will not do it automatically:

GUI: Just go to the Project Main page and click "Sync" in the Application.

OR,

CLI:
$ argocd app get guestbook-helm
$ argocd app sync guestbook-helm  # Enable auto-sync can be set in the UI inside of the App > App Details.

In both outputs a list of the Kubernetes Resources from the Source(Manifest file, Helm Chart, Kustomize Apps, etc.)  
In the GUI a display chart of the Source Dependencies and Components from the Kubernetes Cluster can be visualized.  
Also from the GUI inside of the App > App Details > Parameters, the values.yaml of the Repo can be reviewed.

$ kubectl --kubeconfig kubeconfig.yaml get apps -n argocd
$ kubectl --kubeconfig kubeconfig.yaml describe apps -n argocd guestbook-helm
$ kubectl --kubeconfig kubeconfig.yaml get svc,deploy,ep -n kube-system guestbook-helm-helm-guestbook

# Delete the Application
- Can be performed from GUI or CLI

$ argocd app delete guestbook-helm
```

8. ArgoCD allows the installation of Helm Charts on top of already existing Helm Charts to add Services.
- values.yaml needs to have indented the values of the new helm chart. This helm chart uses the base of a helm template and adds WordPress to the Repo.

```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 05-wordpress-helm-app.yaml
$ kubectl --kubeconfig kubeconfig.yaml get -f 05-wordpress-helm-app.yaml

- Manually Sync the app as ArgoCD will not do it automatically:

GUI: Just go to the Project Main page and click "Sync" in the Application.

OR,

CLI:
$ argocd app get wordpress-helm
$ argocd app sync wordpress-helm # Enable auto-sync can be set in the UI inside of the App > App Details.

In both outputs a list of the Kubernetes Resources from the Source(Manifest file, Helm Chart, Kustomize Apps, etc.)
In the GUI a display chrt of the Source Dependencies and Components from the Kubernetes Cluster can be visualized.
Also from the GUI inside of the App > App Details > Parameters, the values.yaml of the Repo can be reviewed.

# For this Sync it will take a while, since "service/wordpress-helm" creates a LoadBalancer in CloudProvisioner.

$ kubectl --kubeconfig kubeconfig.yaml get apps -n argocd
$ kubectl --kubeconfig kubeconfig.yaml describe apps -n argocd wordpress-helm
$ kubectl --kubeconfig kubeconfig.yaml get svc,deploy,ep -n kube-system 
$ kubectl --kubeconfig kubeconfig.yaml get all -n kube-system | grep wordpress


# Delete the Application
- Can be performed from GUI or CLI

$ argocd app delete wordpress-helm
```


9. A bundle of apps can be set in a Git Repo and created in an ArgoCD Application:
- Useful for bootstraping a cluster with all of the apps/services needed to start working.

```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 06-argo-apps.yaml
$ kubectl --kubeconfig kubeconfig.yaml get -f 06-argo-apps.yaml

- Manually Sync the app as ArgoCD will not do it automatically:

GUI: Just go to the Project Main page and click "Sync" in the Application.

OR,

CLI:
$ argocd app get argocd-apps
$ kubectl --kubeconfig kubeconfig.yaml get apps -n argocd
$ argocd app sync argocd-apps # Enable auto-sync can be set in the UI inside of the App > App Details.
$ argocd app sync helm-guestbook
$ argocd app sync helm-hooks
$ argocd app sync kustomize-guestbook
$ argocd app sync sync-waves


In both outputs a list of the Kubernetes Resources from the Source(Manifest file, Helm Chart, Kustomize Apps, etc.)
In the GUI a display chrt of the Source Dependencies and Components from the Kubernetes Cluster can be visualized.
Also from the GUI inside of the App > App Details > Parameters, the values.yaml of the Repo can be reviewed.

$ kubectl --kubeconfig kubeconfig.yaml get apps -n argocd
$ for i in argocd-apps helm-guestbook helm-hooks kustomize-guestbook sync-waves; do kubectl --kubeconfig kubeconfig.yaml describe apps -n argocd $i ; done | less


$ kubectl --kubeconfig kubeconfig.yaml get ns
$ for i in kube-system helm-guestbook helm-hooks kustomize-guestbook sync-waves; do kubectl --kubeconfig kubeconfig.yaml get all -n $i; done | less
$ kubectl --kubeconfig kubeconfig.yaml get all --all-namespaces | egrep -i 'kube-system|helm-guestbook|helm-hooks|kustomize-guestbook|sync-waves|namespace' | less


# Delete the Application
- Can be performed from GUI or CLI

$ argocd app delete argocd-apps
```