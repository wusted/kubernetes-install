# Authentication -  Credentials 
  
* Credentials  
1. Create Private Key  
```
openssl genpkey -out developer-user.key -algorithm ed25519
openssl req -new -key developer-user.key -out developer-user.csr -subj '/CN=developer-user/O=edit'
```
  OR
  
```
openssl genrsa -out developer-user.key 2048
openssl req -new -key developer-user.key -out developer-user.csr -subj '/CN=developer-user/O=edit'
```
  
2. Encode the CSR 
```
cat developer-user.csr | base64 | tr -d "\n"
```

2. Create certificate signing request K8s Object. 
``` 
kubectl apply -f 01-csr.yaml

# Important, place the base64 encoded string in the spec.request filed.
```
  

3. Approve and get the crt file. 

a. Approve certificate signing request  
```
kubectl get csr  

kubectl certificate approve developer-user
```
  
b. Get the certificate  
```
kubectl get csr/developer-user -o yaml | less
```
```
kubectl get csr developer-user -o jsonpath='{.status.certificate}' | base64 -d > developer-user.crt
```
    
4. Create the kubeconfig file, create the user to authenticate with the K8s API  


a. Make a copy of an existing kubeconfig file for the cluster, the copy will be provided to the new user.  
(This can also be done on the current ~/.kube/config file used, but for isolation of access recommended to create a new file for new user.)
```
cp ~/.kube/config jean-kubeconfig
OR
cp /etc/kubernetes/admin.conf jean-kubeconfig
sudo chown $(id -u):$(id -g) jean-kubeconfig
```

b. Open jean-kubeconfig and delete all fields, leave only the cluster fields:  
- apiVersion, clusters, clusters.cluster, clusters.cluster.certificate-authority-data,  
- clusters.cluster.server, clusters.name, 


c. Add the credentials
```
kubectl --kubeconfig jean-kubeconfig config set-credentials developer-user --client-key=developer-user.key --client-certificate=developer-user.crt --embed-certs=true
```  
```
kubectl --kubeconfig jean-kubeconfig config get-users
```
  
d. Set a new context to use the credentials  
```
kubectl --kubeconfig jean-kubeconfig config set-context developer-user --cluster=kubernetes --user=developer-user --namespace=development
```
```
kubectl --kubeconfig jean-kubeconfig config get-contexts
```
  
e. Change to the new context to the test the user
```
kubectl --kubeconfig jean-kubeconfig config use-context developer-user
```
```
kubectl --kubeconfig jean-kubeconfig config current-context
```


f. Confirm no permissions to get,read,execute on resources.
```
kubectl --kubeconfig jean-kubeconfig get nodes  
  
Error from server (Forbidden): nodes is forbidden: User "developer-user" cannot list resource "nodes" in API group "" at the cluster scope
```

- This file 'jean-kubeconfig' can now be shared for external users to access the cluster on the specified namespace and resources to execute the allowed actions.  
- For example in another client paste in ~/.kube/config or use it with the --kubeconfig flag.

# Authorization - RBAC - ClusterRoles/Roles and ClusterRoleBindings/RoleBindings  

1. Apply and create rolebinding and role in the admin context.
```
kubectl apply -f 02-role.yaml,03-rolebinding.yaml
```

Should work.

# Testing RBAC

1. Create a Pod.
```
kubectl --kubeconfig jean-kubeconfig run nginx --image=nginx
  
kubectl --kubeconfig jean-kubeconfig get pods
```

2. Confirm that other resources are not accessible (to access each resource, those need to be added in the role or clusterrole along with the verb/action and namespace)

```
kubectl --kubeconfig jean-kubeconfig get nodes  
Error from server (Forbidden): nodes is forbidden: User "developer-user" cannot list resource "nodes" in API group "" at the cluster scope  
  
kubectl --kubeconfig jean-kubeconfig get ns  
Error from server (Forbidden): namespaces is forbidden: User "developer-user" cannot list resource "namespaces" in API group "" at the cluster scope
```

# ServiceAccounts, for Pods and Services.

1. Apply the manifest with the ServiceAccount, ClusterRole, ClusterRoleBinding and Pod.
```
kubectl apply -f 04-serviceaccount-pod.yaml
```
```
kubectl get -f 04-serviceaccount-pod.yaml
```

2. Access the Pod logs to see the API request output:

```
kubectl logs -n development dashboard-cluster-role-pod
```

3. Optional to access the Pod to check the Envs and replicate the API request.

```
kubectl exec -n development -it dashboard-cluster-role-pod -- /bin/bash
```

```
root@dashboard-cluster-role-pod:/# env | grep KUBERNETES

root@dashboard-cluster-role-pod:/# curl https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}/apis/apps/v1 --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -header "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
```

- Note: The endpoint https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}/apis/apps/v1 can be modified to get other resources, like pods, namespaces, deployments, or any other object in the K8S API, since the ClusterRole resource is set to "[*]" which is everything. This can be also modified to limit the specific resources that can be accessed.


References:
https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user  
https://kubernetes.io/docs/setup/best-practices/certificates/  
https://kubernetes.io/docs/reference/access-authn-authz/rbac/  
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/
