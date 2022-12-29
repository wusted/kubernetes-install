# Terraform deployment
Backend(MYSQL)+ Frontend(WordPress)  
Goal is to test the Kubernetes/Microservices:  
Immutable and Disposable approach of Nodes and Pods.

# Pre-requisites
- Use DigitalOcean Cloud Provider.
- Get the respective token set as environment variables.
- For Terraform to connect to DigitalOcean
- add the A record in the Domain Provider for the Load Balancer.

# Usage.

1. Deploy Cloud Infrastructure.
- Kubernetes Cluster
- Load Balancer
- Block Volume
- Output File
- DNS Records and Domain

```
$ terraform init
$ terraform plan
$ terraform apply
```

2. Test Kubernetes Cluster

```
$ kubectl --kubeconfig=kubeconfig.yaml get nodes
```

3. Apply the manifests, to create:
- MySQL StatefulSet with one PVC from Cloud StorageClass
- ClusterIP Service for MySQL p-3306-> Wordpress
- WordPress Deployment
- nodePort Service for WordPress p-30000-> LoadBalancer:80

```
$ kubectl -kubeconfig=kubeconfig.yaml apply -f ./kubernetes/
```
Connectivity can be tested with:  
curl or web browser to the LoadBalancerIP or DNS Domain A Record.

4. Access the Site in the Web Browser  
Create a site and user to be stored in the DB Persistent Volume.  
Login with the created credentials and go to Posts.  
Edit the Post Title with a custom one.

5. 
- In Cloud Provider:
Destroy the Worker Node. 
and/or 
- In Kubernetes Cluster:
Delete the Pod(s)(not the Deployment or StatefulSet)
that is using the Persistent Volume through the PVC.

6. 
- In Cloud Provider:  
Kubernetes Cluster Service should create a new Node.  
  
and/or  
- In Kubernetes Cluster:  
Kubernetes Operator/Scheduler should create a new pod,  
due to Deployment or StatefulSet applied desired state.  
  
To replace the one deleted in both cases.  
  
7. Volume data should remain persistent and changes made in previous node or pods,  
should still exist.
Confirm by accessing WordPress again and check the Posts.
Or accesing the main site that should show the Post.
