# Documentation for 4 types of HPA. 
    - CPU and Memory
    - Pods Metrics
    - Custom Metrics 
        https://github.com/kubernetes/design-proposals-archive/blob/main/instrumentation/custom-metrics-api.md
        https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/#autoscaling-on-multiple-metrics-and-custom-metrics
    - External Metrics 
        https://github.com/kubernetes/design-proposals-archive/blob/main/instrumentation/external-metrics-api.md
        https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/#autoscaling-on-metrics-not-related-to-kubernetes-objects

0. Install metrics API 
https://github.com/wusted/kubernetes-install/blob/main/2.1-metrics-server-setup

1. Install kube-prometheus.
https://github.com/prometheus-operator/kube-prometheus
https://prometheus-operator.dev/docs/prologue/quick-start/

2. Check the metrics version and api-resources
```
# https://kubernetes.io/docs/reference/using-api/deprecation-guide/#v1-22
$ kubectl get --raw /apis/metrics.k8s.io/

$ kubectl get apiservices.apiregistration.k8s.io
```

3. Create the Deployment that contains the HTTP Metrics for Kube-Prometheus
```
$ kubectl apply -f 00-hello-prom-example-deployment.yaml

$ kubectl get deploy,svc,pods,servicemonitor
```

4. Create the APIServices which works as an EndPoints for Kubernetes to reach kube-prometheus adapter,  
that exposes the Prometheus Metrics for the Kubernetes Cluster.

```
$ kubectl apply -f 01-apiservice.yaml

$ kubectl get apiservices -n monitoring | grep metrics
```

5. Deploy Locust Service for Traffic Load Testing to the Pods.
Ref: https://github.com/deliveryhero/helm-charts/tree/master/stable/locust
https://docs.locust.io/en/stable/running-in-docker.html#running-a-distributed-load-test-on-kubernetes

```
$ kubectl apply -f 02-locust-configmap.yaml
$ kubectl get configmap my-loadtest-locustfile
$ kubectl describe configmap my-loadtest-locustfile

$ helm repo add deliveryhero https://charts.deliveryhero.io/
$ helm install locust deliveryhero/locust \
  --set loadtest.name=my-loadtest \
  --set loadtest.locust_locustfile_configmap=my-loadtest-locustfile

$ helm get manifest locust | kubectl get -f -

### ## To access the locust master UI
Run this command:

$ kubectl --namespace default port-forward service/locust 8089:8089

Then open in a browser: http://localhost:8089  
  
Use the svc name for the test. In this case "http://hello-svc:80"
```

6. Test - CPU and Memory HPA

Initial Locust Test:
- 10 Users , 10 Spawn Rate (1RPS), http://hello-svc:80

- Create the HPA
```
$ kubectl apply -f 03-hello-hpa-cpu.yaml

$ kubectl get hpa
$ kubectl get pods,deploy

# This should not scale (minReplicas: 3) since load is below the threshold of CPU averageUtilization: 50
```

Stop and start a new Locust Test:
- 300 Users , 10 Spawn Rate (44 RPS), http://hello-svc:80
```
$ kubectl get hpa
$ kubectl get pods,deploy

# This should scale since load is above the threshold of CPU averageUtilization: 50
```
