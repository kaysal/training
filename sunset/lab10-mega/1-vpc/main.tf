
provider "google" {}
provider "google-beta" {}

# onprem
#==============================================

# vpc: network

resource "google_compute_network" "onprem_vpc" {
  provider                = google-beta
  project                 = var.project_id_onprem
  name                    = "${var.onprem.prefix}vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# vpc: subnets

resource "google_compute_subnetwork" "onprem_eu_cidr" {
  project       = var.project_id_onprem
  name          = "${var.onprem.prefix}eu-cidr"
  ip_cidr_range = var.onprem.eu.cidr
  region        = var.onprem.eu.region
  network       = google_compute_network.onprem_vpc.self_link

  secondary_ip_range {
    range_name    = "dns-range"
    ip_cidr_range = var.onprem.eu.alias
  }
}

resource "google_compute_subnetwork" "onprem_asia_cidr" {
  project       = var.project_id_onprem
  name          = "${var.onprem.prefix}asia-cidr"
  ip_cidr_range = var.onprem.asia.cidr
  region        = var.onprem.asia.region
  network       = google_compute_network.onprem_vpc.self_link
}

resource "google_compute_subnetwork" "onprem_us_cidr" {
  project       = var.project_id_onprem
  name          = "${var.onprem.prefix}us-cidr"
  ip_cidr_range = var.onprem.us.cidr
  region        = var.onprem.us.region
  network       = google_compute_network.onprem_vpc.self_link
}

# vpc: firewall rules

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
}

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
#==============================================

# eu1
#---------------------------------------------

# vpc: network

resource "google_compute_network" "hub_eu1_vpc" {
  provider                = google-beta
  project                 = var.project_id_hub
  name                    = "${var.hub.prefix}eu1-vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# vpc: subnets

resource "google_compute_subnetwork" "hub_eu1_cidr" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}eu1-cidr"
  ip_cidr_range = var.hub.eu1.cidr
  region        = var.hub.eu1.region
  network       = google_compute_network.hub_eu1_vpc.self_link
}

# vpc: firewall rules

resource "google_compute_firewall" "hub_eu1_allow_ssh" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}eu1-allow-ssh"
  network = google_compute_network.hub_eu1_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "hub_eu1_allow_rfc1918" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}eu1-allow-rfc1918"
  network = google_compute_network.hub_eu1_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "hub_eu1_dns_egress_proxy" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}eu1-dns-egress-proxy"
  network = google_compute_network.hub_eu1_vpc.self_link

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

# vpcx: network

resource "google_compute_network" "hub_eu_vpcx" {
  provider                = google-beta
  project                 = var.project_id_hub
  name                    = "${var.hub.prefix}eu-vpcx"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# vpcx: subnets

resource "google_compute_subnetwork" "hub_eu1_cidrx" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}eu1-cidrx"
  ip_cidr_range = var.hub.eu1.cidrx
  region        = var.hub.eu1.region
  network       = google_compute_network.hub_eu_vpcx.self_link
}

resource "google_compute_subnetwork" "hub_eu2_cidrx" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}eu2-cidrx"
  ip_cidr_range = var.hub.eu2.cidrx
  region        = var.hub.eu2.region
  network       = google_compute_network.hub_eu_vpcx.self_link
}

# vpcx: firewall rules

resource "google_compute_firewall" "hub_eu1_allow_sshx" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}eu1-allow-sshx"
  network = google_compute_network.hub_eu_vpcx.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "hub_eu1_allow_rfc1918x" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}eu1-allow-rfc1918x"
  network = google_compute_network.hub_eu_vpcx.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "hub_eu1_dns_egress_proxyx" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}eu1-dns-egress-proxyx"
  network = google_compute_network.hub_eu_vpcx.self_link

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

# eu2
#---------------------------------------------

# vpc: network

resource "google_compute_network" "hub_eu2_vpc" {
  provider                = google-beta
  project                 = var.project_id_hub
  name                    = "${var.hub.prefix}eu2-vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# vpc: subnets

resource "google_compute_subnetwork" "hub_eu2_cidr" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}eu2-cidr"
  ip_cidr_range = var.hub.eu2.cidr
  region        = var.hub.eu2.region
  network       = google_compute_network.hub_eu2_vpc.self_link
}

