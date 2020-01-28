
# browse
#---------------------------------------

# asia

resource "google_compute_instance_group" "browse_asia" {
  name      = "browse-asia"
  zone      = "${var.hub.default.asia.region}-b"
  instances = [local.instances.browse_asia.self_link]

  named_port {
    name = "http"
    port = 80
  }
}

# eu

resource "google_compute_instance_group" "browse_eu" {
  name      = "browse-eu"
  zone      = "${var.hub.default.eu.region}-b"
  instances = [local.instances.browse_eu.self_link]

  named_port {
    name = "http"
    port = 80
  }
}

# us

resource "google_compute_instance_group" "browse_us" {
  name      = "browse-us"
  zone      = "${var.hub.default.us.region}-c"
  instances = [local.instances.browse_us.self_link]

  named_port {
    name = "http"
    port = 80
  }
}

# cart
#---------------------------------------

# asia

resource "google_compute_instance_group" "cart_asia" {
  name      = "cart-asia"
  zone      = "${var.hub.default.asia.region}-b"
  instances = [local.instances.cart_asia.self_link]

  named_port {
    name = "http"
    port = 80
  }
}

# eu

resource "google_compute_instance_group" "cart_eu" {
  name      = "cart-eu"
  zone      = "${var.hub.default.eu.region}-b"
  instances = [local.instances.cart_eu.self_link]

  named_port {
    name = "http"
    port = 80
  }
}

# us

resource "google_compute_instance_group" "cart_us" {
  name      = "cart-us"
  zone      = "${var.hub.default.us.region}-c"
  instances = [local.instances.cart_us.self_link]

  named_port {
    name = "http"
    port = 80
  }
}


# checkout
#---------------------------------------

# asia

resource "google_compute_instance_group" "checkout_asia" {
  name      = "checkout-asia"
  zone      = "${var.hub.default.asia.region}-b"
  instances = [local.instances.checkout_asia.self_link]

  named_port {
    name = "http"
    port = 80
  }
}

# eu

resource "google_compute_instance_group" "checkout_eu" {
  name = "checkout-eu"
  zone = "${var.hub.default.eu.region}-b"

  instances = [
    local.instances.checkout_eu1.self_link,
    local.instances.checkout_eu2.self_link,
    local.instances.checkout_eu3.self_link
  ]

  named_port {
    name = "http"
    port = 80
  }
}

# us

resource "google_compute_instance_group" "checkout_us" {
  name      = "checkout-us"
  zone      = "${var.hub.default.us.region}-c"
  instances = [local.instances.checkout_us.self_link]

  named_port {
    name = "http"
    port = 80
  }
}

# feeds
#---------------------------------------

# asia

resource "google_compute_instance_group" "feeds_asia" {
  name      = "feeds-asia"
  zone      = "${var.hub.default.asia.region}-b"
  instances = [local.instances.feeds_asia.self_link]

  named_port {
    name = "http"
    port = 80
  }
}

# eu

resource "google_compute_instance_group" "feeds_eu" {
  name = "feeds-eu"
  zone = "${var.hub.default.eu.region}-b"

  instances = [
    local.instances.feeds_eu1.self_link,
    local.instances.feeds_eu2.self_link,
    local.instances.feeds_eu3.self_link,
  ]

  named_port {
    name = "http"
    port = 80
  }
}

# us

resource "google_compute_instance_group" "feeds_us" {
  name      = "feeds-us"
  zone      = "${var.hub.default.us.region}-c"
  instances = [local.instances.feeds_us.self_link]

  named_port {
    name = "http"
    port = 80
  }
}

# db
#---------------------------------------

# asia

resource "google_compute_instance_group" "db_asia" {
  name      = "db-asia"
  zone      = "${var.hub.default.asia.region}-b"
  instances = [local.instances.db_asia.self_link]

  named_port {
    name = "http"
    port = 80
  }
}

# eu

resource "google_compute_instance_group" "db_eu" {
  name      = "db-eu"
  zone      = "${var.hub.default.eu.region}-b"
  instances = [local.instances.db_eu.self_link]

  named_port {
    name = "http"
    port = 80
  }
}

# us

resource "google_compute_instance_group" "db_us" {
  name      = "db-us"
  zone      = "${var.hub.default.us.region}-b"
  instances = [local.instances.db_us.self_link]

  named_port {
    name = "http"
    port = 80
  }
}
