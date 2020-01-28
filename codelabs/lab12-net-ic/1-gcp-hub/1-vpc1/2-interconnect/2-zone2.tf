# cloud router

resource "google_compute_router" "zone2_router" {
  project = var.project_id
  name    = "${var.hub.vpc1.prefix}zone2-router"
  network = local.vpc1.self_link
  region  = var.hub.vpc1.eu.region
  bgp {
    asn            = var.hub.vpc1.asn
    advertise_mode = "CUSTOM"
    #advertised_groups = ["ALL_SUBNETS"]

    advertised_ip_ranges {
      range = "10.0.0.0/8"
    }
  }
}

# interconnect attachment

resource "google_compute_interconnect_attachment" "zone2_vlan_304" {
  project           = var.project_id
  name              = "${var.hub.vpc1.prefix}zone2-vlan-304"
  interconnect      = local.ic_zone2_url
  type              = "DEDICATED"
  bandwidth         = "BPS_10G"
  vlan_tag8021q     = var.hub.vpc1.eu.zone2.vlan_id
  region            = var.hub.vpc1.eu.region
  router            = google_compute_router.zone2_router.self_link
  candidate_subnets = [var.hub.vpc1.eu.zone2.candidate_subnets]
  admin_enabled     = true

  lifecycle {
    ignore_changes = all
  }
}

# cloud router interface

resource "google_compute_router_interface" "zone2_vlan_304" {
  project                 = var.project_id
  region                  = var.hub.vpc1.eu.region
  name                    = "${var.hub.vpc1.prefix}zone2-vlan-304"
  interconnect_attachment = google_compute_interconnect_attachment.zone2_vlan_304.name
  router                  = google_compute_router.zone2_router.name
  ip_range                = var.hub.vpc1.eu.zone2.ip_range
}

# cloud router bgp peer

resource "google_compute_router_peer" "zone2_vlan_304" {
  project                   = var.project_id
  region                    = var.hub.vpc1.eu.region
  name                      = "${var.hub.vpc1.prefix}zone2-vlan-304"
  router                    = google_compute_router.zone2_router.name
  interface                 = google_compute_router_interface.zone2_vlan_304.name
  peer_ip_address           = var.hub.vpc1.eu.zone2.peer_ip_address
  peer_asn                  = var.hub.vpc1.eu.zone2.peer_asn
  advertised_route_priority = var.hub.vpc1.eu.zone2.advertised_route_priority
}
