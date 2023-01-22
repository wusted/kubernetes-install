resource "digitalocean_kubernetes_cluster" "jean-1" {
    name = "jean-1"
    region = "nyc1"
    version = "1.25.4-do.0"

    node_pool {
      name = "jean-1-nodes"
      size = "s-1vcpu-2gb"
      node_count = 2
      tags = ["jean-1-nodes"]
    }
}

resource "digitalocean_kubernetes_cluster" "jean-2" {
  name = "jean-2"
  region = "nyc1"
  version = "1.25.4-do.0"

  node_pool {
    name = "jean-2-nodes"
    size = "s-1vcpu-2gb"
    node_count = 2
    tags = ["jean-2-nodes"]
  }
}
