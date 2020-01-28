

locals {
  ic_zone1_url = "https://www.googleapis.com/compute/v1/projects/jlr-tst-interconnect/global/interconnects/jlr-tst-ic-main"
  ic_zone2_url = "https://www.googleapis.com/compute/v1/projects/jlr-tst-interconnect/global/interconnects/jlr-tst-ic-backup"
  project_id_1 = "jlr-tst-host-1-09dde147"
  project_id_2 = "jlr-tst-host-2-d39a996d"
}


# zone1

## cloud routers (for two projects)

resource "google_compute_router" "jlr-tst-hst-1-main-rtr" {
  project = local.project_id_1
  name    = "jlr-tst-hst-1-main-rtr"
  network = "https://www.googleapis.com/compute/v1/projects/jlr-tst-host-1-09dde147/global/networks/custom-host-vpc"
  region  = "europe-west2"
  bgp {
    asn               = "16550"
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

resource "google_compute_router" "jlr-tst-hst-2-main-rtr" {
  project = local.project_id_2
  name    = "jlr-tst-hst-2-main-rtr"
  network = "https://www.googleapis.com/compute/v1/projects/jlr-tst-host-2-d39a996d/global/networks/custom-host-vpc"
  region  = "europe-west2"
  bgp {
    asn               = "65205"
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

## interconnect attachments for two projects

resource "google_compute_interconnect_attachment" "jlr-tst-hst-1-main-att" {
  project           = local.project_id_1
  name              = "jlr-tst-hst-1-main-att"
  interconnect      = local.ic_zone1_url
  type              = "DEDICATED"
  region            = "europe-west2"
  bandwidth         = "BPS_10G"
  vlan_tag8021q     = 1006
  router            = google_compute_router.jlr-tst-hst-1-main-rtr.self_link
  candidate_subnets = ["169.254.9.32/29"]
  admin_enabled     = true

  lifecycle {
    ignore_changes = all
  }
}

resource "google_compute_interconnect_attachment" "jlr-tst-hst-2-main-att" {
  project           = local.project_id_2
  name              = "jlr-tst-hst-2-main-att"
  interconnect      = local.ic_zone1_url
  type              = "DEDICATED"
  region            = "europe-west2"
  bandwidth         = "BPS_10G"
  vlan_tag8021q     = 1007
  router            = google_compute_router.jlr-tst-hst-2-main-rtr.self_link
  candidate_subnets = ["169.254.55.88/29"]
  admin_enabled     = true

  lifecycle {
    ignore_changes = all
  }
}



## cloud routers interfaces (two projects, two main router)

resource "google_compute_router_interface" "jlr-tst-hst-1-main-rtr-ic-int" {
  project                 = local.project_id_1
  region                  = "europe-west2"
  name                    = "jlr-tst-hst-1-main-rtr-ic-int"
  interconnect_attachment = google_compute_interconnect_attachment.jlr-tst-hst-1-main-att.name
  router                  = google_compute_router.jlr-tst-hst-1-main-rtr.self_link
  ip_range                = "169.254.9.33/29"
}

resource "google_compute_router_interface" "jlr-tst-hst-2-main-rtr-ic-int" {
  project                 = local.project_id_2
  region                  = "europe-west2"
  name                    = "jlr-tst-hst-2-main-rtr-ic-int"
  interconnect_attachment = google_compute_interconnect_attachment.jlr-tst-hst-2-main-att.name
  router                  = google_compute_router.jlr-tst-hst-2-main-rtr.self_link
  ip_range                = "169.254.55.89/29"
}



## cloud router bgp peers (for two projects)

resource "google_compute_router_peer" "jlr-tst-hst-1-main-peer" {
  project                   = local.project_id_1
  region                    = "europe-west2"
  name                      = "jlr-tst-hst-1-main-peer"
  router                    = google_compute_router.jlr-tst-hst-1-main-rtr.name
  interface                 = google_compute_router_interface.jlr-tst-hst-1-main-rtr-ic-int.name
  peer_ip_address           = "169.254.9.34"
  peer_asn                  = "65201"
  advertised_route_priority = 1006
}

resource "google_compute_router_peer" "jlr-tst-hst-2-main-peer" {
  project                   = local.project_id_2
  region                    = "europe-west2"
  name                      = "jlr-tst-hst-2-main-peer"
  router                    = google_compute_router.jlr-tst-hst-2-main-rtr.name
  interface                 = google_compute_router_interface.jlr-tst-hst-2-main-rtr-ic-int.name
  peer_ip_address           = "169.254.55.90"
  peer_asn                  = "65208"
  advertised_route_priority = 1007
}

# zone2

## cloud routers (for two projects)

resource "google_compute_router" "jlr-tst-hst-1-backup-rtr" {
  project = local.project_id_1
  name    = "jlr-tst-hst-1-backup-rtr"
  network = "https://www.googleapis.com/compute/v1/projects/jlr-tst-host-1-09dde147/global/networks/custom-host-vpc"
  region  = "europe-west1"
  bgp {
    asn               = "16550"
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

resource "google_compute_router" "jlr-tst-hst-2-backup-rtr" {
  project = local.project_id_2
  name    = "jlr-tst-hst-2-backup-rtr"
  network = "https://www.googleapis.com/compute/v1/projects/jlr-tst-host-2-d39a996d/global/networks/custom-host-vpc"
  region  = "europe-west1"
  bgp {
    asn               = "65205"
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}


## interconnect attachments for two projects

resource "google_compute_interconnect_attachment" "jlr-tst-hst-1-backup-att" {
  project           = local.project_id_1
  name              = "jlr-tst-hst-1-backup-att"
  interconnect      = local.ic_zone1_url
  type              = "DEDICATED"
  region            = "europe-west1"
  bandwidth         = "BPS_10G"
  vlan_tag8021q     = 1006
  router            = google_compute_router.jlr-tst-hst-1-backup-rtr.self_link
  candidate_subnets = ["169.254.94.80/29"]
  admin_enabled     = true

  lifecycle {
    ignore_changes = all
  }
}

resource "google_compute_interconnect_attachment" "jlr-tst-hst-2-backup-att" {
  project           = local.project_id_2
  name              = "jlr-tst-hst-2-backup-att"
  interconnect      = local.ic_zone1_url
  type              = "DEDICATED"
  region            = "europe-west1"
  bandwidth         = "BPS_10G"
  vlan_tag8021q     = 1007
  router            = google_compute_router.jlr-tst-hst-2-backup-rtr.self_link
  candidate_subnets = ["169.254.11.64/29"]
  admin_enabled     = true

  lifecycle {
    ignore_changes = all
  }
}



## cloud routers interfaces (two projects, two backup router)

resource "google_compute_router_interface" "jlr-tst-hst-1-backup-rtr-ic-int" {
  project                 = local.project_id_1
  region                  = "europe-west1"
  name                    = "jlr-tst-hst-1-backup-rtr-ic-int"
  interconnect_attachment = google_compute_interconnect_attachment.jlr-tst-hst-1-backup-att.name
  router                  = google_compute_router.jlr-tst-hst-1-backup-rtr.self_link
  ip_range                = "169.254.94.81/29"
}

resource "google_compute_router_interface" "jlr-tst-hst-2-backup-rtr-ic-int" {
  project                 = local.project_id_2
  region                  = "europe-west1"
  name                    = "jlr-tst-hst-2-backup-rtr-ic-int"
  interconnect_attachment = google_compute_interconnect_attachment.jlr-tst-hst-2-backup-att.name
  router                  = google_compute_router.jlr-tst-hst-2-backup-rtr.self_link
  ip_range                = "169.254.11.65/29"
}



## cloud router bgp peers (for two projects)

resource "google_compute_router_peer" "jlr-tst-hst-1-backup-peer" {
  project                   = local.project_id_1
  region                    = "europe-west1"
  name                      = "jlr-tst-hst-1-backup-peer"
  router                    = google_compute_router.jlr-tst-hst-1-backup-rtr.name
  interface                 = google_compute_router_interface.jlr-tst-hst-1-backup-rtr-ic-int.name
  peer_ip_address           = "169.254.94.82"
  peer_asn                  = "65301"
  advertised_route_priority = 1006
}

resource "google_compute_router_peer" "jlr-tst-hst-2-backup-peer" {
  project                   = local.project_id_2
  region                    = "europe-west1"
  name                      = "jlr-tst-hst-2-backup-peer"
  router                    = google_compute_router.jlr-tst-hst-2-backup-rtr.name
  interface                 = google_compute_router_interface.jlr-tst-hst-2-backup-rtr-ic-int.name
  peer_ip_address           = "169.254.11.66"
  peer_asn                  = "65305"
  advertised_route_priority = 1007
}
