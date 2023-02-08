## Pod Priorities and Preemption Policies in Kubernetes.
- Useful for critical Apps, Monitoring, Databases, etc to take Priority and never be replaced.

- All resources are provisioned with Terraform
- Kubernetes Cluster
- Cloud Provisioner: DigitalOcean

1. Add the do_token environment variable for Terraform.
```
$ export TF_VAR_do_token=REPLACE_WITH_TOKEN
```

2. Provision the Cloud Infrastructure with Terraform.
This will create:
- 1 Kubernetes Cluster.
- Pull in the "kubeconfig.yaml" file.
```
$ terraform init

$ terraform plan

$ terraform apply
```

3. Once created, the access to the K8s Cluster can be tested with:
```
$ kubectl --kubeconfig kubeconfig.yaml get nodes
```

4. By default, Kubernetes Cluster comes with PodPriorityClass. Higher value takes more priority.

- PriorityClasses are Cluster Wide and are not tied to a namespace.
- Preemptions are for when creating new pods, if existing pods have lower priority and take all the resources, then the pods with higher PreemptionPriority will remain and delete the lowest priority ones.

```
$ kubeclt --kubeconfig kubeconfig.yaml get priorityclass
```

5. Create the Priority Classes:
- LowPriority
- HighPriority with No Preemption
- HighPriority with Preemption

```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 03-priorityclasses.yaml
$ kubectl --kubeconfig kubeconfig.yaml get priorityclass  
```

6. Create LowPriority Pod with 1200m for CPU Request:
```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 04-nginx-pod-lp.yaml
$ kubectl --kubeconfig kubeconfig.yaml get -f 04-nginx-pod-lp.yaml
```

7. Create HighPriority with Preemption Pod with 1200m for CPU Request, to replace LP pod:

```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 05-nginx-pod-hp-preemptive.yaml && kubectl --kubeconfig kubeconfig.yaml get pods -w
$ kubectl --kubeconfig kubeconfig.yaml get pods

# Once replaced, then delete the HP with Preemptive Pod, for next example:
$ kubectl --kubeconfig kubeconfig.yaml delete -f 05-nginx-pod-hp-preemptive.yaml
```

8. Create HighPriority with No Preemption with 1200m for CPU Request, and confirm it will not replace LP pod.
```
# First create LP Pod:
$ kubectl --kubeconfig kubeconfig.yaml apply -f 04-nginx-pod-lp.yaml
$ kubectl --kubeconfig kubeconfig.yaml get -f 04-nginx-pod-lp.yaml

# Then create HP No Preemptive Pod:
$ kubectl --kubeconfig kubeconfig.yaml apply -f 06-nginx-pod-hp-non-preemptive.yaml
$ kubectl --kubeconfig kubeconfig.yaml get pods -w

# Even with a HP Pod, if no resources available since are taken by a LP Pod, if the HP Pod is No Preemptive then the LP Pod will remain and not be replace with HP Pod.
```