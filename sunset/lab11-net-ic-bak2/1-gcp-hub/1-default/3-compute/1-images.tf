
# browse
#---------------------------------

data "google_compute_image" "browse_asia" {
  name    = "browse-asia"
  project = var.project_id
}

data "google_compute_image" "browse_eu" {
  name    = "browse-eu"
  project = var.project_id
}

data "google_compute_image" "browse_us" {
  name    = "browse-us"
  project = var.project_id
}

# cart
#---------------------------------

data "google_compute_image" "cart_asia" {
  name    = "cart-asia"
  project = var.project_id
}

data "google_compute_image" "cart_eu" {
  name    = "cart-eu"
  project = var.project_id
}

data "google_compute_image" "cart_us" {
  name    = "cart-us"
  project = var.project_id
}

# checkout
#---------------------------------

data "google_compute_image" "checkout_asia" {
  name    = "checkout-asia"
  project = var.project_id
}

data "google_compute_image" "checkout_eu" {
  name    = "checkout-eu"
  project = var.project_id
}

data "google_compute_image" "checkout_us" {
  name    = "checkout-us"
  project = var.project_id
}

# feeds
#---------------------------------

data "google_compute_image" "feeds_asia" {
  name    = "feeds-asia"
  project = var.project_id
}

data "google_compute_image" "feeds_eu" {
  name    = "feeds-eu"
  project = var.project_id
}

data "google_compute_image" "feeds_us" {
  name    = "feeds-us"
  project = var.project_id
}

# db
#---------------------------------

data "google_compute_image" "db_asia" {
  name    = "db-asia"
  project = var.project_id
}

data "google_compute_image" "db_eu" {
  name    = "db-eu"
  project = var.project_id
}

data "google_compute_image" "db_us" {
  name    = "db-us"
  project = var.project_id
}

# payment
#---------------------------------

data "google_compute_image" "payment_us" {
  name    = "payment-us"
  project = var.project_id
}

# mqtt
#---------------------------------

data "google_compute_image" "mqtt_us" {
  name    = "mqtt-us"
  project = var.project_id
}

# batch jobs
#---------------------------------

data "google_compute_image" "batch_job_eu" {
  name    = "batch-job-eu"
  project = var.project_id
}

data "google_compute_image" "batch_job_us" {
  name    = "batch-job-us"
  project = var.project_id
}
