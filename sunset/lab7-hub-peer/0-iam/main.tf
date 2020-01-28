
provider "google" {}

provider "google-beta" {}

# onprem
#-----------------------------

# service account

resource "google_service_account" "onprem_sa" {
  account_id   = "${var.global.prefix}onprem-sa"
  display_name = "GCE Service Account"
  project      = var.project_id_onprem
}

# owner role

resource "google_project_iam_member" "onprem_owner" {
  project = var.project_id_onprem
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.onprem_sa.email}"
}

# hub
#-----------------------------

# service account

resource "google_service_account" "hub_sa" {
  account_id   = "${var.global.prefix}hub-sa"
  display_name = "GCE Service Account"
  project      = var.project_id_hub
}

# owner role

resource "google_project_iam_member" "hub_owner" {
  project = var.project_id_hub
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.hub_sa.email}"
}

# spoke1
#-----------------------------

# service account

resource "google_service_account" "spoke1_sa" {
  account_id   = "${var.global.prefix}spoke1-sa"
  display_name = "GCE Service Account"
  project      = var.project_id_spoke1
}

# owner role

resource "google_project_iam_member" "spoke1_owner" {
  project = var.project_id_spoke1
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.spoke1_sa.email}"
}

# spoke2
#-----------------------------

# service account

resource "google_service_account" "spoke2_sa" {
  account_id   = "${var.global.prefix}spoke2-sa"
  display_name = "GCE Service Account"
  project      = var.project_id_spoke2
}

# owner role

resource "google_project_iam_member" "spoke2_owner" {
  project = var.project_id_spoke2
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.spoke2_sa.email}"
}
