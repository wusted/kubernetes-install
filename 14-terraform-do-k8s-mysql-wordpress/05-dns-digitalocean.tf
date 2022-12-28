# Create a new Domain

resource "digitalocean_domain" "pereirajean" {
    name = "pereirajean.com"
}

# Add A Record to the Domain

resource "digitalocean_record" "www" {
    domain = "${digitalocean_domain.pereirajean.name}"
    type = "A"
    name = "www"
    ttl = 30
    value = "${digitalocean_loadbalancer.public.ip}"
}
