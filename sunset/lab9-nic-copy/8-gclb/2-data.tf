
# remote state
#---------------------------------------------

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

locals {
  instance_init = templatefile("scripts/instance.sh.tpl", {})
  spoke1 = {
    network = data.terraform_remote_state.vpc.outputs.networks.spoke1.network
    subnet1 = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.subnet1
  }
}
