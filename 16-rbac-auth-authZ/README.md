# Authentication -  Credentials and/or ServiceAccounts  
  
* Credentials  
1. Create Private Key  
```
openssl genpkey -out jean.key -algorithm ed25519
openssl req -new -key jean.key -out jean.csr -subj '/CN=jean/O=edit'
```
  
2. Encode the CSR 
```
cat jean.csr | base64 | tr -d "\n"
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
kubectl get csr/jean -o yaml | less
```
```
kubectl get csr developer-user -o jsonpath='{.status.certificate}' | base64 -d > developer-user.crt
```
    
4. Create the kubeconfig file, create the user to authenticate with the K8s API  


a. Make a copy an existing kubeconfig for the cluster
```
cp ~/.kube/config jean-kubeconfig
OR
cp /etc/kubernetes/admin.conf jean-kubeconfig
sudo chown $(id -u):$(id -g) jean-kubeconfig
```

b. Open jean-kubeconfig and delete all fields, leave only the cluster fields:  
- apiVersion, clusters, clusters.cluster, clusters.cluster.certificate-authority-data,  
- clusters.cluster.server, clusters.name, 


a. Add the credentials
```
kubectl --kubeconfig jean-kubeconfig config set-credentials developer-user --client-key=jean.key --client-certificate=jean.crt --embed-certs=true
```  
```
kubectl --kubeconfig jean-kubeconfig config get-users
```
  
b. Set a new context to use the credentials  
```
kubectl --kubeconfig jean-kubeconfig config set-context developer-user --cluster=kubernetes --user=developer-user --namespace=development
```
```
kubectl --kubeconfig jean-kubeconfig config get-contexts
```
  
c. Change to the new context to the test the user
```
kubectl --kubeconfig jean-kubeconfig config use-context developer-user
```
```
kubectl --kubeconfig jean-kubeconfig config current-context
```


d. Confirm no permissions to get,read,execute on resources.
```
kubectl --kubeconfig jean-kubeconfig.yaml  get nodes  
  
Error from server (Forbidden): nodes is forbidden: User "jean" cannot list resource "nodes" in API group "" at the cluster scope
```

# Authorization - RBAC - ClusterRoles/Roles and ClusterRoleBindings/RoleBindings  





References:
https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user
https://kubernetes.io/docs/setup/best-practices/certificates/