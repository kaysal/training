# provider

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# remote state

data "terraform_remote_state" "vpc1" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

# local variables

locals {
  vpc1         = data.terraform_remote_state.vpc1.outputs.network.vpc1
  ic_zone1_url = "https://www.googleapis.com/compute/v1/projects/${var.interconnect_project_id}/global/interconnects/${var.hub.vpc1.eu.zone1.interconnect}"
  ic_zone2_url = "https://www.googleapis.com/compute/v1/projects/${var.interconnect_project_id}/global/interconnects/${var.hub.vpc1.eu.zone2.interconnect}"
}
