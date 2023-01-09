# Authentication -  Credentials and/or ServiceAccounts  
  
* Credentials  
1. Create Private Key  
```
openssl genrsa -out developer-user.key 2048  
openssl req -new -key developer-user.key -out developer-user.csr
```
  
2. Create certificate signing request  
``` 
kubectl apply -f 01-csr.yaml
```
  

3. Approve and get the crt file. 

a. Approve certificate signing request  
```
kubectl get csr  

kubectl certificate approve developer-user
```
  
b. Get the certificate  
```
kubectl get csr developer-user -o jsonpath='{.status.certificate}' | base64 -d > developer-user.crt
```
    
4. Add to kubeconfig, create the user to authenticate with the K8s API  

a. Add the credentials
```
kubectl config set-credentials developer-user --client=developer-user.key \  
--client-certificate=developer-user.crt --embed-certs=true
```
  
b. Set a new context to use the credentials  
```
kubectl config set-context developer-user --cluster=kubernetes --user=developer-user
```
  
c. Change to the new context to the test the user
```
kubectl config use-context developer-user
```

# Authorization - RBAC - ClusterRoles/Roles and ClusterRoleBindings/RoleBindings  





References:
https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user
https://kubernetes.io/docs/setup/best-practices/certificates/