
# unmanaged instance group

resource "google_compute_instance_group" "eu_ig" {
  project   = var.project_id_vpc1
  name      = "${var.vpc1.prefix}eu-ig"
  zone      = "${var.vpc1.eu.region}-b"
  instances = [local.vpc1.eu_vm.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}

resource "google_compute_instance_group" "asia_ig" {
  project   = var.project_id_vpc1
  name      = "${var.vpc1.prefix}asia-ig"
  zone      = "${var.vpc1.asia.region}-b"
  instances = [local.vpc1.asia_vm.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}

resource "google_compute_instance_group" "us_ig" {
  project   = var.project_id_vpc1
  name      = "${var.vpc1.prefix}us-ig"
  zone      = "${var.vpc1.us.region}-b"
  instances = [local.vpc1.us_vm.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}
