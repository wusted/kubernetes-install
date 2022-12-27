variable "do_token" {}
variable "circleci_token" {}

# Configure the DigitalOcean Provider
provider "digitalocean/digitalocean" {
    token = "${var.do_token}"
}

# Configure the CircleCI Token
provider "circleci" {
    api_token = "${var.circleci_token}"
    vcs_type = "github"
    organization = "wusted"
}
