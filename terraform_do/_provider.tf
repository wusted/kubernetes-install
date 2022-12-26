variable "do_token" {}

terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

## Token

provider "digitalocean" {
  token = var.do_token
}

## SSH Key

resource "digitalocean_ssh_key" "jean" {
  name       = "jean"
  public_key = "${file("id_rsa.pub")}"
}
