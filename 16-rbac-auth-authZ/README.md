# Authentication -  Credentials and/or ServiceAccounts  
  
* Credentials  
1. Create Private Key  
```
openssl genrsa -out myuser.key 2048  
openssl req -new -key myuser.key -out myuser.csr
```
  
2. Create certificate signing request  
``` 
kubectl apply -f 01-csr.yaml
```
  
3. Approve certificate signing request  
```
kubectl get csr  

kubectl certificate approve developer-user
```
  
3.1 Get the certificate  
```
kubectl get csr developer-user -o jsonpath='{.status.certificate}' | base64 -d > developer-user.crt
```

4. Add to kubeconfig, create the user for authenticate with the K8s API  
```
kubectl config set-credentials
```

# Authorization - RBAC - ClusterRoles/Roles and ClusterRoleBindings/RoleBindings  





References:
https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user
https://kubernetes.io/docs/setup/best-practices/certificates/