## Create a new domain for the Droplet
#

resource "digitalocean_domain" "pereirajean" {
  name = "pereirajean.com"
}

# Add a record sub to the domain
resource "digitalocean_record" "www" {
  domain = "${digitalocean_domain.pereirajean.name}"
  type   = "A"
  name   = "test"
  ttl    = "30"
  value  = "${digitalocean_droplet.web.ipv4_address}"
}
