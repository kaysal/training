
locals {
  web_init = templatefile("scripts/web.sh.tpl", {})
}

resource "google_compute_instance_template" "east_template" {
  name                    = "${var.global.prefix}east-template"
  region                  = "europe-west1"
  machine_type            = "f1-micro"
  metadata_startup_script = local.web_init
  can_ip_forward          = true
  tags                    = ["web"]

  disk {
    source_image = "debian-cloud/debian-9"
    boot         = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.east_subnet.self_link
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
