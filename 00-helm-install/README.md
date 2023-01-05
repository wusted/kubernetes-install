Requirements: Helm and Flagger

1. Install Helm
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
$ helm version

2. Add repos
$ helm repo add bitnami https://charts.bitnami.com/bitnami

$ helm search repo bitnami
$ helm repo list

--
Stern

https://github.com/stern/stern
