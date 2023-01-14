## Droplet's SSH Key Output

resource "digitalocean_ssh_key" "jean" {
    name       = "jean"
    public_key = "${file("id_rsa.pub")}"
}

## Create the Droplet and reference the cloud-config file

resource "digitalocean_droplet" "gitlab" {
    image = "ubuntu-18-04-x64"
    name = "gitlab-1"
    region = "nyc1"
    size = "s-2vcpu-4gb"
    user_data = "${file("userdata.yaml")}"
    ssh_keys = ["${digitalocean_ssh_key.jean.fingerprint}"]
}

## Create a Domain

resource "digitalocean_domain" "pereirajean" {
    name = "pereirajean.com"
}

## Add A record to the Domain - 
## If needed a LoadBalancer can be created to put in front of the Droplet

resource "digitalocean_record" "git" {
    domain = "${digitalocean.domain.pereirajean.name}"
    type = "A"
    name = "git"
    value = "${digitalocean_droplet.gitlab.ipv4_address}"
}

