resource "digitalocean_kubernetes_cluster" "jean" {
    name = "jean-helm-cluster"
    region = "nyc1"
    version = "1.25.4-do.0"

    node_pool {
      name = "jean-helm-cluster-nodes"
      size = "2-vcpu-4gb"
      node_count = 2
      tags = ["jean-helm-cluster-nodes"]
    }
}

