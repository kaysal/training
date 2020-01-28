provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

provider "random" {}

data "terraform_remote_state" "default" {
  backend = "local"

  config = {
    path = "../../1-default/1-vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "custom" {
  backend = "local"

  config = {
    path = "../../2-custom/1-vpc/terraform.tfstate"
  }
}

locals {
  default = data.terraform_remote_state.default.outputs.network.default
  custom  = data.terraform_remote_state.custom.outputs.network.custom
}
