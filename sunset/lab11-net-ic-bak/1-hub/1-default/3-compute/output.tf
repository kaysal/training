output "instances" {
  value = {
    browse_asia   = google_compute_instance.browse_asia
    browse_eu     = google_compute_instance.browse_eu
    browse_us     = google_compute_instance.browse_us
    cart_asia     = google_compute_instance.cart_asia
    cart_eu       = google_compute_instance.cart_eu
    cart_us       = google_compute_instance.cart_us
    checkout_asia = google_compute_instance.checkout_asia
    checkout_eu1  = google_compute_instance.checkout_eu1
    checkout_eu2  = google_compute_instance.checkout_eu2
    checkout_eu3  = google_compute_instance.checkout_eu3
    checkout_us   = google_compute_instance.checkout_us
    feeds_asia    = google_compute_instance.feeds_asia
    feeds_eu1     = google_compute_instance.feeds_eu1
    feeds_eu2     = google_compute_instance.feeds_eu2
    feeds_eu3     = google_compute_instance.feeds_eu3
    feeds_us      = google_compute_instance.feeds_us
    db_asia       = google_compute_instance.db_asia
    db_eu         = google_compute_instance.db_eu
    db_us         = google_compute_instance.db_us
    smtp_us       = google_compute_instance.smtp_us
    payment_us    = google_compute_instance.payment_us
  }
  sensitive = true
}

output "health_check" {
  value = {
    default = google_compute_health_check.default
  }
  sensitive = true
}
