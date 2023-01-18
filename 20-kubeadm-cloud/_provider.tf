## Configures the provider for Upcloud

terraform {
  required_providers {
    upcloud = {
      source = "UpCloudLtd/upcloud"
      version = "2.8.0"
    }
  }
}

provider "upcloud" {
  # Configuration options
}