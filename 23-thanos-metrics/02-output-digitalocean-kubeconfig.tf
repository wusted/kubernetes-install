resource "local_file" "kubernetes-1_config" {
    content = "${digitalocean_kubernetes_cluster.jean-1.kube_config.0.raw_config}"
    filename = "jean-1_kubeconfig.yaml"
}

resource "local_file" "kubernetes-2_config" {
    content = "${digitalocean_kubernetes_cluster.jean-2.kube_config.0.raw_config}"
    filename = "jean-2_kubernetes.yaml"
}