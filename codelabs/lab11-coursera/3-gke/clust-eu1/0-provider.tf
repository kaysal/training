
# gcp

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# remote state

data "terraform_remote_state" "iam" {
  backend = "local"

  config = {
    path = "../../0-iam/terraform.tfstate"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../../1-vpc/terraform.tfstate"
  }
}

# locals

locals {
  vpc          = data.terraform_remote_state.vpc.outputs.network
  eu1_cidr     = data.terraform_remote_state.vpc.outputs.cidrs.eu1_cidr
  eu2_cidr     = data.terraform_remote_state.vpc.outputs.cidrs.eu2_cidr
  eu1_gke_cidr = data.terraform_remote_state.vpc.outputs.cidrs.eu1_gke_cidr
  eu2_gke_cidr = data.terraform_remote_state.vpc.outputs.cidrs.eu2_gke_cidr
  svc_account  = data.terraform_remote_state.iam.outputs.svc_account
}
