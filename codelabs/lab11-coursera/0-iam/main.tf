
provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# service account

resource "google_service_account" "gke_sa" {
  account_id   = "gke-sa"
  display_name = "GCE Service Account"
}

# owner role

resource "google_project_iam_member" "owner" {
  role   = "roles/owner"
  member = "serviceAccount:${google_service_account.gke_sa.email}"
}
