resource "digitalocean_kubernetes_cluster" "jean" {
    name = "jean-resource-cluster"
    region = "nyc1"
    version = "1.25.4-do.0"

    node_pool {
      name = "jean-resource-cluster-nodes"
      size = "s-2vcpu-4gb"
      node_count = 2
      tags = ["jean-resource-cluster-nodes"]
    }
}

