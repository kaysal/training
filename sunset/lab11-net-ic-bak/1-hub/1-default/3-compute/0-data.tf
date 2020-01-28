
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

locals {
  default         = data.terraform_remote_state.default.outputs.network.default
  gclb_vip        = data.terraform_remote_state.default.outputs.gclb_vip
  probe_us_nat_ip = data.terraform_remote_state.default.outputs.probe_us_nat_ip
}
