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

4. Install istioctl on client  
Ref: https://istio.io/latest/docs/setup/getting-started/#download

```
$ curl -L https://istio.io/downloadIstio | sh -

$ cd istio-1.17.1/

$ export PATH=$PWD/bin:$PATH

$ istioctl --kubeconfig kubeconfig.yaml x precheck
```

5. Install "istio" with "istioctl"

```
$ istioctl --kubeconfig kubeconfig.yaml install --set profile=demo -y

$ kubectl --kubeconfig kubeconfig.yaml get ns

$ kubectl --kubeconfig kubeconfig.yaml get all -n istio-system

$ kubectl --kubeconfig label namespace default istio-injection=enabled

$ kubectl --kubeconfig kubeconfig.yaml get ns --selector=istio-injection=enabled
```

5. Deploy 2 sample apps in the "default" namespace.

```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 03-hello-app-v1.yaml,04-hello-app-v2.yaml
$ kubectl --kubeconfig kubeconfig.yaml get -f 03-hello-app-v1.yaml,04-hello-app-v2.yaml

# Confirm that the pods are running a sidecar container for istio-proxy.
$ kubectl --kubeconfig kubeconfig.yaml get pods
$ kubectl --kubeconfig kubeconfig.yaml describe pod hello-v1-[hash] | less
$ kubectl --kubeconfig kubeconfig.yaml describe pod hello-v2-[hash] | less
```

6. Install add-ons (Kiali, Prometheus, Grafana) and access the Dashboard
```
$ kubectl --kubeconfig kubeconfig.yaml apply -f istio-1.17.1/samples/addons
$ kubectl --kubeconfig kubeconfig.yaml get -f istio-1.17.1/samples/addons

$ kubectl --kubeconfig kubeconfig.yaml rollout status deployment/kiali -n istio-system
```

- Then access the dashboard, this will open a tab in a web browser in the client.
Run this in another terminal.
```
$ istioctl --kubeconfig kubeconfig.yaml dashboard kiali
```

- From the website, go to Graphs, then select the "default" namespace and set it to list the idle pods.

7. With Kiali running, generate traffic in the pods.

```
# Access one of the pod's hello-v2 container.
$ kubectl --kubeconfig kubeconfig.yaml exec -it hello-v2-[hash] -- /bin/sh

# Inside of the container, install curl and run a script to reach the hello-v1-svc every 1 second. It should return 200 to the console.
$ apk add --update curl
$ while sleep 1; do curl -o /dev/null -s -w %{http_code} http://hello-v1-svc:80/; done

```

- Go to the "kiali" dashboard for the "default" namespace graph, and click on the "refresh" button at the top right corner.
- Traffic should be detected and monitored, with the HTTP code received, other stats and the network route followed.
- Since the add-ons include Prometheus and Grafana, Istio automatically exposes these metrics to Grafana for monitoring.

8. Expose Grafana port.

```
$ kubectl --kubeconfig kubeconfig.yaml get -n istio-system svc
$ kubectl --kubeconfig kubeconfig.yaml port-forward -n istio-system svc/grafana 3000
```

- Access to localhost:3000 in a web browser from the client.
- For example, go to Dashboards > Istio > Istio Mesh Dashboard or Dashboards > Istio > Istio Service Dashboard > General > select "hello-v1-svc" > Open client and service workload dashboards.
- We can monitor all the network traffic collected by Istio in Grafana.


9. Set up Ingress and VirtualService with Istio

- This helps with prefix and path routing of URI, traffic shifting for weighted routing, i.e. canary deployments, and opening the application to outside traffic.
Along with many other features.

Ref:
https://istio.io/latest/docs/concepts/traffic-management/#gateways  
https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/  
https://istio.io/latest/docs/tasks/traffic-management/traffic-shifting/

