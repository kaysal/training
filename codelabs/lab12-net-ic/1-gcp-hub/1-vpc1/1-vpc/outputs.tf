
output "network" {
  value = {
    vpc1 = google_compute_network.vpc1
  }
  sensitive = true
}

output "subnetwork" {
  value = {
    asia = {
      browse   = google_compute_subnetwork.browse_cidr_asia
      cart     = google_compute_subnetwork.cart_cidr_asia
      checkout = google_compute_subnetwork.checkout_cidr_asia
      db       = google_compute_subnetwork.db_cidr_asia
    }
    eu = {
      browse   = google_compute_subnetwork.browse_cidr_eu
      cart     = google_compute_subnetwork.cart_cidr_eu
      checkout = google_compute_subnetwork.checkout_cidr_eu
      db       = google_compute_subnetwork.db_cidr_eu
      nic      = google_compute_subnetwork.nic_cidr_eu
      batch    = google_compute_subnetwork.batch_cidr_eu
    }
    us = {
      browse   = google_compute_subnetwork.browse_cidr_us
      cart     = google_compute_subnetwork.cart_cidr_us
      checkout = google_compute_subnetwork.checkout_cidr_us
      db       = google_compute_subnetwork.db_cidr_us
      mqtt     = google_compute_subnetwork.mqtt_cidr_us
      nic      = google_compute_subnetwork.nic_cidr_us
      probe    = google_compute_subnetwork.probe_cidr_us
      payment  = google_compute_subnetwork.payment_cidr_us
    }
  }
  sensitive = true
}


output "gclb_vip" {
  value     = google_compute_global_address.gclb_vip
  sensitive = true
}

output "gclb_standard_vip" {
  value     = google_compute_address.gclb_standard_vip
  sensitive = true
}

output "mqtt_tcp_proxy_vip" {
  value     = google_compute_global_address.mqtt_tcp_proxy_vip
  sensitive = true
}
