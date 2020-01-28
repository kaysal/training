provider "google" {}
provider "google-beta" {}


# remote state
#---------------------------------------------

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "instances" {
  backend = "local"

  config = {
    path = "../2-instances/terraform.tfstate"
  }
}

locals {
  vpc1 = {
    network     = data.terraform_remote_state.vpc.outputs.networks.vpc1.network
    eu_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.vpc1.eu_subnet
    asia_subnet = data.terraform_remote_state.vpc.outputs.cidrs.vpc1.asia_subnet
    us_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.vpc1.us_subnet
    eu_vm       = data.terraform_remote_state.instances.outputs.instances.vpc1.eu_vm
    asia_vm     = data.terraform_remote_state.instances.outputs.instances.vpc1.asia_vm
    us_vm       = data.terraform_remote_state.instances.outputs.instances.vpc1.us_vm
  }
}
