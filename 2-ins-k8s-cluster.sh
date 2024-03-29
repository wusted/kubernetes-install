#!/bin/bash
## Steps are tested to work.

## PRE: Do the SSH Passwordless, and add the hostnames to /etc/hosts

## Building a Kubernetes Cluster with Kubeadm

1. ON BOTH CONTROL PLANE(MASTER) AND WORKER NODES

## Install Packages
## Log into the Control Plane Node (Note: The following steps must be performed on all three nodes.).
## Create configuration file for containerd:
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

## Load modules:
sudo modprobe overlay
sudo modprobe br_netfilter

## Confirm modules loaded:
lsmod | egrep 'overlay|br_netfilter'

## Set system configurations for Kubernetes networking:
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

## Apply new settings:
sudo sysctl --system

## Confirm sysctl conf:
sysctl -a | egrep 'net.bridge.bridge-nf-call-iptables|net.ipv4.ip_forward|net.bridge.bridge-nf-call-ip6tables'

## Remove any container runtime that may cause conflict in dependencies:
sudo dnf remove -y runc docker containerd podman

## Add the Docker repo and install Docker:
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

## Install containerd:
sudo dnf install -y containerd docker-ce docker-ce-cli containerd.io docker-compose-plugin

## Create default configuration file for containerd:
sudo mkdir -p /etc/containerd

## Generate default containerd configuration and save to the newly created default file:
sudo containerd config default | sudo tee /etc/containerd/config.toml

## Edit config.toml to enable systemd cgroup driver for container d
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

## Enable and start containerd to ensure new configuration file usage and Verify that containerd is running:
for i in enable start status; do systemctl $i containerd.service; done
for i in enable start status; do systemctl $i docker.service; done


## Disable swap:
sudo swapoff -a

## Disable swap on startup in /etc/fstab:
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

## Add Kubernetes to repository list:
cat << EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
  https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

## Install Kubernetes packages (Note: If you get a dpkg lock message, just wait a minute or two before trying the command again):
sudo dnf install -y kubelet kubeadm kubectl

## Turn off automatic updates:
sudo dnf install -y python3-dnf-plugin-versionlock
sudo dnf versionlock add kubeadm kubectl kubelet
sudo dnf versionlock list

## Enable the kubelet service. The kubelet service will fail to start until the cluster is initiliazed:
sudo systemctl enable kubelet

## Install ip-route-tc for cluster initialization and worker nodes join
sudo dnf install -y iproute-tc

## Test
crictl --debug pull nginx



## FIREWALL RULES:
## Disable firewalld:
sudo systemctl stop firewalld
sudo systemctl disable firewalld

## OR 

## ON CONTROL PLAN(MASTER) NODE, INCLUDES CALICO AND FLANNEL PORTS.
## FOR FURTHER INFO: https://projectcalico.docs.tigera.io/getting-started/kubernetes/requirements AND https://github.com/coreos/coreos-kubernetes/blob/master/Documentation/kubernetes-networking.md
for i in 6443/tcp 2379-2380/tcp 10250-10252/tcp 10259/tcp 10257/tcp 10255/tcp 8472/udp 8285/udp 179/tcp 5473/tcp 5473/udp; do firewall-cmd --permanent --add-port=$i; done
## Depending on the Zone used:
for i in 6443/tcp 2379-2380/tcp 10250-10252/tcp 10259/tcp 10257/tcp 10255/tcp 8472/udp 8285/udp 179/tcp 5473/tcp 5473/udp; do firewall-cmd --zone=[replace_with_zone_name] --permanent --add-port=$i; done


firewall-cmd --add-masquerade --permanent
firewall-cmd --reload
systemctl restart firewalld
firewall-cmd --list-all

## ON WORKER NODES:
for i in 10250-10252/tcp 10255/tcp 8472/udp 8285/udp 30000-32767/tcp 179/tcp 5473/tcp 5473/udp; do firewall-cmd --permanent --add-port=$i; done
firewall-cmd --add-masquerade --permanent
firewall-cmd --reload
systemctl restart firewalld
firewall-cmd --list-all


2. ONLY ON THE CONTROL PLANE(MASTER) NODE

## Pull kubernetes kubeadm images
kubeadm config images pull

## Initialize the Cluster
## Initialize the Kubernetes cluster on the control plane node using kubeadm
#
# For Metrics Server later use need to enable bootstrap of Signed Certs for kubelet:

cat << EOF > kubelet-config.yaml 
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
networking:
  podSubnet: 10.244.0.0/16
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
serverTLSBootstrap: true
EOF

## For more information: https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/#kubelet-serving-certs

sudo kubeadm init --config kubelet-config.yaml

## IMPORTANT, COPY(DISPLAY THE "kubeadm join" command displayed it will be needed later)
## Set kubectl access:
sudo su - k8s
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

