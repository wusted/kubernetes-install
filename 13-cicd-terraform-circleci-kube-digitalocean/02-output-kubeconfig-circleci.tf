resource "local_file" "kubernetes_config" {
    content = "${digitalocean_kubernetes_cluster.jean.kube_config.0.raw_config}"
    filename = "kubeconfig.yaml"
}

resource "circleci_environment_variable" "kubernetes_config" {
    project = "circle-ci-test"
    name = "KUBERNETES_KUBECONFIG"
    value = "${base64encode(digitalocean_kubernetes_cluster.jean.kube_config.0.raw_config)}"

}