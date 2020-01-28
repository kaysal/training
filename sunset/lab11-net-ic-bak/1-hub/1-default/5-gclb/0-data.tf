
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

locals {
  default            = data.terraform_remote_state.default.outputs.network.default
  default_hc         = data.terraform_remote_state.compute.outputs.health_check
  gclb_vip           = data.terraform_remote_state.default.outputs.gclb_vip
  gclb_vip_standard  = data.terraform_remote_state.default.outputs.gclb_vip_standard
  gclb_vip_premium   = data.terraform_remote_state.default.outputs.gclb_vip_premium
  smtp_tcp_proxy_vip = data.terraform_remote_state.default.outputs.smtp_tcp_proxy_vip
  probe_asia_nat_ip  = data.terraform_remote_state.default.outputs.probe_asia_nat_ip
  probe_eu_nat_ip    = data.terraform_remote_state.default.outputs.probe_eu_nat_ip
  probe_us_nat_ip    = data.terraform_remote_state.default.outputs.probe_us_nat_ip
  instances          = data.terraform_remote_state.compute.outputs.instances
}