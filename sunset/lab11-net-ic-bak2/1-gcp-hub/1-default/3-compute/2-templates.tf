

# browse
#-------------------------------------------

# asia

resource "google_compute_instance_template" "browse_asia" {
  name         = "browse-asia"
  region       = var.hub.default.asia.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.browse_asia.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}

# eu

resource "google_compute_instance_template" "browse_eu" {
  name         = "browse-eu"
  region       = var.hub.default.eu.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.browse_eu.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}

# us

resource "google_compute_instance_template" "browse_us" {
  name         = "browse-us"
  region       = var.hub.default.us.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.browse_us.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}

# cart
#-------------------------------------------

# asia

resource "google_compute_instance_template" "cart_asia" {
  name         = "cart-asia"
  region       = var.hub.default.asia.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.cart_asia.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}

# eu

resource "google_compute_instance_template" "cart_eu" {
  name         = "cart-eu"
  region       = var.hub.default.eu.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.cart_eu.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}

# us

resource "google_compute_instance_template" "cart_us" {
  name         = "cart-us"
  region       = var.hub.default.us.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.cart_us.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}

# checkout
#-------------------------------------------

# asia

resource "google_compute_instance_template" "checkout_asia" {
  name         = "checkout-asia"
  region       = var.hub.default.asia.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.checkout_asia.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}

# eu

resource "google_compute_instance_template" "checkout_eu" {
  name         = "checkout-eu"
  region       = var.hub.default.eu.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.checkout_eu.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}

# us

resource "google_compute_instance_template" "checkout_us" {
  name         = "checkout-us"
  region       = var.hub.default.us.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.checkout_us.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}

# feeds
#-------------------------------------------

# asia

resource "google_compute_instance_template" "feeds_asia" {
  name         = "feeds-asia"
  region       = var.hub.default.asia.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.feeds_asia.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}

# eu

resource "google_compute_instance_template" "feeds_eu" {
  name         = "feeds-eu"
  region       = var.hub.default.eu.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.feeds_eu.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}

# us

resource "google_compute_instance_template" "feeds_us" {
  name         = "feeds-us"
  region       = var.hub.default.us.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.feeds_us.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}

# mqtt
#-------------------------------------------

# us

locals {
  mqtt_us_init = templatefile("scripts/default.sh.tpl", {})
}

resource "google_compute_instance_template" "mqtt_us" {
  name         = "mqtt-us"
  region       = var.hub.default.us.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.mqtt_us.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}

# payment
#-------------------------------------------

# us

locals {
  payment_us_init = templatefile("scripts/default.sh.tpl", {})
}

resource "google_compute_instance_template" "payment_us" {
  name         = "payment-us"
  region       = var.hub.default.us.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.payment_us.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}
