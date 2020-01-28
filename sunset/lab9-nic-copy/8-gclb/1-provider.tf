provider "google" {
  project = var.project_id_spoke1
}

provider "google-beta" {
  project = var.project_id_spoke1
}

provider "random" {}
