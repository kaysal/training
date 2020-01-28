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
  spoke1 = {
    network     = data.terraform_remote_state.vpc.outputs.networks.spoke1.network
    subnet_eu   = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.subnet_eu
    subnet_asia = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.subnet_asia
    subnet_us   = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.subnet_us
    vm_eu       = data.terraform_remote_state.instances.outputs.instances.spoke1.vm_eu
    vm_asia     = data.terraform_remote_state.instances.outputs.instances.spoke1.vm_asia
    vm_us       = data.terraform_remote_state.instances.outputs.instances.spoke1.vm_us
  }
}
