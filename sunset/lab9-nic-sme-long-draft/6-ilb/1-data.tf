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
  spoke2 = {
    network     = data.terraform_remote_state.vpc.outputs.networks.spoke2.network
    eu_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.eu_subnet
    asia_subnet = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.asia_subnet
    eu_vm       = data.terraform_remote_state.instances.outputs.instances.spoke2.eu_vm
    asia_vm1    = data.terraform_remote_state.instances.outputs.instances.spoke2.asia_vm1
    asia_vm2    = data.terraform_remote_state.instances.outputs.instances.spoke2.asia_vm2
  }
}
