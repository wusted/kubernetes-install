# CI/CD in Gitlab Instance
- GitLab Instance runs in a Docker Container.  
- All resources provisioned with Terraform.  
- Kubernetes Cluster to run the CI/CD Jobs in GitLab.  
- This is not for GitOps. Though, with little modification can be used for that too.

1. Add the do_token environment variable

```
$export TF_VAR_do_token=REPLACE_WITH_TOKEN
```

2. Provision the Cloud Infrastructure with Terraform.  
This will create:  
- 1 Kubernetes Cluster
- Pull in kubeconfig.yaml file
- 1 Droplet Instance
- Push the ssh public key.
- 1 DNS and 1 A Record.

```
$ terraform init

$ terraform plan

$ terraform apply 

# Remember to have the id_rsa.pub in the terraform.state directory
```

3. Once created the access can be tested with:

```
$ kubectl --kubeconfig kubeconfig.yaml get nodes

$ ssh -i /path/to/private/key root@DROPLET_IP
```

4. The IP of the Droplet should be added to A Record git.pereirajean.com  
Add that IP and A record to the Domain Provider.  
Wait for the TTL and access in a web browser:  

```
git.pereirajean.com
```

5. To get the password for GitLab login

```
## Access the instance that is running the docker container with gitlab.
$ ssh -i /path/to/private/key root@DROPLET_IP

## Confirm the container is running and grep the password
$ docker ps
$ sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password

## Password will be the output. User is "root"
## Ref: https://docs.gitlab.com/ee/install/docker.html
```

6. Once logged-in:  
- Disable everyone can sign-up.  
- Install the Agent in the K8s Cluster  
    - https://docs.gitlab.com/ee/user/clusters/agent/install/index.html  
    - https://www.youtube.com/watch?v=XuBpKtsgGkE  
- Create a Project.  
- Create the agent configuration file. config.yaml   
- Add the contents for CI/CD.  
- Connect the Cluster.
- Install the Helm Chart, the install with "--kubeconfig kubeconfig.yaml"  
- Agent is now ready should show as connected in GitLab.  
- Confirm in the cluster:  
```
$ chmod 711 kubeconfig.yaml

$ kubectl --kubeconfig kubeconfig.yaml get ns

$ kubectl --kubeconfig kubeconfig.yaml get all -n gitlab-agent-primary-agent
```

7. In the Kubernetes Cluster Repo.  
- Go to Settings > CI/CD > Runners [Expand]
- Click on [Show runner installation instructions] > [Kubernetes] > [View installation instructions]  
- https://docs.gitlab.com/runner/install/kubernetes-agent.html
- Install the Helm Chart, the install with "--kubeconfig kubeconfig.yaml"
- Create "runner-chart-values.yaml" with the runner token and git server url.  
- Then create a template.
```
$ helm install --namespace gitlab-runner --create-namespace gitlab-runner -f runner-chart-values.yaml --kubeconfig kubeconfig.yaml gitlab/gitlab-runner

$ kubectl get pods -n gitlab-runner --kubeconfig kubeconfig.yaml
```

- Go to Settings > CI/CD > Runners [Expand] 
- Confirm that the Runner is now added and it shows in Runners page.

7. Set the RBAC permissions for the "gitlab-runner:default" ServiceAccount  
```
$ kubectl --kubeconfig kubeconfig.yaml apply -f 04-k8s-rbac.yaml
```


8. With the cluster connected.  
- Create a new project named "test" and in there:

- Go to Settings > CI/CD > Runners [Expand] > Click go to the group's Runners page.
- Edit the Runner created in the Kubernetes Project and Remove the flag for "Lock to current projects" and Save.  

- Go back to the "test" project.
- Go to Settings > CI/CD > Runners [Expand] > Runner should now be available. > Click on [Enable for this Project]

- In "test" project.
- Create a repo in your Docker Hub account, for example:
    - wusted/gitlab-cicd-test
- Go to Settings > CI/CD > Variables [Expand]
- Add Variables for CI_REGISTRY_USER and CI_REGISTRY_PASSWORD for the Docker Registry.
- Add Variables CI_REGISTRY_IMAGE=wusted/gitlab-cicd-test

Then copy the contents of: > To the test project in Gitlab.
```
./test/
./test/src/index.php
./test/.gitlab-ci.yml
./test/Dockerfile
```

9. Go to the "test" Project main page.  
- Click on Pipeline.  
- Go to Jobs, and see the process of the jobs.


10. When finished, if not needed anymore.  
Remember to destroy all of the resources with Terraform.

```
$ terraform destroy
```
