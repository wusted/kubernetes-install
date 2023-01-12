References:  

1. Initialize resources with terraform on cloud provider:

```
cd terraform

terraform init

terraform plan

terraform apply

```

2. Once deployed use the kubeconfig.yaml file to access the K8s API from the cluster created.  
And create the first 5 manifests.

```
kubectl --kubeconfig terraform/kubeconfig.yaml get nodes

kubectl --kubeconfig terraform/kubeconfig.yaml apply -f 00-traefik-crd.yaml,01-traefik-rbac-crd.yaml,02-traefik-service.yaml,03-traefik-deployments.yaml,04-traefik-loadbalancer.yaml
```

3. Once created, wait for the Load Balancer in the Cloud Provider to get created.  
And assign the Public IP to an A record for a Domain in the Cloud Provider and in the  
Domain provider using the testing subdomain, in this case *test.pereirajean.com*

4. After assigned and waited the TTL for the IP to resolve the Hostname.  
Create the IngressRoutes

```
kubectl --kubeconfig terraform/kubeconfig.yaml apply -f 04-traefik-loadbalancer.yaml
```

https://doc.traefik.io/traefik/providers/kubernetes-crd/#configuration-requirements  
https://doc.traefik.io/traefik/user-guides/crd-acme/

