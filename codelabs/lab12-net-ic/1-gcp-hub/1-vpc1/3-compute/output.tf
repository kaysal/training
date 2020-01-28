output "instances" {
  value = {
    db_asia = google_compute_instance.db_asia
    db_eu   = google_compute_instance.db_eu
    db_us   = google_compute_instance.db_us
  }
  sensitive = true
}

output "templates" {
  value = {
    browse_asia   = google_compute_instance_template.browse_asia
    browse_eu     = google_compute_instance_template.browse_eu
    browse_us     = google_compute_instance_template.browse_us
    cart_asia     = google_compute_instance_template.cart_asia
    cart_eu       = google_compute_instance_template.cart_eu
    cart_us       = google_compute_instance_template.cart_us
    checkout_asia = google_compute_instance_template.checkout_asia
    checkout_eu   = google_compute_instance_template.checkout_eu
    checkout_us   = google_compute_instance_template.checkout_us
    mqtt_us       = google_compute_instance_template.mqtt_us
    payment_us    = google_compute_instance_template.payment_us
  }
  sensitive = true
}

output "health_check" {
  value = {
    vpc1 = google_compute_health_check.vpc1
  }
  sensitive = true
}
