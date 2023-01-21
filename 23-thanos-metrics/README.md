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