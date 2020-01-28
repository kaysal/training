# gcp
#----------------------------------

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

data "terraform_remote_state" "default" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "compute" {
  backend = "local"

  config = {
    path = "../3-compute/terraform.tfstate"
  }
}

# ip address data

data "google_compute_address" "gclb_vip_standard" {
  region = var.hub.default.us.region
  name   = "standard-tier"
}

locals {
  default = data.terraform_remote_state.default.outputs.network.default
}
