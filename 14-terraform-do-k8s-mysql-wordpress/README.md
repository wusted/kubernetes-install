# Terraform deployment
# Backend(MYSQL)+ Frontend(WordPress)

# Pre-requisites
- Use DigitalOcean Cloud Provider.
- Get the respective token set as environment variables.
- For Terraform to connect to DigitalOcean
- add the A record in the Domain Provider for the Load Balancer.

# Usage.

# Step 1 and 2: In this Repo:

1. Deploy Cloud Infrastructure.
- Kubernetes Cluster
- Load Balancer
- CircleCI
- Output File
- DNS Records and Domain

```
$ terraform init
$ terraform plan
$ terraform apply
```

2. Test Kubernetes Cluster

```
$ kubectl --kubeconfig=kubeconfig.yaml get nodes
```

# Step 3 and 4: In this Repo:

3. Apply the manifests, to create:
- MySQL StatefulSet with one PVC from StorageClass
- ClusterIP Service for MySQL p-3306-> Wordpress
- WordPress Deployment
- nodePort Service for WordPress p-30000-> LoadBalancer:80

```
$ kubectl -kubeconfig=kubeconfig.yaml apply -f ./kubernetes/
```
Connectivity can be tested with 
curl or in a web browser to the 
LoadBalancerIP or DNS Domain A Record.

4. 