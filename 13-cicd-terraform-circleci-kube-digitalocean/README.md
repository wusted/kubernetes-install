# circle-ci-test
For Circle CI Testing Usage

# Pre-requisites
- Have a CircleCI and Docker accounts.
- Use DigitalOcean Cloud Provider.
- Get the respective token set as environment variables.
- For Terraform to connect to CircleCI and DigitalOcean
- Add the DOCKER_USER and DOCKER_PASS 
- envs to CircleCI for the project.
- add the A record in the Domain Provider for the Load Balancer.

# Usage.

# Step 1 and 2: In this Repo:

If CI is NOT desired, just to deploy a K8sCluster
Then only follow step 1 and 2.

https://github.com/wusted/kubernetes-install/tree/main/13-cicd-terraform-circleci-kube-digitalocean
/wusted/kubernetes-install/13-cicd-terraform-circleci-kube-digitalocean

1. Deploy Cloud Infrastructure.
- Kubernetes Cluster
- Load Balancer
- CircleCI
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

# Step 3 and 4: In this Repo:

https://github.com/wusted/circle-ci-test

3. Add a change to this repo in the .circleci/kube directory 
and add the replacement to the file scripts/ci-deploy.sh
4. Add, Commit and Push the changes from CLI.