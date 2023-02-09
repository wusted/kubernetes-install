## Pod Disruption Budgets and Nodes Draining
- "Drain" will move the existing Pods running on a Node to another Node.
- "Cordon" will block the scheduling of new Pods to a particular Node.
- "PodDisruptionBudgets" will make sure that in the Drain process when evicting the Pods, a minimum number of Pod Replicas remain running in the source Node, this helps assure Pod's Services reliability.
- This behavior will be effective only for expected changes, like Draining Manually or a Kubernetes Task moves a Pod to a new Node.
- This behavior will NOT be effective if a Pod is deleted with #kubectl delete or if the Pod Crashes.

- All resources are provisioned with Terraform
- Kubernetes Cluster
- Cloud Provisioner: DigitalOcean

1. Add the do_token environment variable for Terraform.
```
$ export TF_VAR_do_token=REPLACE_WITH_TOKEN
```

2. Provision the Cloud Infrastructure with Terraform.
- This will deploy:
- 1 Kubernetes Cluster
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

4. Create an Nginx Deployment with 6 Pods replicas:
```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 03-deployment-nginx.yaml

# Check on which node each pod was scheduled and placed:
$ kubectl --kubeconfig kubeconfig.yaml get pods --selector=app=nginx -o wide
```

5. Drain a Node without the Pod Disruption Budgets.
- All Pods will be evicted without making sure that enough available replicas of the Nodes are running. (Can cause service downtime)
- When draining, first Kubernetes will Cordon off the Node to disable the scheduling of new Pods in that Node.
```
# Drain will move all the Pods without making sure a minimum number of replicas will leave the service running.
# Replace jean-pod-disruption-cluster-nodes-q7dmk with the actual name of the Node. Ignore DaemonSet to avoid DaemonSets to be scheduled in other Node. (AntiPattern) 
$ kubectl --kubeconfig kubeconfig.yaml drain jean-pod-disruption-cluster-nodes-q7dmk --ignore-daemonsets

# Confirm that that all the pods that were running in jean-pod-disruption-cluster-nodes-q7dmk are now placed in another node.
$ kubectl --kubeconfig kubeconfig.yaml get pods --selector=app=nginx -o wide

# Check the status of the Cordoned Node is SchedulingDisabled.
$ kubectl --kubeconfig kubeconfig.yaml get nodes

# Uncordon the Node so it can receives new Pods scheduled. (This will not move back the Pods to the Node.)
$ kubectl --kubeconfig kubeconfig.yaml uncordon jean-pod-disruption-cluster-nodes-q7dmk

# Delete the Deployment to proceed with next example.
$ kubectl --kubeconfig kubeconfig.yaml delete -f 03-deployment-nginx.yaml
```


6. Create an Nginx Deployment with 6 Pods replicas:
```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 03-deployment-nginx.yaml

# Check on which node each pod was scheduled and placed:
$ kubectl --kubeconfig kubeconfig.yaml get pods --selector=app=nginx -o wide
```

7. Drain a Node with the Pod Disruption Budgets.
- Pods will be evicted making sure that a specified Number of "minAvailable" replicas are running when Draining to another Node (Prevents a service downtime)
- When draining, first Kubernetes will Cordon off the Node to disable the scheduling of new Pods in that Node.
- Pod Disruption Budgets will "matchLabels" to apply the parameter. 
- In this example "minAvailable" =  5, so that while evicting and placing Pods on a new Node, the sum of the Pods on every Node should always be at least 5.

```
# Apply the PDB
$ kubectl --kubeconfig kubeconfig.yaml apply -f 04-pdb-nginx.yaml
$ kubectl --kubeconfig kubeconfig.yaml get poddisruptionbudgets
$ kubectl --kubeconfig kubeconfig.yaml describe poddisruptionbudgets
```

```
# Drain will move all the Pods while making sure a minimum number of replicas will leave the service running.
# Replace jean-pod-disruption-cluster-nodes-q7dmk with the actual name of the Node. Ignore DaemonSet to avoid DaemonSets to be scheduled in other Node. (AntiPattern) 

$ kubectl --kubeconfig kubeconfig.yaml drain jean-pod-disruption-cluster-nodes-q7dmk --ignore-daemonsets
# Messages like `"error when evicting pods/"nginx-76d6c9b8c-zzzwx" -n "default" (will retry after 5s): Cannot evict pod as it would violate the pod's disruption budget."` Confirms that a desired number of replicas will be maintained for reliability of the service, before evicting and moving the Pods.

# Confirm that that all the pods that were running in jean-pod-disruption-cluster-nodes-q7dmk are now placed in another node.
$ kubectl --kubeconfig kubeconfig.yaml get pods --selector=app=nginx -o wide

# Check the status of the Cordoned Node is SchedulingDisabled.
$ kubectl --kubeconfig kubeconfig.yaml get nodes

# Uncordon the Node so it can receives new Pods scheduled. (This will not move back the Pods to the Node.)
$ kubectl --kubeconfig kubeconfig.yaml uncordon jean-pod-disruption-cluster-nodes-q7dmk
```