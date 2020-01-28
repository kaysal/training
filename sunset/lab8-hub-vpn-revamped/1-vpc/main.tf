
provider "google" {}

provider "google-beta" {}

# onprem
#---------------------------------------------

# vpc

resource "google_compute_network" "onprem" {
  provider                = google-beta
  project                 = var.project_id_onprem
  name                    = "${var.onprem.prefix}"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "onprem_belgium" {
  project       = var.project_id_onprem
  name          = "${var.onprem.prefix}belgium"
  ip_cidr_range = var.onprem.belgium.subnet
  region        = var.onprem.belgium.region
  network       = google_compute_network.onprem_vpc.self_link
}

resource "google_compute_subnetwork" "onprem_london" {
  project       = var.project_id_onprem
  name          = "${var.onprem.prefix}london"
  ip_cidr_range = var.onprem.london.subnet
  region        = var.onprem.london.region
  network       = google_compute_network.onprem_vpc.self_link
}

# firewall rules

resource "google_compute_firewall" "onprem_allow_ssh" {
  project = var.project_id_onprem
  name    = "${var.onprem.prefix}allow-ssh"
  network = google_compute_network.onprem_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "onprem_allow_rfc1918" {
  project = var.project_id_onprem
  name    = "${var.onprem.prefix}allow-rfc1918"
  network = google_compute_network.onprem_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}region_cidr

resource "google_compute_firewall" "onprem_dns_egress_proxy" {
  project = var.project_id_onprem
  name    = "${var.onprem.prefix}dns-egress-proxy"
  network = google_compute_network.onprem_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["53"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }

  source_ranges = ["35.199.192.0/19"]
}

# hub
#---------------------------------------------

# vpc

resource "google_compute_network" "hub" {
  provider                = google-beta
  project                 = var.project_id_hub
  name                    = "${var.hub.prefix}"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "hub_belgium" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}belgium"
  ip_cidr_range = var.hub.belgium.cidr
  region        = var.hub.belgium.region
  network       = google_compute_network.hub_vpc.self_link
}

resource "google_compute_subnetwork" "hub_london" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}london"
  ip_cidr_range = var.hub.london.cidr
  region        = var.hub.london.region
  network       = google_compute_network.hub_vpc.self_link
}

# firewall rules

resource "google_compute_firewall" "hub_allow_ssh" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}allow-ssh"
  network = google_compute_network.hub_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "hub_allow_rfc1918" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}allow-rfc1918"
  network = google_compute_network.hub_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "hub_dns_egress_proxy" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}dns-egress-proxy"
  network = google_compute_network.hub_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["53"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }

  source_ranges = ["35.199.192.0/19"]
}

# spoke1
#---------------------------------------------

# vpc

resource "google_compute_network" "spoke1" {
  project                 = var.project_id_spoke1
  provider                = google-beta
  name                    = "${var.spoke1.prefix}"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "spoke1_belgium" {
  project       = var.project_id_spoke1
  name          = "${var.spoke1.prefix}belgium-subnet"
  ip_cidr_range = var.spoke1.belgium.cidr
  region        = var.spoke1.belgium.region
  network       = google_compute_network.spoke1_vpc.self_link
}

resource "google_compute_subnetwork" "spoke1_london" {
  project       = var.project_id_spoke1
  name          = "${var.spoke1.prefix}london"
  ip_cidr_range = var.spoke1.london.cidr
  region        = var.spoke1.london.region
  network       = google_compute_network.spoke1_vpc.self_link
}

# firewall rules

resource "google_compute_firewall" "spoke1_allow_ssh" {
  project = var.project_id_spoke1
  name    = "${var.spoke1.prefix}allow-ssh"
  network = google_compute_network.spoke1_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "spoke1_allow_rfc1918" {
  project = var.project_id_spoke1
  name    = "${var.spoke1.prefix}allow-rfc1918"
  network = google_compute_network.spoke1_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

# routes

resource "google_compute_route" "spoke1_private_googleapis" {
  project          = var.project_id_spoke1
  name             = "${var.spoke1.prefix}private-googleapis"
  description      = "Route to default gateway for private.googleapis.com"
  dest_range       = "199.36.153.4/30"
  network          = google_compute_network.spoke1_vpc.self_link
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}

resource "google_compute_route" "spoke1_restricted_googleapis" {
  project          = var.project_id_spoke1
  name             = "${var.spoke1.prefix}restricted-googleapis"
  description      = "Route to default gateway for restricted.googleapis.com"
  dest_range       = "199.36.153.8/30"
  network          = google_compute_network.spoke1_vpc.self_link
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}

# spoke2
#---------------------------------------------

# vpc

resource "google_compute_network" "spoke2" {
  project                 = var.project_id_spoke2
  provider                = google-beta
  name                    = "${var.spoke2.prefix}"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "spoke2_belgium" {
  project       = var.project_id_spoke2
  name          = "${var.spoke2.prefix}belgium"
  ip_cidr_range = var.spoke2.belgium.cidr
  region        = var.spoke2.belgium.region
  network       = google_compute_network.spoke2_vpc.self_link
}

resource "google_compute_subnetwork" "spoke2_london" {
  project       = var.project_id_spoke2
  name          = "${var.spoke2.prefix}london"
  ip_cidr_range = var.spoke2.london.cidr
  region        = var.spoke2.london.region
  network       = google_compute_network.spoke2_vpc.self_link
}

# firewall rules

resource "google_compute_firewall" "spoke2_allow_ssh" {
  project = var.project_id_spoke2
  name    = "${var.spoke2.prefix}allow-ssh"
  network = google_compute_network.spoke2_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "spoke2_allow_rfc1918" {
  project = var.project_id_spoke2
  name    = "${var.spoke2.prefix}allow-rfc1918"
  network = google_compute_network.spoke2_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

# routes

resource "google_compute_route" "spoke2_private_googleapis" {
  project          = var.project_id_spoke2
  name             = "${var.spoke2.prefix}private-googleapis"
  description      = "Route to default gateway for private.googleapis.com"
  dest_range       = "199.36.153.4/30"
  network          = google_compute_network.spoke2_vpc.self_link
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}

resource "google_compute_route" "spoke2_restricted_googleapis" {
  project          = var.project_id_spoke2
  name             = "${var.spoke2.prefix}restricted-googleapis"
  description      = "Route to default gateway for restricted.googleapis.com"
  dest_range       = "199.36.153.8/30"
  network          = google_compute_network.spoke2_vpc.self_link
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}
