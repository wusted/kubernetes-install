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

- Create and new repo in github.com/wusted/ named "helm-chart"
```
from 31-helm-charts $ mkdir ../../helm-chart
$ cd ../
$ cp -r 31-helm-charts/jeanchart ../helm-chart
$ cd ../helm-chart

$ echo "Use this with: https://github.com/wusted/kubernetes-install/tree/main/31-helm-charts" >> README.md
$ git init
$ git add .
$ git commit -m "Helm Chart Repo Example"
$ git branch -M main
$ git remote add origin https://github.com/wusted/helm-chart.git
$ git push -u origin main
```

- Go to https://github.com/wusted/helm-chart
Then, to the "Settings" section, under code and automation go to "Pages". Set "main" branch and save.

- Wait for "job" build and deploy to complete in "Actions"
- Back in pages the URL for this case is https://wusted.github.io/helm-chart/

- Package the chart from the new Git Repo.
```
$ helm package jeanchart/
$ mkdir charts
$ mv jeanchart-0.1.0.tgz charts
$ tree
```

- Create an index for the helm client to know which charts are in this repo.
- This index will check for all the .tgz files in charts/ and create a list with those charts for the repo.
```
$ helm repo index .
$ less index.yaml
```

9. Sync with git
```
$ git add .
$ git commit -m "Helm Chart Repo Example"
$ git push -u origin main
```

====
Helm is a great tool for...  
Other Helm Features include:
- 
- 
- 
- 