## CONFIRM POD IP RANGE
kubectl get nodes -o jsonpath='{.items[*].spec.podCIDR}'




######################### IF NEED TO RESTORE THE CONFIGURATION ON EACH NODE:
#sudo kubeadm reset -f
#sudo rm -rf /etc/cni /etc/kubernetes /var/lib/dockershim /var/lib/etcd /var/lib/kubelet /var/run/kubernetes ~/.kube/*
#systemctl restart docker
##############################################



## CHOOSE BETWEEN FLANNEL(SIMPLE) OR CALICO(POLICY-BASED - USES LINUX ROUTING ) CNI Network Providers

All the following with k8s user

## On the Control Plane Node, Deploy Flannel:
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml


#################### OR


## On the Control Plane Node, deploy Calico as Operator:

## Requirements: Firewalld allow 179 tcp port
#
# Prevent NetworkManager from interfering with the interfaces
vim /etc/NetworkManager/conf.d/calico.conf
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:tunl*;interface-name:vxlan.calico;interface-name:vxlan-v6.calico;interface-name:wireguard.cali;interface-name:wg-v6.cali
:wq

# Install the Operator in the Control Plane:
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/tigera-operator.yaml

# Download the custom resources and edit to have the POD IP Pool Range CIDR:
curl https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/custom-resources.yaml -O

vim custom-resources.yaml
Edit ipPools:
     - 
       cidr: 10.244.0.0/16
:wq

# Create the manifest:
kubectl create -f custom-resources.yaml

## Verify the Calico POD IP RANGE:
kubectl get ippools -o yaml | grep cidr

## If will take a few minutes to deploy depending on the cluster size, amount of worker node
watch kubectl get all -n calico-system -o wide



## Join the Worker Nodes to the Cluster
## In the Control Plane Node, create the token and copy the kubeadm join command (NOTE:The join command can also be found in the output from kubeadm init command):
kubeadm token create --print-join-command


3. ONLY ON ALL WORKER NODE
## Paste the kubeadm join command to join the cluster. Use sudo to run it as root:
sudo kubeadm join ...

4. ON BOTH CONTROL PLANE(MASTER) AND WORKER NODES
## Enable the kubelet server. For nodes to communicate with API Server after reboots.
sudo systemctl enable --now kubelet

5. ONLY ON CONTROL PLANE(MASTER) NODE
## In the Control Plane Node, view cluster status (Note: You may have to wait a few moments to allow all nodes to become ready):
kubectl get nodes
kubectl get pods --all-namespaces

## If pods are not Running for calico, but the nodes are added and ready, and the Control Plane node is not ready.
# Deploy a simple manifest to test it.

vim nginx.yaml

apiVersion: v1
kind: Pod
metadata:
  name: nginx
  namespace: default
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80

:wq

## Deploy that manifest and confirm again:
kubectl apply -f nginx.yaml
kubectl get nodes
kubectl get pods --all-namespaces


## CONFIRM KUBELET SIGNED CERTS:
kubectl get csr

## CONDITION will be "Pending" need to be approved:
kubectl certificate approve <CSR-NAME>



## Install Calicoctl, if needed, follow steps in:
https://projectcalico.docs.tigera.io/maintenance/clis/calicoctl/install

## Everything should be working and running now.



### REFERENCES:
https://kubernetes.io/docs/setup/production-environment/container-runtimes/
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
https://kubernetes.io/docs/reference/ports-and-protocols/
https://github.com/flannel-io/flannel/blob/master/Documentation/troubleshooting.md
https://medium.com/@vivekanand.poojari/installing-kubernetes-behind-a-corporate-proxy-bc5582e43fb8
https://developpaper.com/containerd-configure-proxy-server/
https://projectcalico.docs.tigera.io/maintenance/troubleshoot/troubleshooting
https://projectcalico.docs.tigera.io/reference/faq
https://projectcalico.docs.tigera.io/getting-started/kubernetes/self-managed-onprem/onpremises
https://projectcalico.docs.tigera.io/maintenance/clis/calicoctl/install
https://projectcalico.docs.tigera.io/getting-started/kubernetes/requirements
https://kubernetes.io/docs/tutorials/services/connect-applications-service/
https://www.linuxtechi.com/how-to-install-kubernetes-cluster-rhel/
https://kb.novaordis.com/index.php/Kubernetes_Control_Plane_and_Data_Plane_Concepts#:~:text=A%20Kubernetes%20cluster%20consists%20of,known%20as%20the%20control%20plane.

Error for crictl pull image
Is not related to proxy but to firewalld service.
Need to run logging on firewalld and understand which services, ports needs to be added, or else to consider disabling firewalld.service
https://www.cyberciti.biz/faq/enable-firewalld-logging-for-denied-packets-on-linux/
