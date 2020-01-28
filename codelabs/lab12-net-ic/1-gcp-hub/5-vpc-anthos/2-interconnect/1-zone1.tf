
# cloud router

resource "google_compute_router" "zone1_router" {
  project = var.project_id
  name    = "${var.hub.vpc_anthos.prefix}zone1-router"
  network = local.vpc_anthos.self_link
  region  = var.hub.vpc_anthos.eu.region
  bgp {
    asn               = var.hub.vpc_anthos.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# interconnect attachment

resource "google_compute_interconnect_attachment" "zone1_vlan_314" {
  project           = var.project_id
  name              = "${var.hub.vpc_anthos.prefix}zone1-vlan-314"
  interconnect      = local.ic_zone1_url
  type              = "DEDICATED"
  region            = var.hub.vpc_anthos.eu.region
  bandwidth         = "BPS_10G"
  vlan_tag8021q     = var.hub.vpc_anthos.eu.zone2.vlan_id
  router            = google_compute_router.zone1_router.self_link
  candidate_subnets = [var.hub.vpc_anthos.eu.zone1.candidate_subnets]
  admin_enabled     = true

  lifecycle {
    ignore_changes = all
  }
}

# cloud router interface

resource "google_compute_router_interface" "zone1_vlan_314" {
  project                 = var.project_id
  region                  = var.hub.vpc_anthos.eu.region
  name                    = "${var.hub.vpc_anthos.prefix}zone1-vlan-314"
  interconnect_attachment = google_compute_interconnect_attachment.zone1_vlan_314.name
  router                  = google_compute_router.zone1_router.name
  ip_range                = var.hub.vpc_anthos.eu.zone1.ip_range
}

# cloud router bgp peer

resource "google_compute_router_peer" "zone1_vlan_314" {
  project                   = var.project_id
  region                    = var.hub.vpc_anthos.eu.region
  name                      = "${var.hub.vpc_anthos.prefix}zone1-vlan-314"
  router                    = google_compute_router.zone1_router.name
  interface                 = google_compute_router_interface.zone1_vlan_314.name
  peer_ip_address           = var.hub.vpc_anthos.eu.zone1.peer_ip_address
  peer_asn                  = var.hub.vpc_anthos.eu.zone1.peer_asn
  advertised_route_priority = var.hub.vpc_anthos.eu.zone1.advertised_route_priority
}
