Used mainly to automate Block Volumes creation and usage for Kubernetes Clusters in Cloud Providers through a StorageClass that interacts with Cloud Provider's API to get and create Persistent Volumes in Kubernetes by using a Persistent Volume Claim that is mounted in a Pod.

PVC is similar to what a Deployment is to a Pod. A Pool of Volumes created upon request.

---

In this Lab theres a first set of 2 manifests, for Cloud Environments.
And a second set with manifests for setting up a StorageClass with NFS to emulate On-Prem the functionality on Cloud.

Pre-Requisites for NFS On-Prem StorageClass Environment.

1. Set Up an NFS Server and make sure that is accessible from the Clients.

# Server and Clients
$ sudo dnf install libnfsidmap nfs4-acl-tools nfs-utils libstoragemgmt-nfs-plugin
$ sudo systemctl start nfs-server.service
$ sudo systemctl enable nfs-server.service

# Only on Server (This is for testing VM lab, not secure on production) 
$ for i in nfs rpc-bind mountd ; do sudo firewall-cmd --permanent --add-service=$i; done
$ /etc/exports >> /disk1/nfs/provisioner [NFS_CLIENT_IP](rw,no_subtree_check,sync,no_wdelay,insecure,no_root_squash)

# Only on Clients
$ showmount -e [NFS_SERVER_IP]

2. Create the NFS StorageClass.
3.1. For this step since K8s doesnt have an internal provisioner for NFS.
3.2. The creation of the same from an external provisioner is required.
3.3. This Lab uses https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner

$ helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
$ helm install my-release nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=x.x.x.x \
        --set nfs.path=/exported/path

4. Start creating PVCs with NFS StorageClass created.

