
# networks
#-----------------------------------------------

resource "google_compute_network" "net_peering" {
  project                 = var.project_id
  name                    = "net-peering"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "us_central1_subnet_peering" {
  project       = var.project_id
  name          = "subnet-peering"
  ip_cidr_range = "10.100.0.0/20"
  region        = "us-central1"
  network       = google_compute_network.net_peering.self_link
}

resource "google_compute_subnetwork" "europe_west1_subnet_peering" {
  project       = var.project_id
  name          = "subnet-peering"
  ip_cidr_range = "10.101.0.0/20"
  region        = "europe-west1"
  network       = google_compute_network.net_peering.self_link
}

# firewall rules


resource "google_compute_firewall" "peering_network_allow_local" {
  name    = "peering-network-allow-local"
  network = google_compute_network.net_peering.self_link

  allow {
    protocol = "all"
  }

  source_ranges = ["10.0.0.0/8"]
}

resource "google_compute_firewall" "peering_network_allow_ssh" {
  name    = "peering-network-allow-ssh"
  network = google_compute_network.net_peering.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}
