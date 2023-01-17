# 2 examples for initContainers.

1. Mysql container, wait for initContainer to fetch a file from the Internet.  
    - The file is then added to the pod's shared volume and added to the mysql container.

```
$ kubectl apply -f 01-wget-mysql-pod.yaml

$ kubectl get pods # This will display the Init status

$ kubectl logs pod/mydb -c fetch

$ kubectl logs pod/mydb -c mysql
```

2. Busybox container waiting for initContainer to resolve myservice DNS.  
    - The service needs to be created for succesful init of pod.

```
$ kubectl apply -f 02-nslookup-app.yaml

$ kubectl get pods

$ kubectl logs pod/myapp-pod -c init-nslookup

$ kubectl logs pod/myapp-pod -c myapp-container

$ kubectl apply -f 03-myservice.yaml

$ kubectl logs pod/myapp-pod -c init-nslookup

$ kubectl logs pod/myapp-pod -c myapp-container
```
