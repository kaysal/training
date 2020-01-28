provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# remote state

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
    subnet_mirror    = data.terraform_remote_state.vpc.outputs.subnets.vpc1.subnet_mirror
    subnet_collector = data.terraform_remote_state.vpc.outputs.subnets.vpc1.subnet_collector
    network          = data.terraform_remote_state.vpc.outputs.networks.vpc1
    pfsense          = data.terraform_remote_state.instances.outputs.instances.vpc1.pfsense
  }
}
