
# onprem
#---------------------------------------------

# vpc

module "vpc_onprem" {
  source       = "../modules/vpc"
  network_name = "${local.onprem.prefix}vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name              = local.onprem.subnet1
      subnet_ip                = "10.10.1.0/24"
      subnet_region            = local.onprem.region
      private_ip_google_access = false
    },
  ]

  secondary_ranges = {
    "${local.onprem.subnet1}" = []
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

resource "google_compute_firewall" "onprem_allow_icmp" {
  name    = "${local.onprem.prefix}allow-icmp"
  network = module.vpc_onprem.network.self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8", "172.0.0.0/8", ]
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
      subnet_name              = local.hub.subnet1
      subnet_ip                = "172.16.1.0/24"
      subnet_region            = local.hub.region
      private_ip_google_access = false
    },
  ]

  secondary_ranges = {
    "${local.hub.subnet1}" = []
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

resource "google_compute_firewall" "hub_allow_icmp" {
  name    = "${local.hub.prefix}allow-icmp"
  network = module.vpc_hub.network.self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8", "172.0.0.0/8", ]
}
