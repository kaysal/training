
# hub to spoke1

resource "google_compute_network_peering" "hub_to_spoke1" {
  name         = "hub-to-spoke1"
  network      = local.hub_default.self_link
  peer_network = local.spoke_custom.self_link
}

# spoke1 to hub

resource "google_compute_network_peering" "spoke1_to_hub" {
  name         = "spoke1-to-hub"
  network      = local.spoke_custom.self_link
  peer_network = local.hub_default.self_link
}
