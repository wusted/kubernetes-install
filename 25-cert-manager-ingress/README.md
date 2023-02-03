# Nginx Ingress with Load Balancer and Cert-Manager
- All resources are provisioned with Terraform including K8s Cluster.
- Cloud Provisioner is Digital Ocean
- Kubernetes Ingress is Nginx
- Replace with Domain needed at the moment
- LoadBalancer created with Kubernetes Service
- Cert-Manager CRD for Kubernetes.
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

$ kubectl --kubeconfig kubeconfig.yaml patch svc --namespace=ingress-nginx ingress-nginx-controller -p '{"spec":{"externalTrafficPolicy":"Cluster"}}'
$ kubectl --kubeconfig kubeconfig.yaml describe svc --namespace=ingress-nginx ingress-nginx-controller
```

6. Create the Ingress Resource to connect with the Ingress Controller.

- Deploy Manifests.
```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 05-hello-ingress.yaml
$ kubectl --kubeconfig kubeconfig.yaml get -f 05-hello-ingress.yaml
```

- Go to the DNS Service in Cloud Provider and for the A Record created with Terraform with hostname "hello", replace the placeholder IPV4 1.1.1. with the Load Balancer IP created from step5 with the Ingress Controller.

- Add that IP and A record to the Domain Provider.
Wait for the TTL and access in a web browser, or with curl:

```
hello.pereirajean.com

$ curl hello.pereirajean.com
```

6. Install and Configure cert-manager CRD.

- Apply manifest: https://cert-manager.io/docs/installation/
```
$ kubectl --kubeconfig kubeconfig.yaml apply -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.yaml

$ kubectl --kubeconfig kubeconfig.yaml get pod -n cert-manager 

$ kubectl --kubeconfig kubeconfig.yaml get -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.yaml
```

7. Enabling Pod Communication through the Load Balancer (If using DigitalOcean Kubernetes Cluster)

- Create A Record for Let's Encrypt to identify the Pods LoadBalancer

- Go to the DNS Service in Cloud Provider and create a new A Record with "workaround", use the Load Balancer IP created from step5 with the Ingress Controller.

- Add that IP and A record to the Domain Provider, with "workaround" hostname.

- Modify the LoadBalancer service (If Using DigitalOcean Kubernetes Cluster):
```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 06-loadbalancer-ingress.yaml

$ kubectl --kubeconfig kubeconfig.yaml get -f 06-loadbalancer-ingress.yaml
```

== STAGING ==  
8. Create the cert-manager ClusterIssuer for Staging.

```
# For testing use staging
$ kubectl --kubeconfig kubeconfig.yaml apply -f 07.0-staging-issuer.yaml
$ kubectl --kubeconfig kubeconfig.yaml get -f 07.0-staging-issuer.yaml
$ kubectl --kubeconfig kubeconfig.yaml get -n cert-manager secrets
```

9. Apply the TLS config to the Ingress created in step 5

```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 07.1-staging-hello-ingress-tls.yaml
$ kubectl --kubeconfig kubeconfig.yaml get -f 07.1-staging-hello-ingress-tls.yaml
$ kubectl --kubeconfig kubeconfig.yaml get secrets

$ kubectl --kubeconfig kubeconfig.yaml get certificate
$ kubectl --kubeconfig kubeconfig.yaml describe certificate 

# Test 
$ wget --save-headers -O- hello.pereirajean.com
# It will fail with:
HTTP request sent, awaiting response... 308 Permanent Redirect
. . .
ERROR: cannot verify echo1.example.com's certificate, issued by ‘ERROR: cannot verify hello.pereirajean.com's certificate, issued by ‘CN=(STAGING) Artificial Apricot R3,O=(STAGING) Let's Encrypt,C=US’:
  Unable to locally verify the issuer's authority.
To connect to hello.pereirajean.com insecurely, use `--no-check-certificate'.
```

- This is because we are using staging cert, which is similar to a Self-Sign Certificate where it is not possible to verify certificate authenticity for the client.


== PROD ==  
10. Create the cert-manager ClusterIssuer for Prod.

```
# Set prod issuer.
$ kubectl --kubeconfig kubeconfig.yaml apply -f 08.0-prod-issuer.yaml
$ kubectl --kubeconfig kubeconfig.yaml get -f 08.0-prod-issuer.yaml
$ kubectl --kubeconfig kubeconfig.yaml get -n cert-manager secrets
```

11. Apply the TLS config to the Ingress created in step 5 and staged in step 8.

```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 08.1-prod-hello-ingress-tls.yaml
$ kubectl --kubeconfig kubeconfig.yaml get -f 08.1-prod-hello-ingress-tls.yaml
$ kubectl --kubeconfig kubeconfig.yaml get secrets

$ kubectl --kubeconfig kubeconfig.yaml get certificate
$ kubectl --kubeconfig kubeconfig.yaml describe certificate 

```

12. Test HTTPS

```
$ curl -v hello.pereirajean.com
Output: 308 Permanent Redirect
Location: https://hello.pereirajean.com

$ curl -v https://hello.pereirajean.com
Output: 200 OK
Pod content.

From web browser:

hello.pereirajean.com will redirect to https://hello.pereirajean.com/ which is encrypted with the certificates.
```


References:   
https://github.com/cert-manager/cert-manager  
https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-with-cert-manager-on-digitalocean-kubernetes
