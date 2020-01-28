
provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

data "terraform_remote_state" "vpc1" {
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

data "terraform_remote_state" "aws_init" {
  backend = "local"

  config = {
    path = "../../../0-aws-init/1-vpc/terraform.tfstate"
  }
}

locals {
  zones             = "https://www.googleapis.com/compute/v1/projects/nic-host-project/zones"
  vpc1              = data.terraform_remote_state.vpc1.outputs.network.vpc1
  vpc1_hc           = data.terraform_remote_state.compute.outputs.health_check.vpc1
  gclb_vip          = data.terraform_remote_state.vpc1.outputs.gclb_vip
  gclb_standard_vip = data.terraform_remote_state.vpc1.outputs.gclb_standard_vip
  instances         = data.terraform_remote_state.compute.outputs.instances
  templates         = data.terraform_remote_state.compute.outputs.templates
  aws = {
    tokyo_eip     = data.terraform_remote_state.aws_init.outputs.aws.tokyo.eip
    singapore_eip = data.terraform_remote_state.aws_init.outputs.aws.singapore.eip
    london_eip    = data.terraform_remote_state.aws_init.outputs.aws.london.eip
    ohio_eip      = data.terraform_remote_state.aws_init.outputs.aws.ohio.eip
  }
}
