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
    subnet_eu   = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.subnet_eu
    subnet_asia = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.subnet_asia
    vm_eu       = data.terraform_remote_state.instances.outputs.instances.spoke2.vm_eu
    vm_asia_1   = data.terraform_remote_state.instances.outputs.instances.spoke2.vm_asia_1
    vm_asia_2   = data.terraform_remote_state.instances.outputs.instances.spoke2.vm_asia_2
  }
}
