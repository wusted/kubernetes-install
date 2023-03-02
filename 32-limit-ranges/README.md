## Limit Range in Kubernetes

Ref: https://kubernetes.io/docs/concepts/policy/limit-range/

- All resources are provisioned with Terraform.
- Kubernetes Cluster
- Cloud Provisioner: Digital Ocean
- Limit Range enables management of default resource allocation for NEW pods, containers and PersistentVolumeClaims per Kubernetes Namespace. (Requests and Limits for CPU and Memory)

- Limit Range defines a threshold range for Min and Max Resources CPU and Memory on a Type(Container,Pod,PVC) and then we can set a Default Request and a Default Limit to be assigned to the Resource Type, and those Defaults need to be inside of the Min/Max threshold.

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

4. Create a Pod without Resource Limits or Requests.
```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 03-pod.yaml 
$ kubectl --kubeconfig kubeconfig.yaml get -f 03-pod.yaml

# Confirm that there are no Limits or Requests.
$ kubectl --kubeconfig kubeconfig.yaml describe -f 03-pod.yaml | less

$ kubectl --kubeconfig kubeconfig.yaml delete -f 03-pod.yaml
```

5. Apply the LimitRange and create a Pod without Resource Limits or Requests.

- Create the LimitRange on the default namespace.
```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 04-limit-range.yaml
$ kubectl --kubeconfig kubeconfig.yaml get -f 04-limit-range.yaml
$ kubectl --kubeconfig kubeconfig.yaml describe -f 04-limit-range.yaml | less

```

- Create a new pod that will inherit the limit range on the default namespace.
```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 03-pod.yaml 
$ kubectl --kubeconfig kubeconfig.yaml get -f 03-pod.yaml

# Confirm that the Limits or Requests are set accordingly.
$ kubectl --kubeconfig kubeconfig.yaml describe -f 03-pod.yaml | less
```


6. Create Pod with a bigger Resource Request than the Limit Range

- Create a new pod with a CPU resource request higher than the Max for the Limit range on the default namespace.
```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 05-big-pod.yaml
--
The Pod "nginx-big" is invalid: spec.containers[0].resources.requests: Invalid value: "500m": must be less than or equal to cpu limit
--

# Confirm the Pod wasn't created since it surpasses the Max threshold.
$ kubectl --kubeconfig kubeconfig.yaml get -f 05-big-pod.yaml
```

===
LimitRanges is a great object for setting resource limits available in a namespace where other users have access to create pods, containers and PVC to ensure correct and planned usage of resources.
Other LimitRange features include:
