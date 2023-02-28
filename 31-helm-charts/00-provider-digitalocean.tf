variable "do_token" {}

terraform {
  required_providers {
    digitalocean = {
        source = "digitalocean/digitalocean"
        version = "2.25.2"
    }
  }
}

## Configure DigitalOcean Provider
provider "digitalocean" {
    token = "${var.do_token}"  
}