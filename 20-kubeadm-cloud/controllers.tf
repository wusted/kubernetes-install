# Creating the controllers

resource "random_string" "kubeadm_token_1" {
    length = 6
    special = false
    upper = false
}

resource "random_string" "kubeadm_token_2" {
    length = 16
    special = false
    upper = false
}

locals {
    kubeadm_token = "${random_string.kubeadm_token_1.result}.${random_string.kubeadm_token_2.result}"
    kube_master = "${element(upcloud_server.controller.*.network_interface[0].ip_address,0)}:6443"
}

resource "upcloud_storage" "controller_storage" {
    size    = 50
    tier    = "maxiops"
    title   = "controller"
    zone    = "us-sjo1"
    clone {
        # Template UUID for Ubuntu 18.04
        id = "01000000-0000-4000-8000-000030080200" 
        #storage = "01a0d2d1-657f-43ac-8e37-bc0a7b0447cd"
        #storage = "CoreOS Stable 1068.8.0"
    }
}


resource "upcloud_server" "controller" {
    zone        = "us-sjo1"
    count       = "1"
    hostname    = "controller-${count.index}"
    cpu         = "4"
    mem         = "8192"

    login {
        user            = "tf"
        keys            = [ "${file("id_rsa.pub")}" ]   # This file has to be in current dir.
        create_password = false
    }

    storage_devices {
        storage = upcloud_storage.controller_storage.id
    }

    network_interface {
      type = "public"
    }

    connection {
        host        = "${element(self.network_interface[0].ip_address,count.index)}"
        type        = "ssh"
        user        = "tf"
        private_key = "${file("id_rsa")}"
    }

    provisioner "file" {
        source      = "install-kubeadm.sh"
        destination = "/home/tf/install-kubeadm.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /home/tf/install-kubeadm.sh",
            "sudo /home/tf/install-kubeadm.sh",
            "sudo kubeadm init --token ${local.kubeadm_token}",
            "sudo kubectl --kubeconfig=/etc/kubernetes/config.yaml apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"
        ]
    }
    
}

output "public_ip_controller" {
    value = "${element(upcloud_server.controller.*.network_interface[0].ip_address, 0)}"
}


# this provisioner will start a Kubernetes master in this machine on-prem,
# with the help of "kubeadm" 

# resource "null_resource" "controller" {
#   count         = "${var.controller_count}"
#   depends_on    = ["upcloud_server.controller"]
#   connection {
#     host        = "${element(upcloud_server.controller.*.ipv4_address, count.index)}"
#     type        = "ssh"
#     user        = "tf"
#     private_key = "${file("id_rsa")}"
#   }

#   provisioner "kubeadm" {
#     config = "${kubeadm.main.config}"
#     role   = "master"
# #    join      = "${count.index == 0 ? "" : aws_instance.masters.0.private_ip}"

#     #nodename = "${self.private_dns}"

#     ignore_checks = [
#       "KubeletVersion",  // the kubelet version in the base image can be very different
#     ]

#     install {
#       auto = true
#     }
#   }
# }