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

locals {
  instance_init = templatefile("scripts/instance.sh.tpl", {})
  onprem = {
    subnet  = data.terraform_remote_state.vpc.outputs.subnets.onprem.self_link
    network = data.terraform_remote_state.vpc.outputs.networks.onprem.self_link
  }
  untrust = {
    subnet  = data.terraform_remote_state.vpc.outputs.subnets.untrust.self_link
    network = data.terraform_remote_state.vpc.outputs.networks.untrust.self_link
  }
  trust = {
    subnet  = data.terraform_remote_state.vpc.outputs.subnets.trust.self_link
    network = data.terraform_remote_state.vpc.outputs.networks.trust.self_link
  }
  mgt = {
    subnet  = data.terraform_remote_state.vpc.outputs.subnets.mgt.self_link
    network = data.terraform_remote_state.vpc.outputs.networks.mgt.self_link
  }
  zone1 = {
    subnet  = data.terraform_remote_state.vpc.outputs.subnets.zone1.self_link
    network = data.terraform_remote_state.vpc.outputs.networks.zone1.self_link
  }
}
