## Thanos Metric for Prometheus
- For this we will need at least 2 Kubernetes clusters.
- I will setup: 2 Cloud DigitalOcean Kubernetes Cluster with Terraform. (This can be adapted to mostly of Cloud Providers)

1. Local cluster already set, need to set the DigitalOcean Cluster
```
$ export TF_VAR_do_token=[replace_with_token_value]

$ terraform init

$ terraform plan

$ terraform apply
```

2. Create the kubeconfig with both contexts

```
# Set the ENV for kubectl to grab it temp.
$ export KUBECONFIG=./jean-1_kubeconfig.yaml:./jean-2_kubeconfig.yaml
$ kubectl config get-contexts

# Merge the contents in a new file.
$ kubectl config view --merge --flatten > thanosconfig.yaml
$ exit

# Without setting the ENV for KUBECONFIG, check both contexts with new config file.
# It should show 2 contexts, one for each cluster
$ kubectl --kubeconfig thanosconfig.yaml config get-contexts
```


3. Install kube-prometheus in both clusters.
- Repeat for any other context/cluster needed.

https://github.com/wusted/kubernetes-install/tree/main/15-kube-prometheus-operator


- Digital Ocean Cluster Number 1 Example
```
## Create the metrics CRDs.
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-1 apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-1 get --raw /apis/metrics.k8s.io
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-1 top pods -n kube-system
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-1 top nodes



## Create the kube-prometheus-operator
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-1 apply -f ./kube-prometheus-operator/manifests/setup --server-side

$ until kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-1 get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-1 wait --for condition=Established --all CustomResourceDefinition --namespace=monitoring

$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-1 apply -f ./kube-prometheus-operator/manifests


$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-1 get pods -n monitoring
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-1 -n monitoring port-forward svc/prometheus-k8s 9090
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-1 -n monitoring port-forward svc/grafana 3000


## Test by going to browser at localhost:9090 and localhost:3000
## User for grafana is admin
## Password for grafana can be: admin or prom-operator

```




- Digital Ocean Cluster Number 2 Example
```
## Create the metrics CRDs.
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-2 apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-2 get --raw /apis/metrics.k8s.io
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-2 top pods -n kube-system
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-2 top nodes


## Create the kube-prometheus-operator
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-2 apply -f ./kube-prometheus-operator/manifests/setup --server-side

$ until kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-2 get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-2 wait --for condition=Established --all CustomResourceDefinition -n monitoring

$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-2 apply -f ./kube-prometheus-operator/manifests

$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-2 get pods -n monitoring
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-2 -n monitoring port-forward svc/prometheus-k8s 9090
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-2 -n monitoring port-forward svc/grafana 3000


## Test by going to browser at localhost:9090 and localhost:3000
## User for grafana is admin
## Password for grafana can be: admin or prom-operator


```



4. Create the S3 Bucket Secret - One Bucket per Cluster  
Create the Bucket on AWS First, and replace parameters values with correct ones.

- Digital Ocean Cluster Number 1 Example
`vim _thanos-objstorage-1.yaml`
```
type: S3
config:
  bucket: "xxxx"
  endpoint: "s3.amazonaws.com"
  region: "us-east-1"
  access_key: "yyyy"
  secret_key: "zzzz"
``` 

- Base64 Encode
`cat _thanos-objstorage-1.yaml | base64`

- Generate Kubernetes Secret
`vim _thanos-objstore-secret-1.yaml`
```
apiVersion: v1
kind: Secret
metadata:
  name: thanos-objectstorage
  namespace: monitoring
  labels:
    app: thanos
type: Opaque
data:
  thanos.yaml: [PLACE_BASE64_S3_OBJ_STORE_HERE]
```
  
  
- Digital Ocean Cluster Number 2 Example
`vim _thanos-objstorage-2.yaml`
```
type: S3
config:
  bucket: "xxxx"
  endpoint: "s3.amazonaws.com"
  region: "us-east-1"
  access_key: "yyyy"
  secret_key: "zzzz"
``` 

- Base64 Encode
`cat _thanos-objstorage-2.yaml | base64`

- Generate Kubernetes Secret
`vim _thanos-objstore-secret-2.yaml`
```
apiVersion: v1
kind: Secret
metadata:
  name: thanos-objectstorage
  namespace: monitoring
  labels:
    app: thanos
type: Opaque
data:
  thanos.yaml: [PLACE_BASE64_S3_OBJ_STORE_HERE]
```


4. Apply the Secrets on the respective cluster.

- Digital Ocean Cluster Number 1 Example
```
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-1 apply -f _thanos-objstore-secret-1.yaml
```

- Digital Ocean Cluster Number 2 Example
```
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-2 apply -f _thanos-objstore-secret-2.yaml
```


5. Add the Thanos sidecar container to the Prometheus Pod in the kube-prometheus operator.
- With different values for the secrets for each cluster.
- This sidecar will be accesing and sharing all of the Prometheus Metrics.
- Reference: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/thanos.md

- Make a copy of the Prometheus pod manifest to the main directory.  
Edit the file to add the Thanos sidecar container.


- Digital Ocean Cluster Number 1 Example
`$ cp ./kube-prometheus-operator/manifests/prometheus-prometheus.yaml ./03-prometheus-prometheus-thanos-digitalocean-cluster-1.yaml`

`vim ./03-prometheus-prometheus-thanos-digitalocean-cluster-1.yaml`
```
## At the end of the file add:
  thanos:
    image: quay.io/thanos/thanos:v0.28.1
    objectStorageConfig:
      key: thanos.yaml
      name: thanos-objectstorage # This is the secret's name created in the cluster from previous step.
    version: v0.28.1
```

- Apply the changes to the Prometheus Pod
```
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-1 apply -f ./03-prometheus-prometheus-thanos-digitalocean-cluster-1.yaml

$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-1 get pods monitoring prometheus-prometheus

$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-1 get pods monitoring promethues-prometheus -o jsonpath='{.spec.thanos}'
```


- Digital Ocean Cluster Number 2 Example
`$ cp ./kube-prometheus-operator/manifests/prometheus-prometheus.yaml ./03-prometheus-prometheus-thanos-digitalocean-cluster-2.yaml`

`vim ./03-prometheus-prometheus-thanos-digitalocean-cluster-2.yaml`
```
## At the end of the file add:
  thanos:
    image: quay.io/thanos/thanos:v0.28.1
    objectStorageConfig:
      key: thanos.yaml
      name: thanos-objectstorage # This is the secret's name created in the cluster from previous step.
    version: v0.28.1
```

- Apply the changes to the Prometheus Pod
```
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-2 apply -f ./03-prometheus-prometheus-thanos-digitalocean-cluster-1.yaml

$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-2 get pods monitoring prometheus-prometheus

$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-2 get pods monitoring promethues-prometheus -o jsonpath='{.spec.thanos}'
```

6. Create the Service for the Thanos Sidecar.
- This was customized to be a LoadBalancer to be accesible across the Internet.
- Syntax and labels for creation was a customization based on:
https://github.com/prometheus-operator/kube-prometheus/tree/main/manifests  
https://github.com/prometheus-operator/prometheus-operator/blob/main/example/thanos/sidecar-service.yaml

- Digital Ocean Cluster Number 1 Example
```
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-1 apply -f 04-thanos-sidecar-svc.yaml
```

- Digital Ocean Cluster Number 2 Example
```
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean-2 apply -f 04-thanos-sidecar-svc.yaml
```


