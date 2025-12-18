terraform {
  required_providers {
    genesyscloud = {
      source = "MyPureCloud/genesyscloud"
      # version = "1.47.0"
    }
  }
}

provider "genesyscloud" {
  sdk_debug = true
}
