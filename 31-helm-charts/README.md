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

5. Create our chart 
- This is going to create a directory with a directory structure inside, for charts, chart configuration, templates, and `values.yaml`
- The chart contains default settings for an example nginx app, this can be modified as needed.
```
$ helm create jeanchart
$ ls
$ brew install tree
$ tree jeanchart/
```

6. Check what is going to be installed with this chart

- This will all the manifests inside the helm chart.
- All this is based on the contents of the ./templates directory.
```
$ helm --kubeconfig kubeconfig.yaml install --dry-run debug ./jeanchart | less
```

7. Modify a template .yaml file

- First, edit the values.yaml
```
$ cd jeanchart
$ vim values.yaml

## Add a new section, below resources and above autoscaling.
--
healthcheck:
  readinessProbe:
    path: /readiness
    port: http
  livenessProbe:
    path: /liveness
    port: http
--
```

- Then reference that values.yaml section in the template.
```
$ cd jeanchart/templates
$ vim deployment.yaml 

## Edit the deployment .spec.template.spec.containers.livenessProbe and .spec.template.spec.containers.readinessProbe
--
livenessProbe:
  httpGet:
    path: {{ .Values.healthcheck.livenessProbe.path }}
    port: {{ .Values.healthcheck.livenessProbe.port }}
readinessProbe:
  httpGet:
    path: {{ .Values.healthcheck.livenessProbe.path }}
    port: {{ .Values.healthcheck.livenessProbe.port }}
--
```

- It is a good practice to run this check (syntax check) after making a change.
```
$ cd ../../ # to the 31-helm-charts Git Repo
$ helm --kubeconfig kubeconfig.yaml lint jeanchart/
```

- Dry run debug to make sure that the values changed in the deployment.yaml
```
$ helm --kubeconfig kubeconfig.yaml install --dry-run debug ./jeanchart | less
```

---

8. We can also create our own Helm Repo with this chart, hosted in Github and share it with anyone.



====
Helm is a great tool for...  
Other Helm Features include:
- 
- 
- 
- 
