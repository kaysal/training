
provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

data "terraform_remote_state" "vpc_nat" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

locals {
  vpc_trust   = data.terraform_remote_state.vpc_nat.outputs.network.vpc_trust
  vpc_untrust = data.terraform_remote_state.vpc_nat.outputs.network.vpc_untrust
  subnet = {
    eu = {
      trust   = data.terraform_remote_state.vpc_nat.outputs.subnetwork.eu.trust
      untrust = data.terraform_remote_state.vpc_nat.outputs.subnetwork.eu.untrust
    }
  }
}
