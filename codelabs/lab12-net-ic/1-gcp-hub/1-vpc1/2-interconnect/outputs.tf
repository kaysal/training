
output "megaport" {
  value = {
    state              = google_compute_interconnect_attachment.megaport_zone1.state
    google_ref_id      = google_compute_interconnect_attachment.megaport_zone1.google_reference_id
    pairing_key        = google_compute_interconnect_attachment.megaport_zone1.pairing_key
    partner_asn        = google_compute_interconnect_attachment.megaport_zone1.partner_asn
    cloud_router_ip    = google_compute_interconnect_attachment.megaport_zone1.cloud_router_ip_address
    customer_router_ip = google_compute_interconnect_attachment.megaport_zone1.customer_router_ip_address
  }
}
