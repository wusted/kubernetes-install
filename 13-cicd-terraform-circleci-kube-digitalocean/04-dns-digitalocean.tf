# Create a new Domain

resource "digitalocean_domain" "pereirajean" {
    name = "pereirajean.com"
}

# Add A Record to the Domain

resource "digitalocean_record" "kbs" {
    domain = "${digitalocean_domain.pereirajean.name}"
    type = "A"
    name = "kbs"
    ttl = "30"
    value = "${digitalocean_loadbalancer.public.ip}"
}