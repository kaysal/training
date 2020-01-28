
# browse
#-------------------------------------------

# asia

locals {
  browse_asia_init = templatefile("scripts/browse.sh.tpl", {
    TARGET = var.hub.default.asia.db_ip
    DIR    = "browse"
    n      = 1
    c      = 1
  })
}

resource "google_compute_instance_template" "browse_asia" {
  name         = "browse-asia"
  region       = var.hub.default.asia.region
  machine_type = var.global.standard_machine

  tags = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.image_asia_web.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  metadata_startup_script = local.browse_asia_init

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}

# eu

locals {
  browse_eu_init = templatefile("scripts/browse.sh.tpl", {
    TARGET = var.hub.default.eu.db_ip
    DIR    = "browse"
    n      = 1
    c      = 1
  })
}

resource "google_compute_instance_template" "browse_eu" {
  name         = "browse-eu"
  region       = var.hub.default.eu.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.image_eu_web.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  metadata_startup_script = local.browse_eu_init

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}

# us

locals {
  browse_us_init = templatefile("scripts/browse.sh.tpl", {
    TARGET = var.hub.default.us.db_ip
    DIR    = "browse"
    n      = 1
    c      = 1
  })
}

resource "google_compute_instance_template" "browse_us" {
  name         = "browse-us"
  region       = var.hub.default.us.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.image_us_web.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  metadata_startup_script = local.browse_us_init

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

locals {
  cart_asia_init = templatefile("scripts/cart.sh.tpl", {
    TARGET = var.hub.default.asia.db_ip
    DIR    = "cart"
    n      = 1
    c      = 1
  })
}

resource "google_compute_instance_template" "cart_asia" {
  name         = "cart-asia"
  region       = var.hub.default.asia.region
  machine_type = var.global.standard_machine

  tags = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.image_asia_web.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  metadata_startup_script = local.cart_asia_init

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}

# eu

locals {
  cart_eu_init = templatefile("scripts/cart.sh.tpl", {
    TARGET = var.hub.default.eu.db_ip
    DIR    = "cart"
    n      = 1
    c      = 1
  })
}

resource "google_compute_instance_template" "cart_eu" {
  name         = "cart-eu"
  region       = var.hub.default.eu.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.image_eu_web.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  metadata_startup_script = local.cart_eu_init

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}

# us

locals {
  cart_us_init = templatefile("scripts/cart.sh.tpl", {
    TARGET = var.hub.default.us.db_ip
    DIR    = "cart"
    n      = 1
    c      = 1
  })
}

resource "google_compute_instance_template" "cart_us" {
  name         = "cart-us"
  region       = var.hub.default.us.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.image_us_web.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  metadata_startup_script = local.cart_us_init

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

locals {
  checkout_asia_init = templatefile("scripts/checkout.sh.tpl", {
    TARGET = var.hub.default.asia.db_ip
    DIR    = "checkout"
    n      = 1
    c      = 1
  })
}

resource "google_compute_instance_template" "checkout_asia" {
  name         = "checkout-asia"
  region       = var.hub.default.asia.region
  machine_type = var.global.standard_machine

  tags = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.image_asia_web.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  metadata_startup_script = local.checkout_asia_init

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}

# eu

locals {
  checkout_eu_init = templatefile("scripts/checkout.sh.tpl", {
    TARGET = var.hub.default.eu.db_ip
    DIR    = "checkout"
    n      = 1
    c      = 1
  })
}

resource "google_compute_instance_template" "checkout_eu" {
  name         = "checkout-eu"
  region       = var.hub.default.eu.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.image_eu_web.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  metadata_startup_script = local.checkout_eu_init

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = all
  }
}

# us

locals {
  checkout_us_init = templatefile("scripts/checkout.sh.tpl", {
    TARGET = var.hub.default.us.db_ip
    DIR    = "checkout"
    n      = 1
    c      = 1
  })
}

resource "google_compute_instance_template" "checkout_us" {
  name         = "checkout-us"
  region       = var.hub.default.us.region
  machine_type = var.global.standard_machine
  tags         = ["web", "lockdown"]

  disk {
    source_image = data.google_compute_image.image_us_web.self_link
    boot         = true
  }

  network_interface {
    network = local.default.name
  }

  metadata_startup_script = local.checkout_us_init

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
    source_image = data.google_compute_image.image_us_web.self_link
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
    source_image = data.google_compute_image.image_us_web.self_link
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
