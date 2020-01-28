
# unmanaged instance group

resource "google_compute_instance_group" "eu_ig" {
  project   = var.project_id_spoke1
  name      = "${var.spoke1.prefix}eu-ig"
  zone      = "${var.spoke1.eu.region}-b"
  instances = [local.spoke1.eu_vm.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}

resource "google_compute_instance_group" "asia_ig" {
  project   = var.project_id_spoke1
  name      = "${var.spoke1.prefix}asia-ig"
  zone      = "${var.spoke1.asia.region}-b"
  instances = [local.spoke1.asia_vm.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}

resource "google_compute_instance_group" "us_ig" {
  project   = var.project_id_spoke1
  name      = "${var.spoke1.prefix}us-ig"
  zone      = "${var.spoke1.us.region}-b"
  instances = [local.spoke1.us_vm.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}
