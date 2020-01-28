
provider "google" {}

provider "google-beta" {}

# remote state

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "router" {
  backend = "local"

  config = {
    path = "../3-router/terraform.tfstate"
  }
}

data "terraform_remote_state" "gateway" {
  backend = "local"

  config = {
    path = "../4-vpn-gw/terraform.tfstate"
  }
}

locals {
  onprem = {
    vpc = data.terraform_remote_state.vpc.outputs.networks.onprem
  }
  hub = {
    vpc_eu1    = data.terraform_remote_state.vpc.outputs.networks.hub.eu1
    vpc_eu1x   = data.terraform_remote_state.vpc.outputs.networks.hub.eu1x
    vpc_eu2    = data.terraform_remote_state.vpc.outputs.networks.hub.eu2
    vpc_eu2x   = data.terraform_remote_state.vpc.outputs.networks.hub.eu2x
    vpc_asia1  = data.terraform_remote_state.vpc.outputs.networks.hub.asia1
    vpc_asia1x = data.terraform_remote_state.vpc.outputs.networks.hub.asia1x
    vpc_asia2  = data.terraform_remote_state.vpc.outputs.networks.hub.asia2
    vpc_asia2x = data.terraform_remote_state.vpc.outputs.networks.hub.asia2x
    vpc_us1    = data.terraform_remote_state.vpc.outputs.networks.hub.us1
    vpc_us1x   = data.terraform_remote_state.vpc.outputs.networks.hub.us1x
    vpc_us2    = data.terraform_remote_state.vpc.outputs.networks.hub.us2
    vpc_us2x   = data.terraform_remote_state.vpc.outputs.networks.hub.us2x
  }
  svc = {
    vpc = data.terraform_remote_state.vpc.outputs.networks.svc
  }
}
