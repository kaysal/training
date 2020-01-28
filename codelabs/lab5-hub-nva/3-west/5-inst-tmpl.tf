
locals {
  web_init = templatefile("scripts/web.sh.tpl", {})
}

resource "google_compute_instance_template" "west_template" {
  name                    = "${var.global.prefix}west-template"
  region                  = "europe-west2"
  machine_type            = "f1-micro"
  metadata_startup_script = local.web_init
  can_ip_forward          = true
  tags                    = ["web"]

  disk {
    source_image = "debian-cloud/debian-9"
    boot         = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.west_subnet.self_link
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
