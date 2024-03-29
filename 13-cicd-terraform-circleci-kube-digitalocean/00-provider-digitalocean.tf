variable "do_token" {}
variable "circleci_token" {}


terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.25.2"
    }
    circleci = {
      source = "mrolla/circleci"
      version = "0.6.1"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
    token = "${var.do_token}"
}

# Configure the CircleCI Token
provider "circleci" {
  api_token = "${var.circleci_token}"
  vcs_type = "github"
  organization = "wusted"
}