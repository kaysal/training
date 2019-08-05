
provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# create a regional bucket
resource "google_storage_bucket" "bucket" {
  name          = "${var.onprem.prefix}${var.project_id}"
  location      = var.cloud.region
  force_destroy = true
  storage_class = "REGIONAL"
}

# add objects to bucket
resource "google_storage_bucket_object" "file" {
  name   = "image.png"
  source = "../image.png"
  bucket = google_storage_bucket.bucket.name
}
