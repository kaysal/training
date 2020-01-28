
provider "google" {}
provider "google-beta" {}

# onprem
#-----------------------------

# service account

resource "google_service_account" "onprem_sa" {
  account_id   = "onprem-sa"
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
  account_id   = "hub-sa"
  display_name = "GCE Service Account"
  project      = var.project_id_hub
}

# owner role

resource "google_project_iam_member" "hub_owner" {
  project = var.project_id_hub
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.hub_sa.email}"
}

# svc
#-----------------------------

# service account

resource "google_service_account" "svc_sa" {
  account_id   = "svc-sa"
  display_name = "GCE Service Account"
  project      = var.project_id_svc
}

# owner role

resource "google_project_iam_member" "svc_owner" {
  project = var.project_id_svc
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.svc_sa.email}"
}
