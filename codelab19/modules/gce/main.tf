resource "google_compute_instance" "instance" {
  project                   = "${var.project}"
  name                      = "${var.name}"
  machine_type              = "${var.machine_type}"
  zone                      = "${var.zone}"
  allow_stopping_for_update = true
  metadata_startup_script   = "${var.metadata_startup_script}"

  boot_disk {
    initialize_params {
      image = "${var.image}"
    }
  }

  network_interface {
    subnetwork_project = "${var.subnetwork_project}"
    subnetwork         = "${var.subnetwork}"
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
