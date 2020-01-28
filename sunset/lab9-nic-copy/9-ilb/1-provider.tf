provider "google" {
  project = var.project_id_spoke2
}

provider "google-beta" {
  project = var.project_id_spoke2
}

provider "random" {}
