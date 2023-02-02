resource "digitalocean_kubernetes_cluster" "jean" {
    name = "jean-nginx-cert-manager"
    region = "nyc1"
    version = "1.25.4-do.0"

    node_pool {
        name = "jean-nginx-cert-manager-nodes"
        size = "s-1vcpu-2gb"
        node_count = 2
        tags = ["jean-nginx-cert-manager-nodes"]
    }
}