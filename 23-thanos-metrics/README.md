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
$