## Sealed Secrets  
- Alternative to store secrets securely.  
- This will use by "default" the Master/Controller kubeconfig SSL certificate to encrypt the secrets values.  
- If multiple cluster used with kubeseal kubeconfig we can specify which cluster to use.  
- Secrets created in a cluster can then only be decrypted within that cluster.  

1. Apply the manifest with the sealed secrets controller. (CRD needed to use the SealedSecrets)
```
$ kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.19.4/controller.yaml

$ kubectl get pods -n kube-system
```

2. Create a sample secret, coded in base64
```
$ echo -n bar | kubectl create secret generic mysecret --dry-run=client --from-file=foo=/dev/stdin -o json > mysecret.json

$ cat mysecret.json

## Secret can be decoded with
$ echo YmFy | base64 -d
```

- This is not secure and it's why sealed-secrets can be a good alternative to store secrets.

3. Install kubeseal
```
$ brew install kubeseal
```

3. Use kubeseal to encrypt the mysecret.json file in base64 previously generated.
```
$ kubeseal < mysecret.json > mysealedsecret.json

$ cat mysealedsecret.json
```

4. Apply the sealedsecret
```
$ kubectl apply -f mysealedsecret.json
```

5. Verify that the SealedSecret and the linked Secret were created.
```
$ kubectl get sealedsecrets,secrets
```

6. If opened in the same cluster where the SealedSecret was created.  
Then you would see the base64 content of the secret.
And Kubernetes will be able to read it.
```
kubectl get secret mysecret -o yaml
```

Reference: https://github.com/bitnami-labs/sealed-secrets