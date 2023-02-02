## Create a Domain

resource "digitalocean_domain" "pereirajean" {
    name = "pereirajean.com"
}

## Add A record to the Domain

resource "digitalocean_record" "hello" {
    domain = "${digitalocean_domain.pereirajean.com.name}"
    type = "A"
    name = "hello"
    value = "1.1.1.1" # Replace in UI with IP from Kubernetes Created Load Balancer.
}