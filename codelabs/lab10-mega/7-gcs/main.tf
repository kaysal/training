
provider "google" {}

provider "google-beta" {}

data "terraform_remote_state" "iam" {
  backend = "local"

  config = {
    path = "../0-iam/terraform.tfstate"
  }
}

locals {
  onprem = {
    svc_account = data.terraform_remote_state.iam.outputs.svc_account.onprem
  }
  hub = {
    svc_account = data.terraform_remote_state.iam.outputs.svc_account.hub
  }
  svc = {
    svc_account = data.terraform_remote_state.iam.outputs.svc_account.svc
  }
  spoke2 = {
    svc_account = data.terraform_remote_state.iam.outputs.svc_account.spoke2
  }
}

# spoke 1

## europe-west1 bucket

resource "google_storage_bucket" "svc_bucket" {
  project       = var.project_id_svc
  name          = "${var.global.prefix}${var.project_id_svc}"
  location      = "europe-west1"
  force_destroy = true
  storage_class = "REGIONAL"
}

resource "google_storage_bucket_object" "svc_file" {
  name   = "svc.txt"
  source = "./objects/svc.txt"
  bucket = google_storage_bucket.svc_bucket.name
}

# acl for allUsers

resource "google_storage_bucket_iam_binding" "svc_binding" {
  bucket = google_storage_bucket.svc_bucket.name
  role   = "roles/storage.objectViewer"

  members = [
    "serviceAccount:${local.onprem.svc_account.email}",
    "serviceAccount:${local.svc.svc_account.email}",
    "serviceAccount:${local.spoke2.svc_account.email}",
  ]
}

# spoke 2

## europe-west1 bucket

resource "google_storage_bucket" "spoke2_bucket" {
  project       = var.project_id_spoke2
  name          = "${var.global.prefix}${var.project_id_spoke2}"
  location      = "europe-west1"
  force_destroy = true
  storage_class = "REGIONAL"
}

resource "google_storage_bucket_object" "spoke2_file" {
  name   = "spoke2.txt"
  source = "./objects/spoke2.txt"
  bucket = google_storage_bucket.spoke2_bucket.name
}

# acl for allUsers

resource "google_storage_bucket_iam_binding" "spoke2_binding" {
  bucket = google_storage_bucket.spoke2_bucket.name
  role   = "roles/storage.objectViewer"

  members = [
    "serviceAccount:${local.onprem.svc_account.email}",
    "serviceAccount:${local.svc.svc_account.email}",
    "serviceAccount:${local.spoke2.svc_account.email}",
  ]
}