# vpc: firewall rules

resource "google_compute_firewall" "hub_eu2_allow_ssh" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}eu2-allow-ssh"
  network = google_compute_network.hub_eu2_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "hub_eu2_allow_rfc1918" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}eu2-allow-rfc1918"
  network = google_compute_network.hub_eu2_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "hub_eu2_dns_egress_proxy" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}eu2-dns-egress-proxy"
  network = google_compute_network.hub_eu2_vpc.self_link

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

# asia1
#---------------------------------------------

# vpc: network

resource "google_compute_network" "hub_asia1_vpc" {
  provider                = google-beta
  project                 = var.project_id_hub
  name                    = "${var.hub.prefix}asia1-vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# vpc: subnets

resource "google_compute_subnetwork" "hub_asia1_cidr" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}asia1-cidr"
  ip_cidr_range = var.hub.asia1.cidr
  region        = var.hub.asia1.region
  network       = google_compute_network.hub_asia1_vpc.self_link
}

# vpc: firewall rules

resource "google_compute_firewall" "hub_asia1_allow_ssh" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}asia1-allow-ssh"
  network = google_compute_network.hub_asia1_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "hub_asia1_allow_rfc1918" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}asia1-allow-rfc1918"
  network = google_compute_network.hub_asia1_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "hub_asia1_dns_egress_proxy" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}asia1-dns-egress-proxy"
  network = google_compute_network.hub_asia1_vpc.self_link

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

# vpcx: network

resource "google_compute_network" "hub_asia_vpcx" {
  provider                = google-beta
  project                 = var.project_id_hub
  name                    = "${var.hub.prefix}asia-vpcx"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# vpcx: subnets

resource "google_compute_subnetwork" "hub_asia1_cidrx" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}asia1-cidrx"
  ip_cidr_range = var.hub.asia1.cidrx
  region        = var.hub.asia1.region
  network       = google_compute_network.hub_asia_vpcx.self_link
}

resource "google_compute_subnetwork" "hub_asia2_cidrx" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}asia2-cidrx"
  ip_cidr_range = var.hub.asia2.cidrx
  region        = var.hub.asia2.region
  network       = google_compute_network.hub_asia_vpcx.self_link
}

# vpcx: firewall rules

resource "google_compute_firewall" "hub_asia1_allow_sshx" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}asia1-allow-sshx"
  network = google_compute_network.hub_asia_vpcx.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "hub_asia1_allow_rfc1918x" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}asia1-allow-rfc1918x"
  network = google_compute_network.hub_asia_vpcx.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "hub_asia1_dns_egress_proxyx" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}asia1-dns-egress-proxyx"
  network = google_compute_network.hub_asia_vpcx.self_link

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

# asia2
#---------------------------------------------

# vpc: network

resource "google_compute_network" "hub_asia2_vpc" {
  provider                = google-beta
  project                 = var.project_id_hub
  name                    = "${var.hub.prefix}asia2-vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# vpc: subnets

resource "google_compute_subnetwork" "hub_asia2_cidr" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}asia2-cidr"
  ip_cidr_range = var.hub.asia2.cidr
  region        = var.hub.asia2.region
  network       = google_compute_network.hub_asia2_vpc.self_link
}

# vpc: firewall rules

resource "google_compute_firewall" "hub_asia2_allow_ssh" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}asia2-allow-ssh"
  network = google_compute_network.hub_asia2_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "hub_asia2_allow_rfc1918" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}asia2-allow-rfc1918"
  network = google_compute_network.hub_asia2_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "hub_asia2_dns_egress_proxy" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}asia2-dns-egress-proxy"
  network = google_compute_network.hub_asia2_vpc.self_link

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

# us1
#---------------------------------------------

# vpc: network

resource "google_compute_network" "hub_us1_vpc" {
  provider                = google-beta
  project                 = var.project_id_hub
  name                    = "${var.hub.prefix}us1-vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# vpc: subnets

resource "google_compute_subnetwork" "hub_us1_cidr" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}us1-cidr"
  ip_cidr_range = var.hub.us1.cidr
  region        = var.hub.us1.region
  network       = google_compute_network.hub_us1_vpc.self_link
}

# vpc: firewall rules

