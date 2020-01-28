
# hub to svc
#---------------------------------------

resource "google_compute_network_peering" "hub_to_eu1_vpcx_to_svc" {
  provider             = google-beta
  name                 = "${var.hub.prefix}eu1-vpcx-to-svc"
  network              = google_compute_network.hub_eu1_vpcx.self_link
  peer_network         = google_compute_network.svc_vpc.self_link
  export_custom_routes = "true"
  import_custom_routes = "true"
}

resource "google_compute_network_peering" "hub_to_eu2_vpcx_to_svc" {
  provider             = google-beta
  name                 = "${var.hub.prefix}eu2-vpcx-to-svc"
  network              = google_compute_network.hub_eu2_vpcx.self_link
  peer_network         = google_compute_network.svc_vpc.self_link
  export_custom_routes = "true"
  import_custom_routes = "true"

  depends_on = [google_compute_network_peering.hub_to_eu1_vpcx_to_svc]
}

resource "google_compute_network_peering" "hub_to_asia1_vpcx_to_svc" {
  provider             = google-beta
  name                 = "${var.hub.prefix}asia1-vpcx-to-svc"
  network              = google_compute_network.hub_asia1_vpcx.self_link
  peer_network         = google_compute_network.svc_vpc.self_link
  export_custom_routes = "true"
  import_custom_routes = "true"

  depends_on = [google_compute_network_peering.hub_to_eu2_vpcx_to_svc]
}

resource "google_compute_network_peering" "hub_to_asia2_vpcx_to_svc" {
  provider             = google-beta
  name                 = "${var.hub.prefix}asia2-vpcx-to-svc"
  network              = google_compute_network.hub_asia2_vpcx.self_link
  peer_network         = google_compute_network.svc_vpc.self_link
  export_custom_routes = "true"
  import_custom_routes = "true"

  depends_on = [google_compute_network_peering.hub_to_asia1_vpcx_to_svc]
}

resource "google_compute_network_peering" "hub_to_us1_vpcx_to_svc" {
  provider             = google-beta
  name                 = "${var.hub.prefix}us1-vpcx-to-svc"
  network              = google_compute_network.hub_us1_vpcx.self_link
  peer_network         = google_compute_network.svc_vpc.self_link
  export_custom_routes = "true"
  import_custom_routes = "true"

  depends_on = [google_compute_network_peering.hub_to_asia2_vpcx_to_svc]
}

resource "google_compute_network_peering" "hub_to_us2_vpcx_to_svc" {
  provider             = google-beta
  name                 = "${var.hub.prefix}us2-vpcx-to-svc"
  network              = google_compute_network.hub_us2_vpcx.self_link
  peer_network         = google_compute_network.svc_vpc.self_link
  export_custom_routes = "true"
  import_custom_routes = "true"

  depends_on = [google_compute_network_peering.hub_to_us1_vpcx_to_svc]
}

# svc to hub
#---------------------------------------

resource "google_compute_network_peering" "svc_to_hub_eu1_vpcx" {
  provider             = google-beta
  name                 = "${var.svc.prefix}to-hub-eu1-vpcx"
  network              = google_compute_network.svc_vpc.self_link
  peer_network         = google_compute_network.hub_eu1_vpcx.self_link
  export_custom_routes = "true"
  import_custom_routes = "true"

  depends_on = [google_compute_network_peering.hub_to_us2_vpcx_to_svc]
}

resource "google_compute_network_peering" "svc_to_hub_eu2_vpcx" {
  provider             = google-beta
  name                 = "${var.svc.prefix}to-hub-eu2-vpcx"
  network              = google_compute_network.svc_vpc.self_link
  peer_network         = google_compute_network.hub_eu2_vpcx.self_link
  export_custom_routes = "true"
  import_custom_routes = "true"

  depends_on = [google_compute_network_peering.svc_to_hub_eu1_vpcx]
}

resource "google_compute_network_peering" "svc_to_hub_asia1_vpcx" {
  provider             = google-beta
  name                 = "${var.svc.prefix}to-hub-asia1-vpcx"
  network              = google_compute_network.svc_vpc.self_link
  peer_network         = google_compute_network.hub_asia1_vpcx.self_link
  export_custom_routes = "true"
  import_custom_routes = "true"

  depends_on = [google_compute_network_peering.svc_to_hub_eu2_vpcx]
}

resource "google_compute_network_peering" "svc_to_hub_asia2_vpcx" {
  provider             = google-beta
  name                 = "${var.svc.prefix}to-hub-asia2-vpcx"
  network              = google_compute_network.svc_vpc.self_link
  peer_network         = google_compute_network.hub_asia2_vpcx.self_link
  export_custom_routes = "true"
  import_custom_routes = "true"

  depends_on = [google_compute_network_peering.svc_to_hub_asia1_vpcx]
}

resource "google_compute_network_peering" "svc_to_hub_us1_vpcx" {
  provider             = google-beta
  name                 = "${var.svc.prefix}to-hub-us1-vpcx"
  network              = google_compute_network.svc_vpc.self_link
  peer_network         = google_compute_network.hub_us1_vpcx.self_link
  export_custom_routes = "true"
  import_custom_routes = "true"

  depends_on = [google_compute_network_peering.svc_to_hub_asia2_vpcx]
}

resource "google_compute_network_peering" "svc_to_hub_us2_vpcx" {
  provider             = google-beta
  name                 = "${var.svc.prefix}to-hub-us2-vpcx"
  network              = google_compute_network.svc_vpc.self_link
  peer_network         = google_compute_network.hub_us2_vpcx.self_link
  export_custom_routes = "true"
  import_custom_routes = "true"

  depends_on = [google_compute_network_peering.svc_to_hub_us1_vpcx]
}
