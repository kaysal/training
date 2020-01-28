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
  trust = {
    subnet1       = data.terraform_remote_state.vpc.outputs.subnets.trust.subnet1
    subnet2       = data.terraform_remote_state.vpc.outputs.subnets.trust.subnet2
    network       = data.terraform_remote_state.vpc.outputs.networks.trust
    pfsense       = data.terraform_remote_state.instances.outputs.instances.trust.pfsense
    trust_vm_solo = data.terraform_remote_state.instances.outputs.instances.trust.vm_solo
  }
}
