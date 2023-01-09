# Authentication -  Credentials and/or ServiceAccounts  
  
Credentials  
1. Create Private Key  
```
openssl genrsa -out myuser.key 2048  
openssl req -new -key myuser.key -out myuser.csr
```
  
2. Create certificate signing request  
``` 
kubectl apply -f 01-csr.yaml
```

# Authorization - RBAC - ClusterRoles/Roles and ClusterRoleBindings/RoleBindings  





References:
https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user
https://kubernetes.io/docs/setup/best-practices/certificates/