```
## Deploy the Gateway and VirtualService
$ kubectl --kubeconfig kubeconfig.yaml apply -f 05-ingress.yaml

## Get the External IP from istio-ingressgateway Load Balancer Service
$ kubectl --kubeconfig kubeconfig.yaml get svc istio-ingressgateway -n istio-system

## Test the Prefix Route set for the VirtualService, with curl to specify the Host: "Header"
$ curl -H "Host: hello.pereirajean.local" [LB_External_IP]/v1
Output:
Hello, world!
Version: 2.0.0
Hostname: hello-v1-7f78d74bd8-r9phz

$ curl -H "Host: hello.pereirajean.local" [LB_External_IP]/v2
Output:
Hello, world!
Version: 2.0.0
Hostname: hello-v2-549f7b8bf7-4wqmf
```

```
## Alternatively we can store the IP and Port in environment variables for ease of access:

$ export INGRESS_HOST=$(kubectl --kubeconfig kubeconfig.yaml -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

$ export INGRESS_PORT=$(kubectl --kubeconfig kubeconfig.yaml -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')

$ export SECURE_INGRESS_PORT=$(kubectl --kubeconfig kubeconfig.yaml -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')

$ export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT

$ env | egrep "INGRESS|GATEWAY"

$ echo "$GATEWAY_URL"


## Test the Prefix Route set for the VirtualService, with curl to specify the Host: "Header" and the Environment Variables instead of IP or PORT.

$ curl -H "Host: hello.pereirajean.local" $GATEWAY_URL/v1
Output:
Hello, world!
Version: 2.0.0
Hostname: hello-v1-7f78d74bd8-r9phz

$ curl -H "Host: hello.pereirajean.local" $GATEWAY_URL/v2
Output:
Hello, world!
Version: 2.0.0
Hostname: hello-v2-549f7b8bf7-4wqmf
```

10. Simulate dependencies between services using an Nginx Proxy to interact with Istio.

- This nginx deployment will proxy_pass the services for the sample app hello-v1 and hello-v2

```
## Apply the Deployment and Port-Forward the Service.
$ kubectl --kubeconfig kubeconfig.yaml apply -f 06-nginx-proxy.yaml
$ kubectl --kubeconfig kubeconfig.yaml get -f 06-nginx-proxy.yaml

## Verify that the sidecar container with istio-proxy was added to the nginx pods.
$ kubectl --kubeconfig kubeconfig.yaml get pods

## In another terminal, port forward the nginx deployment service
$ kubectl --kubeconfig kubeconfig.yaml port-forward svc/nginx-svc 8080:80

## In another terminal, while the above service is exposed, run a while script for reaching the endpoints every second from the client.
$ while sleep 1; do curl localhost:8080/v1 && curl localhost:8080/v2; done
```

- Then go to Kiali, to the Graph > "default" namespace and press the "refresh" to get a display of the "nginx" pod traffic interaction with hello-v2-svc and hello-v1-svc.

- Now for testing, delete deployment "hello-v1" and keep monitoring.

```
$ kubectl --kubeconfig kubeconfig.yaml delete -f 03-hello-app-v1.yaml
OR
$ kubectl --kubeconfig kubeconfig.yaml delete service/hello-v1-svc

$ kubectl --kubeconfig kubeconfig.yaml get -f 03-hello-app-v1.yaml
$ kubectl --kubeconfig kubeconfig.yaml get pods
```

- Go back to Kiali, to the Graph > "default" namespace and press the "refresh" to get the status of "nginx" with hello-v1-svc.
- We can see from Kilai what is failing in the Network Topology and start debugging from there.

- Maybe deleting a deployment OR a service is an extreme scenario, but we can also use Istio+Kiali+Grafana to monitor and detect latency, communication issues and multiple errors in architectures with multiple microservices to understand and analyze the network dependencies and what is failing.

====
Istio is a great tool to enable developers.  
Other Istio Features include:
- create policies for traffic routing.
- divide or weight the traffic for 2 versions of a deployment.
- multi clustering, connecting Istio from different Kubernetes clusters
- create rules for failover, for multi clustering if one cluster fails, redirect the traffic to the other cluster.
