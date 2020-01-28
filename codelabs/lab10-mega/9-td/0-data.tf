provider "google" {
  project = var.project_id_svc
}

provider "google-beta" {
  project = var.project_id_svc
}

# project data

data "google_project" "project" {
  project_id = var.project_id_svc
}

# remote state

data "terraform_remote_state" "iam" {
  backend = "local"

  config = {
    path = "../0-iam/terraform.tfstate"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

locals {
  onprem = {
    eu_cidr     = data.terraform_remote_state.vpc.outputs.cidrs.onprem.eu_cidr
    asia_cidr   = data.terraform_remote_state.vpc.outputs.cidrs.onprem.asia_cidr
    us_cidr     = data.terraform_remote_state.vpc.outputs.cidrs.onprem.us_cidr
    svc_account = data.terraform_remote_state.iam.outputs.svc_account.onprem
  }
  hub = {
    vpc_eu1     = data.terraform_remote_state.vpc.outputs.networks.hub.eu1
    vpc_eu1x    = data.terraform_remote_state.vpc.outputs.networks.hub.eu1x
    vpc_eu2     = data.terraform_remote_state.vpc.outputs.networks.hub.eu2
    vpc_eu2x    = data.terraform_remote_state.vpc.outputs.networks.hub.eu2x
    vpc_asia1   = data.terraform_remote_state.vpc.outputs.networks.hub.asia1
    vpc_asia1x  = data.terraform_remote_state.vpc.outputs.networks.hub.asia1x
    vpc_asia2   = data.terraform_remote_state.vpc.outputs.networks.hub.asia2
    vpc_asia2x  = data.terraform_remote_state.vpc.outputs.networks.hub.asia2x
    vpc_us1     = data.terraform_remote_state.vpc.outputs.networks.hub.us1
    vpc_us1x    = data.terraform_remote_state.vpc.outputs.networks.hub.us1x
    vpc_us2     = data.terraform_remote_state.vpc.outputs.networks.hub.us2
    vpc_us2x    = data.terraform_remote_state.vpc.outputs.networks.hub.us2x
    eu1_cidr    = data.terraform_remote_state.vpc.outputs.cidrs.hub.eu1_cidr
    eu1_cidrx   = data.terraform_remote_state.vpc.outputs.cidrs.hub.eu1_cidrx
    eu2_cidr    = data.terraform_remote_state.vpc.outputs.cidrs.hub.eu2_cidr
    eu2_cidrx   = data.terraform_remote_state.vpc.outputs.cidrs.hub.eu2_cidrx
    asia1_cidr  = data.terraform_remote_state.vpc.outputs.cidrs.hub.asia1_cidr
    asia1_cidrx = data.terraform_remote_state.vpc.outputs.cidrs.hub.asia1_cidrx
    asia2_cidr  = data.terraform_remote_state.vpc.outputs.cidrs.hub.asia2_cidr
    asia2_cidrx = data.terraform_remote_state.vpc.outputs.cidrs.hub.asia2_cidrx
    us1_cidr    = data.terraform_remote_state.vpc.outputs.cidrs.hub.us1_cidr
    us1_cidrx   = data.terraform_remote_state.vpc.outputs.cidrs.hub.us1_cidrx
    us2_cidr    = data.terraform_remote_state.vpc.outputs.cidrs.hub.us2_cidr
    us2_cidrx   = data.terraform_remote_state.vpc.outputs.cidrs.hub.us2_cidrx
    svc_account = data.terraform_remote_state.iam.outputs.svc_account.hub
  }
  svc = {
    vpc          = data.terraform_remote_state.vpc.outputs.networks.svc
    eu1_cidr     = data.terraform_remote_state.vpc.outputs.cidrs.svc.eu1_cidr
    eu1_gke_cidr = data.terraform_remote_state.vpc.outputs.cidrs.svc.eu1_gke_cidr
    eu2_cidr     = data.terraform_remote_state.vpc.outputs.cidrs.svc.eu2_cidr
    asia1_cidr   = data.terraform_remote_state.vpc.outputs.cidrs.svc.asia1_cidr
    asia2_cidr   = data.terraform_remote_state.vpc.outputs.cidrs.svc.asia2_cidr
    us1_cidr     = data.terraform_remote_state.vpc.outputs.cidrs.svc.us1_cidr
    us1_gke_cidr = data.terraform_remote_state.vpc.outputs.cidrs.svc.us1_gke_cidr
    us2_cidr     = data.terraform_remote_state.vpc.outputs.cidrs.svc.us2_cidr
    svc_account  = data.terraform_remote_state.iam.outputs.svc_account.svc
  }
}
