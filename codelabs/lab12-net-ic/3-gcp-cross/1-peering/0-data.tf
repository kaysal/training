
provider "google" {}
provider "google-beta" {}
provider "random" {}

data "terraform_remote_state" "hub_default" {
  backend = "local"

  config = {
    path = "../../1-gcp-hub/1-default/1-vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "spoke_custom" {
  backend = "local"

  config = {
    path = "../../2-gcp-spoke/1-custom/1-vpc/terraform.tfstate"
  }
}

locals {
  hub_default  = data.terraform_remote_state.hub_default.outputs.network.default
  spoke_custom = data.terraform_remote_state.spoke_custom.outputs.network.custom
}
