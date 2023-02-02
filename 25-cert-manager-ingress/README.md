# Nginx Ingress with Load Balancer and Cert-Manager
- All resources are provisioned with Terraform including K8s Cluster.
- Cloud Provisioner is Digital Ocean
- Kubernetes Ingress is Nginx
- Replace with Domain needed at the moment
- LoadBalancer created with Kubernetes Service
- Let's Encrypt for Certificate Provisioning.

1. Add the do_token enviroment variable for Terraform.
```
$ export TF_VAR_do_token=REPLACE_WITH_TOKEN
```

2. Provision the Cloud Infrastructure with Terraform.
This will create:
- 1 Kubernetes Cluster
- Pull in kubeconfig.yaml file
- 1 DNS and 1 A Record

```
$ terraform init

$ terraform plan

$ terraform apply
```

3. Once created the access to the K8s Cluster can be tested with:
```
$ kubectl --kubeconfig kubeconfig.yaml get nodes
```

4. Create the Deployment and ClusterIP Service
```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 04-hello-app.yaml

$ kubectl --kubeconfig kubeconfig.yaml get -f 04-hello-app.yaml
```

5. Deploy the Kubernetes Nginx Ingress Controller - LoadBalancer

```
$ kubectl --kubeconfig kubeconfig.yaml apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/do/deploy.yaml

$ kubectl --kubeconfig kubeconfig.yaml get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx --watch

$ kubectl --kubeconfig kubeconfig.yaml get svc --namespace=ingress-nginx

$ kubectl --kubeconfig kubeconfig.yaml get -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/do/deploy.yaml
```

6. Create the Ingress Resource to connect with the Ingress Controller.

- Deploy Manifests.
```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 05-hello-ingress.yaml
$ kubectl --kubeconfig kubeconfig.yaml get -f 05-hello-ingress.yaml
```

- Go to the DNS Service in Cloud Provider and for the A Record created with Terraform, replace the placeholder IPV4 1.1.1. with the Load Balancer IP created from step5 with the Ingress Controller.

- Add that IP and A record to the Domain Provider.
Wait for the TTL and access in a web browser, or with curl:

```
hello.pereirajean.com

$ curl hello.pereirajean.com
```