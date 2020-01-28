
provider "google" {}
provider "google-beta" {}

data "google_compute_lb_ip_ranges" "ranges" {}
