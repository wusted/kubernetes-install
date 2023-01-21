## Thanos Metric for Prometheus
- For this we will need at least 2 cluster.
- I will setup: 1 Local On-Prem Kubeadm Cluster and 1 Cloud DigitalOcean Cluster.
- For the Cloud Cluster will use Terraform.

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
$ export KUBECONFIG=~/.kube/config:./do_kubeconfig.yaml
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

- Digital Ocean Cluster Example
```
## Create the metrics CRDs.
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean get --raw /apis/metrics.k8s.io
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean top pods
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean top nodes

## Create the kube-prometheus-operator
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean apply --server-side -f ./kube-prometheus-operator/manifests/setup
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean wait --for condition=Established --all CustomResourceDefinition --namespace=monitoring
$ kubectl --kubeconfig thanosconfig.yaml --context do-nyc1-jean apply -f ./kube-prometheus-operator/manifests
```

- Local On-Prem Kubeadm Cluster
```
## Create the metrics CRDs.
$ kubectl --kubeconfig thanosconfig.yaml --context kubernetes-admin@kubernetes apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
$ kubectl --kubeconfig thanosconfig.yaml --context kubernetes-admin@kubernetes get --raw /apis/metrics.k8s.io
$ kubectl --kubeconfig thanosconfig.yaml --context kubernetes-admin@kubernetes top pods
$ kubectl --kubeconfig thanosconfig.yaml --context kubernetes-admin@kubernetes top nodes

## Create the kube-prometheus-operator
$ kubectl --kubeconfig thanosconfig.yaml --context kubernetes-admin@kubernetes apply --server-side -f ./kube-prometheus-operator/manifests/setup
$ kubectl --kubeconfig thanosconfig.yaml --context kubernetes-admin@kubernetes wait --for condition=Established --all CustomResourceDefinition --namespace=monitoring
$ kubectl --kubeconfig thanosconfig.yaml --context kubernetes-admin@kubernetes apply -f ./kube-prometheus-operator/manifests
```



4. Create the S3 Bucket Secret. 
- One Bucket per Cluster `vim _thanos-objstorage.yaml`
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
`cat _thanos-objstorage.yaml | base64`

- Generate Kubernetes Secret
`vim _thanos-objstore-secret.yaml`
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