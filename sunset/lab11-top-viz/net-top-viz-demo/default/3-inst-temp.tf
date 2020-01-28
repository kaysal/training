# web
#-------------------------------------------

# asia

resource "google_compute_instance_template" "web_asia" {
  name         = "web-asia"
  region       = var.default.asia.region
  machine_type = var.global.machine_type
  tags         = ["web"]

  disk {
    source_image = var.global.image.debian
    boot         = true
  }

  network_interface {
    network = google_compute_network.default.self_link
    access_config {}
  }

  metadata_startup_script = file("scripts/startup.sh")

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# eu

resource "google_compute_instance_template" "web_eu" {
  name         = "web-eu"
  region       = var.default.eu.region
  machine_type = var.global.machine_type
  tags         = ["web"]

  disk {
    source_image = var.global.image.debian
    boot         = true
  }

  network_interface {
    network = google_compute_network.default.self_link
    access_config {}
  }

  metadata_startup_script = file("scripts/startup.sh")

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# us

resource "google_compute_instance_template" "web_us" {
  name         = "web-us"
  region       = var.default.us.region
  machine_type = var.global.machine_type
  tags         = ["web"]

  disk {
    source_image = var.global.image.debian
    boot         = true
  }

  network_interface {
    network = google_compute_network.default.self_link
    access_config {}
  }

  metadata_startup_script = file("scripts/startup.sh")

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
