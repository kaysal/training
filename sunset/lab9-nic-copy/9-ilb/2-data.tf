
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
  spoke2 = {
    network = data.terraform_remote_state.vpc.outputs.networks.spoke2
    subnet1 = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.subnet1
  }
}
