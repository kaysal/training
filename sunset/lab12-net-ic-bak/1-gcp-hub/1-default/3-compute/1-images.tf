
# asia

data "google_compute_image" "image_asia_web" {
  name    = "image-asia-web"
  project = var.project_id
}

# eu

data "google_compute_image" "image_eu_web" {
  name    = "image-eu-web"
  project = var.project_id
}

# us

data "google_compute_image" "image_us_web" {
  name    = "image-us-web"
  project = var.project_id
}
