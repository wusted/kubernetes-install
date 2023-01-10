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


References:
https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user  
https://kubernetes.io/docs/setup/best-practices/certificates/