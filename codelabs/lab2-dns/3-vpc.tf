
# onprem
#---------------------------------------------

# vpc

module "vpc_onprem" {
  source       = "../modules/vpc"
  network_name = "${local.onprem.prefix}vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name              = "${local.onprem.prefix}-${local.onprem.subnet1}"
      subnet_ip                = "172.16.1.0/24"
      subnet_region            = local.onprem.region
      private_ip_google_access = false
    },
  ]

  secondary_ranges = {
    "${local.onprem.prefix}-${local.onprem.subnet1}" = []
  }
}

# firewall rules

resource "google_compute_firewall" "onprem_allow_ssh" {
  name    = "${local.onprem.prefix}allow-ssh"
  network = module.vpc_onprem.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "onprem_allow_rfc1918" {
  name    = "${local.onprem.prefix}allow-rfc1918"
  network = module.vpc_onprem.network.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.0.0.0/8",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "gcp_dns_egress_proxy" {
  name    = "${local.onprem.prefix}gcp-dns-egress-proxy"
  network = module.vpc_onprem.network.self_link

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

module "vpc_hub" {
  source       = "../modules/vpc"
  network_name = "${local.hub.prefix}vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name              = "${local.hub.prefix}-${local.hub.subnet1}"
      subnet_ip                = "10.10.1.0/24"
      subnet_region            = local.hub.region
      private_ip_google_access = false
    },
  ]

  secondary_ranges = {
    "${local.hub.prefix}-${local.hub.subnet1}" = []
  }
}

# firewall rules

resource "google_compute_firewall" "hub_allow_ssh" {
  name    = "${local.hub.prefix}allow-ssh"
  network = module.vpc_hub.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "hub_allow_rfc1918" {
  name    = "${local.hub.prefix}allow-rfc1918"
  network = module.vpc_hub.network.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.0.0.0/8",
    "192.168.0.0/16"
  ]
}
