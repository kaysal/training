# provider

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# remote state

data "terraform_remote_state" "vpc_nat" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

# local variables

locals {
  vpc_anthos = data.terraform_remote_state.vpc_nat.outputs.network.vpc_anthos
  subnet = {
    eu = {
      anthos = data.terraform_remote_state.vpc_nat.outputs.subnetwork.eu.anthos
    }
  }
  ic_zone1_url = "https://www.googleapis.com/compute/v1/projects/${var.interconnect_project_id}/global/interconnects/${var.hub.vpc_anthos.eu.zone1.interconnect}"
  ic_zone2_url = "https://www.googleapis.com/compute/v1/projects/${var.interconnect_project_id}/global/interconnects/${var.hub.vpc_anthos.eu.zone2.interconnect}"
}
