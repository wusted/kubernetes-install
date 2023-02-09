resource "digitalocean_kubernetes_cluster" "jean" {
    name = "jean-pod-disruption"
    region = "nyc1"
    version = "1.25.4-do.0"

    node_pool {
        name = "jean-pod-disruption-cluster-nodes"
        size = "s-1vcpu-2gb"
        node_count = 2
        tags = ["jean-pod-disruption-cluster-nodes"]
    }
}