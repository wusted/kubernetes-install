## Create a new domain for the Droplet
#

resource "digitalocean_domain" "[domain_name]" {
  name = "jean"
}

# Add a record to the domain
resource "digitalocean_record" "www" {
  domain = "${digitalocean_domain.jean.name}"
  type   = "A"
  name   = "[record_name]"
  ttl    = "30"
  value  = "${digitalocean_droplet.web.ipv4_address}"
}