
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

data "terraform_remote_state" "aws_init" {
  backend = "local"

  config = {
    path = "../../../0-aws-init/1-vpc/terraform.tfstate"
  }
}

locals {
  default           = data.terraform_remote_state.default.outputs.network.default
  default_hc        = data.terraform_remote_state.compute.outputs.health_check.default
  gclb_vip          = data.terraform_remote_state.default.outputs.gclb_vip
  gclb_vip_standard = data.terraform_remote_state.default.outputs.gclb_vip_standard
  #gclb_vip_premium  = data.terraform_remote_state.default.outputs.gclb_vip_premium
  instances = data.terraform_remote_state.compute.outputs.instances
  templates = data.terraform_remote_state.compute.outputs.templates

  aws = {
    tokyo_eip     = data.terraform_remote_state.aws_init.outputs.aws.tokyo.eip
    singapore_eip = data.terraform_remote_state.aws_init.outputs.aws.singapore.eip
    london_eip    = data.terraform_remote_state.aws_init.outputs.aws.london.eip
    ohio_eip      = data.terraform_remote_state.aws_init.outputs.aws.ohio.eip
  }
}
