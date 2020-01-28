provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# remote state

data "terraform_remote_state" "east" {
  backend = "local"

  config = {
    path = "../2-east/terraform.tfstate"
  }
}

locals {
  east = {
    subnet  = data.terraform_remote_state.east.outputs.subnet
    network = data.terraform_remote_state.east.outputs.network
  }
}
