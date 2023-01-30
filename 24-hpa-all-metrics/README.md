# Documentation for 4 types of HPA. 
    - CPU and Memory
    - Pods Metrics
    - Custom Metrics 
        https://github.com/kubernetes/design-proposals-archive/blob/main/instrumentation/custom-metrics-api.md
        https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/#autoscaling-on-multiple-metrics-and-custom-metrics
    - External Metrics 
        https://github.com/kubernetes/design-proposals-archive/blob/main/instrumentation/external-metrics-api.md
        https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/#autoscaling-on-metrics-not-related-to-kubernetes-objects
    
1. Install kube-prometheus.
https://github.com/prometheus-operator/kube-prometheus
https://prometheus-operator.dev/docs/prologue/quick-start/

2. 
```
# https://kubernetes.io/docs/reference/using-api/deprecation-guide/#v1-22
$ kubectl get --raw /apis/metrics.k8s.io/
```