resource "google_compute_firewall" "hub_us1_allow_ssh" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}us1-allow-ssh"
  network = google_compute_network.hub_us1_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "hub_us1_allow_rfc1918" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}us1-allow-rfc1918"
  network = google_compute_network.hub_us1_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "hub_us1_dns_egress_proxy" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}us1-dns-egress-proxy"
  network = google_compute_network.hub_us1_vpc.self_link

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

# vpcx: network

resource "google_compute_network" "hub_us_vpcx" {
  provider                = google-beta
  project                 = var.project_id_hub
  name                    = "${var.hub.prefix}us-vpcx"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# vpcx: subnets

resource "google_compute_subnetwork" "hub_us1_cidrx" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}us1-cidrx"
  ip_cidr_range = var.hub.us1.cidrx
  region        = var.hub.us1.region
  network       = google_compute_network.hub_us_vpcx.self_link
}

resource "google_compute_subnetwork" "hub_us2_cidrx" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}us2-cidrx"
  ip_cidr_range = var.hub.us2.cidrx
  region        = var.hub.us2.region
  network       = google_compute_network.hub_us_vpcx.self_link
}

# vpcx: firewall rules

resource "google_compute_firewall" "hub_us1_allow_sshx" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}us1-allow-sshx"
  network = google_compute_network.hub_us_vpcx.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "hub_us1_allow_rfc1918x" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}us1-allow-rfc1918x"
  network = google_compute_network.hub_us_vpcx.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "hub_us1_dns_egress_proxyx" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}us1-dns-egress-proxyx"
  network = google_compute_network.hub_us_vpcx.self_link

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

# us2
#---------------------------------------------

# vpc: network

resource "google_compute_network" "hub_us2_vpc" {
  provider                = google-beta
  project                 = var.project_id_hub
  name                    = "${var.hub.prefix}us2-vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# vpc: subnets

resource "google_compute_subnetwork" "hub_us2_cidr" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}us2-cidr"
  ip_cidr_range = var.hub.us2.cidr
  region        = var.hub.us2.region
  network       = google_compute_network.hub_us2_vpc.self_link
}

# vpc: firewall rules

resource "google_compute_firewall" "hub_us2_allow_ssh" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}us2-allow-ssh"
  network = google_compute_network.hub_us2_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "hub_us2_allow_rfc1918" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}us2-allow-rfc1918"
  network = google_compute_network.hub_us2_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "hub_us2_dns_egress_proxy" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}us2-dns-egress-proxy"
  network = google_compute_network.hub_us2_vpc.self_link

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

# svc
#==============================================

# vpc: network

resource "google_compute_network" "svc_vpc" {
  provider                = google-beta
  project                 = var.project_id_svc
  name                    = "${var.svc.prefix}vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# vpc: subnets

resource "google_compute_subnetwork" "svc_eu_cidr" {
  project       = var.project_id_svc
  name          = "${var.svc.prefix}eu-cidr"
  ip_cidr_range = var.svc.eu.cidr
  region        = var.svc.eu.region
  network       = google_compute_network.svc_vpc.self_link
}

resource "google_compute_subnetwork" "svc_asia_cidr" {
  project       = var.project_id_svc
  name          = "${var.svc.prefix}asia-cidr"
  ip_cidr_range = var.svc.asia.cidr
  region        = var.svc.asia.region
  network       = google_compute_network.svc_vpc.self_link
}

resource "google_compute_subnetwork" "svc_us_cidr" {
  project       = var.project_id_svc
  name          = "${var.svc.prefix}us-cidr"
  ip_cidr_range = var.svc.us.cidr
  region        = var.svc.us.region
  network       = google_compute_network.svc_vpc.self_link
}

# vpc: firewall rules

resource "google_compute_firewall" "svc_allow_ssh" {
  project = var.project_id_svc
  name    = "${var.svc.prefix}allow-ssh"
  network = google_compute_network.svc_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "svc_allow_rfc1918" {
  project = var.project_id_svc
  name    = "${var.svc.prefix}allow-rfc1918"
  network = google_compute_network.svc_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "svc_dns_egress_proxy" {
  project = var.project_id_svc
  name    = "${var.svc.prefix}dns-egress-proxy"
  network = google_compute_network.svc_vpc.self_link

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
