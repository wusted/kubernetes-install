## Kubernetes with Traefik Ingress CRD to deploy Services with TLS encryption.
- Using Terraform to deploy Cloud Resources  
- Load Balancer and Domain to access the K8s Service from the Internet. 

1. Initialize resources with terraform on cloud provider:

```
$ cd terraform

$ terraform init

$ terraform plan

$ terraform apply

```

2. Once deployed use the kubeconfig.yaml file to access the K8s API from the cluster created.  
And create the first 4 manifests for CRDs, RBAC, Service nodePort and Load Balancer.

```
$ kubectl --kubeconfig kubeconfig.yaml get nodes

$ kubectl --kubeconfig kubeconfig.yaml apply -f 03-traefik-crd.yaml,04-traefik-rbac-crd.yaml,05-traefik-service.yaml,06-traefik-loadbalancer.yaml

$ kubectl --kubeconfig kubeconfig.yaml get -f 03-traefik-crd.yaml,04-traefik-rbac-crd.yaml,05-traefik-service.yaml,06-traefik-loadbalancer.yaml
```

3. Once applied, wait for the Load Balancer in the Cloud Provider to get created.  
And assign the Public IP to an A record for a Domain in the Cloud Provider and in the  
Domain provider using the testing subdomain, in this case *test.pereirajean.com*

```
$ kubectl --kubeconfig kubeconfig.yaml get all

# Wait until service/tcp-loadbalancer shows External IP value instead of <pending>
```

4. After assigned and waited the TTL for the IP to resolve the Hostname.  
Create the Deployment and IngressRoutes manifests.

```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 07-traefik-deployments.yaml,08-traefik-ingressroutes.yaml
```

5. Confirm in the logs that the Certificate was obtained.
```
$ kubectl --kubeconfig kubeconfig.yaml logs pod/traefik

## Output should be something like this:
level=debug msg="Loading ACME certificates [test.pereirajean.com]..."
```

6. Confirm by accessing through a web browser

```
## Without TLS
http://test.pereirajean.com/notls

## With TLS
https://test.pereirajean.com/tls

## Troubleshoot - If it doesnt work with tls, then delete the traeffik pod.
$ kubectl --kubeconfig kubeconfig.yaml delete pod/traefik

## Then try again, this will allow the ingress-controller to read the certificates.
```


7. When finished remember to delete all kubernetes resources and cloud resources.  
To prevent cloud charges :)

```
$ kubectl --kubeconfig kubeconfig.yaml delete -f 03-traefik-crd.yaml,04-traefik-rbac-crd.yaml,05-traefik-service.yaml,06-traefik-loadbalancer.yaml,07-traefik-deployments.yaml,08-traefik-ingressroutes.yaml

$ kubectl --kubeconfig kubeconfig.yaml get all

$ terraform destroy
```
  
References:  
https://doc.traefik.io/traefik/providers/kubernetes-crd/#configuration-requirements  
https://doc.traefik.io/traefik/user-guides/crd-acme/

