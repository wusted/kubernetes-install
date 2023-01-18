# Creating a Kubeadm cluster in Upclod with Terraform.

- IMPORTANT, currently not working due to count.index update on terraform.
- Debugging
- Alternative: https://www.linode.com/docs/guides/how-to-provision-an-unmanaged-kubernetes-cluster-using-terraform/

1. Add the environment variables for the session or to the .bashrc, .zshrc file.
https://upcloud.com/resources/tutorials/getting-started-upcloud-api
```
$ export UPCLOUD_USERNAME="Username de user Upcloud API"
$ export UPCLOUD_PASSWORD="Password del user Upcloud API"
```

2. Make sure id_rsa.pub and id_rsa are in current directory.

3. Terraform deploy
```
$ for i in init plan apply; do terraform $i; done
```

4. Destroy everything when not needed
```
$ terraform destroy
```